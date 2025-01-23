import SwiftUI

struct HistoryTab: View {
    
    @StateObject var router = Router()
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            HistoryView()
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
                    if appState.selectedTab == .history {
                        router.navigateToRoot()
                    }
                }
        }
//        .onAppear {
//            appState.selectedTab = .history
//        }
        .environmentObject(router)
    }
}

#Preview {
    HistoryTab()
}