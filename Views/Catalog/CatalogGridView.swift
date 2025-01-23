import SwiftUI

struct CatalogGridView: View {

    @State private var searchText: String = ""
    
    @ObservedObject private var loader: CatalogViewModel
    private let router: Router
    
    public init(loader: CatalogViewModel, router: Router, searchTerm: String) {
        self.loader = loader
        self.router = router
        self.searchText = searchTerm
    }

    var body: some View {
            switch loader.threadState {
            case .initial:
                ProgressView("Loading catalog").task {
                    await loader.loadThread()
                }
            case .loading:
                ProgressView("Loading catalog")
            case .loaded:
                let thread = loader.filteredThread
                let posts = thread.posts
                let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
                    GeometryReader { geometry in
                        ScrollView {
                            LazyVGrid(columns: columns) {
                                ForEach(posts.indices, id: \.self) { index in
                                    let post = posts[index]
                                    CatalogGridItemView(viewModel: PostRowViewModel(thread: thread, post: post, router: router))
                                        .id(post.no)
                                        .frame(height: geometry.size.width/1.6)
                                }
                            }
                            .searchable(text: $searchText)
                            .onChange(of: searchText) {
//                                catalogViewModel.reloadThread(search: searchText)
                            }
                            .padding(.horizontal)
                        }
                    }
            case .error(_):
                Text("Error")
            }
    }
}

//#if DEBUG
//struct CatalogGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        CatalogGridView()
//            .environmentObject(AbstractPostViewModel.preview)
//    }
//}
//#endif
