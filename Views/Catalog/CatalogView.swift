import SwiftUI
enum FocusField: Hashable {
  case field
}
struct CatalogView: View {

    @State var board: String
    @State var searchTerm: String
    
    @StateObject private var viewModel: CatalogViewModel
    @EnvironmentObject var router: Router
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @EnvironmentObject var inlineViewModel: InlineViewModel
    @EnvironmentObject var appStateManager: AppStateManager
    
    @State private var dragOffset: CGFloat = .zero
    @State private var galleryOpacity: Int = 0
    @State private var isGridViewActive = false
    
    @State private var showingBoards = false
    @State private var showSearchBar: Bool = false
    @State private var boardsSearchTerm: String = ""
    @FocusState private var searching: Bool?
    
    @State private var navigationBarTint: Visibility = .automatic
    
    init(board: String, searchTerm: String = "") {
        self.board = board
        self.searchTerm = searchTerm
        _viewModel = StateObject(wrappedValue: CatalogViewModel(board: board))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Color("Default Scheme/AppBackground").ignoresSafeArea()
                VStack {
                    if isGridViewActive {
                        //CatalogGridView(loader: viewModel, router: router, searchTerm: searchTerm)
                    } else {
                        CatalogListView(loader: viewModel, searchTerm: searchTerm)
                            .environmentObject(router)
                            //.id(appStateManager.selectedBoard)
                    }
                }
                .refreshable {
                    Task {
                        await viewModel.loadThread()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Button {
                            //withAnimation(.easeIn) { //todo on initial entry
                                showingBoards.toggle()
                            //}
                        } label: {
                            Text("/\(board)/")
                                .font(.system(size: 24))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                    }
                    ToolbarItem {
                        Menu {
                            Button {
                                viewModel.sortType = .datePosted
                            } label: {
                                Label("Date posted", systemImage: viewModel.sortType == .datePosted ? "checkmark" : "calendar.badge.clock")
                            }
                            
                            Button {
                                viewModel.sortType = .lastReplied
                            } label: {
                                Label("Last replied", systemImage: viewModel.sortType == .lastReplied ? "checkmark" : "clock")
                            }
                            
                            Button {
                                viewModel.sortType = .replyCount
                            } label: {
                                Label("Reply count", systemImage: viewModel.sortType == .replyCount ? "checkmark" : "arrowshape.turn.up.left.2")
                            }
                            
                            Button {
                                viewModel.sortType = .imageCount
                            } label: {
                                Label("Image count", systemImage: viewModel.sortType == .imageCount ? "checkmark" : "photo")
                            }
                            
                            Divider()
                            
                            Menu {
                                Button {
                                    viewModel.isAscending = true
                                } label: {
                                    Label("Ascending", systemImage: viewModel.isAscending == true ? "checkmark" : "arrow.up")
                                }
                                
                                Button {
                                    viewModel.isAscending = false
                                } label: {
                                    Label("Descending", systemImage: viewModel.isAscending == false ? "checkmark" : "arrow.down")
                                }
                            } label: {
                                Label("Sort order", systemImage: "arrow.up.arrow.down")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                        .menuActionDismissBehavior(.disabled)
                    }
                    ToolbarItem {
                        Menu {
                            Button(action: {
                                router.navigate(to: .galleryGrid(media: viewModel.thread.media))
                            }, label: {
                                Label("View images", systemImage: "photo.stack")
                            })
                            Button(action: {
                                isGridViewActive.toggle()
                            }) {
                                Label(isGridViewActive ? "List view" : "Grid view", systemImage: isGridViewActive ? "rectangle.grid.1x2" : "square.grid.2x2")
                            }
                            ShareLink(item: viewModel.thread.catalogUrl)
                            
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                
            }
        }
        .onChange(of: showingBoards) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //transition length
                    navigationBarTint = .visible
                }
            } else {
                navigationBarTint = .automatic
            }
        }
        .onChange(of: appStateManager.selectedBoard) { _, newValue in
            self.board = newValue
            self.searchTerm = "" //TODO reset search term
            viewModel.reset(with: board)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(navigationBarTint, for: .navigationBar)
        .overlay {
            if showingBoards {
                BoardView(showingBoards: $showingBoards, showSearchBar: $showSearchBar, searchTerm: $boardsSearchTerm)
                    .environmentObject(router)
                    //.background(Color.darkGray)
                    //.transition(.move(edge: .bottom))
            }
        }
//        .onAppear {
//            let defaults = UserDefaults.standard
//            defaults.set(board, forKey: "lastBoard")
//        }
        //.navigationBarTitle("/\(board)/ • Catalog", displayMode: .inline)
//        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

//#if DEBUG
//struct CatalogView_Previews: PreviewProvider {
//    static var previews: some View {
//        CatalogView(board: "a", catalogViewModel: CatalogViewModel.preview as? CatalogViewModel)
//            .environmentObject(GalleryViewModel())
//            .environmentObject(AppStateManager())
//            .environmentObject(InlineViewModel())
//        
//        NavigationView {
//            CatalogView(board: "a", catalogViewModel: CatalogViewModel.preview as? CatalogViewModel)
//                .environmentObject(GalleryViewModel())
//                .environmentObject(AppStateManager())
//                .environmentObject(InlineViewModel())
//        }
//        .previewDisplayName("with Navigation")
//    }
//}
//#endif
