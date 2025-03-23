//
//  CodableAppStorage.swift
//  Love4Music
//
//  Created by Martin Ševčík on 21.03.2025.
//

import SwiftUI

// a property wrapper that automatically encodes and decodes Codable values to/from UserDefaults
@propertyWrapper
struct CodableAppStorage<T: Codable> {
    // the key under which the data is stored in UserDefaults
    let key: String
    // the default value to return if no value is found in storage
    let defaultValue: T
    // the UserDefaults instance to use (defaults to .standard)
    var storage: UserDefaults = .standard
    
    // the wrapped value for the property
    // on get, it attempts to decode stored JSON data
    // on set, it encodes the value as JSON and saves it to UserDefaults
    var wrappedValue: T {
        get {
            // attempt to retrieve data for the given key
            guard let data = storage.data(forKey: key) else {
                return defaultValue
            }
            // attempt to decode the data into the expected type
            return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
        }
        set {
            // try to encode the new value as JSON
            if let data = try? JSONEncoder().encode(newValue) {
                storage.set(data, forKey: key)
            }
        }
    }
    
    // initializes the property wrapper with a default value and a UserDefaults key
    init(wrappedValue defaultValue: T, _ key: String) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
