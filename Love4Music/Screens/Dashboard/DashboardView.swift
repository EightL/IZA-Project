import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showCreateListSheet = false
    // unique identifier used to force a refresh of the charts
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationStack {
            // i had to extract the sections due to compiler taking too long to compile
            List {
                // extracted spotify account section
                spotifySection
                
                // extracted album lists section
                albumListsSection
                
                // extracted charts section
                chartsSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dashboard")
            // present the Create List sheet
            .sheet(isPresented: $showCreateListSheet) {
                CreateListView { listName in
                    viewModel.createList(named: listName)
                }
            }
        }
        // present the share sheet
        .sheet(isPresented: $viewModel.showShareSheet) {
            ShareSheet(items: viewModel.shareItems)
        }
    }
    
    // MARK: - Extracted Sections
    
    // spotify account section
    private var spotifySection: some View {
        Section(header: Text("Spotify Account")) {
            if viewModel.isSignedIn {
                HStack {
                    Text("Signed in to Spotify")
                    Image(systemName: "checkmark")
                    Spacer()
                    Button("Sign out") {
                        viewModel.signOut()
                    }
                }
            } else {
                HStack {
                    Text("Signed out of Spotify")
                    Image(systemName: "xmark")
                    Spacer()
                    Button("Sign In") {
                        viewModel.signIn()
                    }
                }
            }
        }
    }
    
    // album lists section
    private var albumListsSection: some View {
        Section(header: albumListsHeader) {
            ForEach(viewModel.albumLists) { list in
                NavigationLink(destination: ListDetailView(albumList: list, collectionVM: viewModel.collectionVM)) {
                    AlbumListRow(list: list)
                }
                // swipe to delete
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteList(list)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                // swipe to export
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        viewModel.exportList(list)
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .tint(.blue)
                }
            }
        }
    }
    
    // header for the album lists section
    private var albumListsHeader: some View {
        HStack {
            Text("My Album Lists")
            Spacer()
            Button {
                showCreateListSheet.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    // charts section
    private var chartsSection: some View {
        Section(header: chartsHeader) {
            VStack {
                DashboardStatisticsView(
                    viewModel: DashboardStatisticsViewModel(
                        collectionVM: viewModel.collectionVM,
                        listsManager: AlbumListsManager.shared
                    )
                )
                // changing the ID forces the charts to refresh
                .id(refreshID)
                .frame(minHeight: 300)
            }
            .listRowInsets(EdgeInsets())
        }
    }
    
    // header for the charts section
    private var chartsHeader: some View {
        HStack {
            Text("Charts")
            Spacer()
            Button {
                refreshID = UUID()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
}

// a simple view to display an album list row
struct AlbumListRow: View {
    let list: AlbumList
    
    var body: some View {
        HStack {
            Text(list.name)
                .font(.headline)
            Spacer()
            Text("\(list.albumIDs.count) albums")
                .foregroundColor(.secondary)
        }
    }
}

// share sheet wraps UIActivityViewController for use in SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
