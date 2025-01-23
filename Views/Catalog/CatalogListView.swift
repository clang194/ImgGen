import SwiftUI

struct CatalogListView: View {
    
    var filters = ["Favorites", "All", "Non Favorites"]
    var adultFilters = ["Adult", "All", "Misc"]

    @State private var showPhotoAccessDeniedAlert = false
    @State var lastIndex = 0
    @State var highlightedIndex: Int? = nil
    //@State var searchText: String
    
    @FocusState private var searchFocused: Bool
    
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @EnvironmentObject var appStateManager: AppStateManager
    @EnvironmentObject var router: Router
    @ObservedObject private var viewModel: CatalogViewModel
    //let router: Router
    
    public init(loader: CatalogViewModel, searchTerm: String) {
        self.viewModel = loader
        //self.router = router
        //viewModel.searchText = searchTerm
    }
    
    func dummyView() -> some View {
        ScrollView {
            LazyVStack {
                SearchBar(searchText: $viewModel.searchText)
                    .padding(.bottom, 6)
                ForEach(Post.dummies) { post in
                    CatalogRowView(viewModel: PostRowViewModel(thread: ThreadModel.dummy, post: post, router: router))
                        .environmentObject(router)
                        .redacted(reason: .placeholder)
                }
            }
        }
    }

    var body: some View {
        switch viewModel.threadState {
        case .initial:
            //EmptyView()
            dummyView()
            .onAppear {
                Task {
                    await viewModel.loadThread()
                }
            }
        case .loading:
            dummyView()
        case .loaded:
            ScrollViewReader { scrollView in
                    List(Array(viewModel.filteredThread.posts.enumerated()), id: \.offset) { index, post in
                        if index == 0 {
                            //Text("/aaaa/ • Catalog").font(.largeTitle).bold()
                            SearchBar(searchText: $viewModel.searchText)
                                .padding(.bottom, 6)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                        }
                            CatalogRowView(viewModel: PostRowViewModel(thread: viewModel.thread, post: post, router: router))
                                .id(post.no)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical, 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10) // choose the corner radius value you want
                                        .stroke((highlightedIndex == index) ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: (highlightedIndex == index) ? 6 : 0)
                                )
                                .animation(.easeInOut(duration: 1), value: highlightedIndex)
                        //}
                    }
                    .listStyle(.plain)
                    //.padding(.horizontal, 10)
                    .onReceive(galleryViewModel.scrollListener) {
                        guard appStateManager.activeView == .catalog,
                        let selection = galleryViewModel.selection,
                        let selectionIndex = viewModel.thread.posts.firstIndex(of: selection) else { return }
                        withAnimation(.easeInOut(duration: 0.5)) {
                            scrollView.scrollTo(selectionIndex, anchor: .center)
                        }
                        highlightedIndex = selectionIndex
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                highlightedIndex = nil
                            }
                        }
                    }
                    .onAppear {
                        appStateManager.activeView = .catalog
                        //loader.prefetch(thumbnail: true) reimplement
                    }
                //}
//                    .overlay {
//                        if !catalogViewModel.isPrefetchComplete {
//                            MediaPrefetchToast()
//                        }
//                    } reimplement
            }
//            .onAppear {
//                viewModel.reloadThread(search: searchText)
//            }
//            .onChange(of: searchText) {
//                viewModel.reloadThread(search: searchText)
//            }
        case .error:
            Text("Error")
        }
    }
}

func openAppSettings() {
    if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(appSettingsURL)
    }
}

//#if DEBUG
//struct CatalogListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CatalogListView()
//            .environmentObject(GalleryViewModel())
//            .environmentObject(AppStateManager())
//            .environmentObject(AbstractPostViewModel.preview)
//    }
//}
//#endif
