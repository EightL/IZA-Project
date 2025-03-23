//
//  CachedAsyncImage.swift
//  Love4Music
//
//  Created by Martin Ševčík on 21.03.2025.
//

import SwiftUI
import Combine

// a singleton class that manages an in-memory cache of images using NSCache
final class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()
    
    init() {
        // set a limit on the number of images stored to control memory usage
        cache.countLimit = 100
    }
    
    // retrieves an image for a given key
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: NSString(string: key))
    }

    // stores an image in the cache with an associated key
    func setImage(_ image: UIImage, forKey key: String) {
        // determine the cost using the image data size (optional)
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        cache.setObject(image, forKey: NSString(string: key), cost: cost)
    }
}

// an ObservableObject that downloads an image from a URL, caches it (both in memory and on disk), and publishes the loaded image
final class ImageLoader: ObservableObject {
    // published image that the view observes
    @Published var image: UIImage?
    
    private let url: URL
    private var dataTask: URLSessionDataTask?
    private var retryCount = 0
    private let maxRetryCount = 1
    
    // initializes the loader with a URL and immediately begins loading the image
    init(url: URL) {
        self.url = url
        loadImage()
    }
    
    // cancels the ongoing image download, if any
    func cancel() {
        dataTask?.cancel()
    }
    
    // loads the image by first checking the in-memory cache, then disk cache, and finally downloading it if needed
    private func loadImage() {
        let key = url.absoluteString
        
        // 1. check the in-memory cache
        if let cachedImage = ImageCache.shared.image(forKey: key) {
            self.image = cachedImage
            return
        }
        
        // 2. check the disk cache
        if let diskImage = loadImageFromDisk(forKey: key) {
            ImageCache.shared.setImage(diskImage, forKey: key)
            self.image = diskImage
            return
        }
        
        // 3. download the image if not cached
        dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // handle errors and optionally retry
            if let error = error {
                print("Error downloading image: \(error)")
                if let self = self, self.retryCount < self.maxRetryCount {
                    self.retryCount += 1
                    self.loadImage()
                }
                return
            }
            
            // ensure we have valid data and can create an image
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                return
            }
            
            // save the image to disk
            self?.saveImageToDisk(downloadedImage, forKey: key)
            // cache the image in memory
            ImageCache.shared.setImage(downloadedImage, forKey: key)
            
            // publish the image on the main thread
            DispatchQueue.main.async {
                self?.image = downloadedImage
            }
        }
        dataTask?.resume()
    }
    
    // disk caching helpers
    
    // returns the URL for the image cache directory
    private func cacheDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths.first?.appendingPathComponent("ImageCache")
    }
    
    // generates a file URL for a given key within the cache directory
    private func cacheFileURL(forKey key: String) -> URL? {
        guard let directory = cacheDirectory() else { return nil }
        // sanitize the key to create a valid file name
        let fileName = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return directory.appendingPathComponent(fileName)
    }
    
    // attempts to load an image from disk for a given key
    private func loadImageFromDisk(forKey key: String) -> UIImage? {
        guard let fileURL = cacheFileURL(forKey: key),
              FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
    
    // saves an image to disk for a given key
    private func saveImageToDisk(_ image: UIImage, forKey key: String) {
        guard let fileURL = cacheFileURL(forKey: key) else { return }
        // ensure the cache directory exists
        if let directory = cacheDirectory() {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        // save the image as a JPEG with compression quality
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }
}


// a view that loads an image asynchronously, displaying a placeholder until the image is available
struct CachedAsyncImage: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Image
    
    // initializes the view with a URL and an optional placeholder
    init(url: URL, placeholder: Image = Image("albumMock")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            // when the image is loaded, display it; otherwise, show the placeholder
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                placeholder
                    .resizable()
            }
        }
        // cancel the download task when the view disappears
        .onDisappear {
            loader.cancel()
        }
    }
}
