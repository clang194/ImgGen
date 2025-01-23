import SwiftUI

struct BrowseTab: View {
    
    @StateObject var router = Router()
    @EnvironmentObject var appState: AppStateManager
    
    @State private var currentBoard: String = UserDefaults.standard.string(forKey: "lastBoard") ?? "a"

    var body: some View {
        NavigationStack(path: $router.navPath) {
            CatalogView(board: appState.selectedBoard)
//                .id(appState.selectedBoard)
                .navigationDestination(for: Router.Endpoint.self) { destination in
                    switch destination {
                    case .catalog(let id, let searchTerm):
                        CatalogView(board: id, searchTerm: searchTerm)
                    case .thread(let board, let id):
                        ThreadView(board: board, id: id)
                    case .bookmarks:
                        SavedView()
                    case .history:
                        HistoryView()
                    case .galleryGrid(let media):
                        GalleryGridView(media: media)
                    case .settings:
                        EmptyView()
                    }
                }
                .onChange(of: appState.tabRootSignal) { _ , newValue in
                    if appState.selectedTab == .browse {
                        router.navigateToRoot()
                    }
                }
                .onChange(of: currentBoard) { _, _ in
                    print("board changed")
                }
        }
//        .onAppear {
//            appState.selectedTab = .browse
//        }
        .environmentObject(router)
    }
}

#Preview {
    BrowseTab()
}
