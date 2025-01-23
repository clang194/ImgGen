import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect


//This is the replies (navigate here from the catalog) essentially.
struct ThreadView: View {

    @StateObject private var loader: ThreadViewModel
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @EnvironmentObject var appStateManager: AppStateManager
    @EnvironmentObject var inlineViewModel: InlineViewModel
    
    @State private var scrollIndex: Int? = 0
    @FocusState private var searchFocused: Bool
    
    @State private var dragOffset: CGFloat = .zero
    @State private var galleryOpacity: Int = 0
    @State var refreshScreen: Bool = false
    @State var highlightedIndex: Int? = nil
    
    @State var scrollProxy: ScrollViewProxy?
    
    @State private var displayedItems: [Post] = []
    @State private var currentPage = 0
    let itemsPerPage = 1
    
    let board: String
    let id: Int
    

    init(board: String, id: Int) {
        self.board = board
        self.id = id
        _loader = StateObject(wrappedValue: ThreadViewModel(board: board, id: id))
    }
    
    func dummyView() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(Post.dummies) { post in
                    ThreadRowView(viewModel: PostRowViewModel(thread: ThreadModel.dummy, post: post, router: router))
                        .redacted(reason: .placeholder)
                }
            }
        }
    }
    
    var body: some View {
        Group {
            switch loader.threadState {
            case .initial:
                ZStack { //reimplement
                    Color("Default Scheme/AppBackground").ignoresSafeArea()
                    dummyView()
                        .onAppear {
                            Task {
                                await loader.loadThread()
                            }
                        }
                }
            case .loading:
                ZStack { //reimplement
                    Color("Default Scheme/AppBackground").ignoresSafeArea()
                    dummyView()
                }
            case .loaded(let thread):
                ZStack {
                    List(loader.filteredThread.posts.indices, id: \.self) { index in
                        VStack {
                            if index == 0 {
                                SearchBar(searchText: $loader.searchText)
                                    .padding(.top, 5)
                                    .padding(.bottom, 15)
                            }
                            let post = loader.filteredThread.posts[index]
                            VStack(spacing: 0) {
                                ThreadRowView(viewModel: PostRowViewModel(thread: thread, post: post, router: router))
                                //.scrollTargetBehavior(.viewAligned)
//                                    .onAppear {
//                                        loader.markSeen(id: post.id)
//                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke((highlightedIndex == index) ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: (highlightedIndex == index) ? 6 : 0)
                                    )
                                    .animation(.easeInOut(duration: 1), value: highlightedIndex)
                                Divider()
                                    .frame(maxHeight: 0.2)
                                    .overlay(Color.gray.opacity(0.35))
                                    .padding(.top, 1)
                            }
//                            .onAppear {
//                                loader.markSeen(id: post.id)
//                            }
                            .padding(4)
                            //}
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                    .listStyle(.plain)
                    //.scrollPosition(id: $scrollIndex)
                    //                            .introspect(.list, on: .iOS(.v16, .v17)) {
                    //                                print(type(of: $0)) // UICollectionView
                    //                                $0.decelerationRate = UIScrollView.DecelerationRate.fast
                    //                            }
                    .onAppear {
                        appStateManager.activeView = .thread
                    }
                    //                                if !loader.isPrefetchComplete {
                    //                                    MediaPrefetchToast()
                    //                                } reimplement
                    //
                    //}
                    .onAppear {
                        print("scroll refrawn")
                    }
                    //                            .scrollPosition(id: $scrollIndex)
                    .onChange(of: scrollIndex) {
                        print(scrollIndex)
                    }
                    //                            .onAppear {
                    //                                scrollProxy = proxy
                    //                            }
                    .refreshable {
                        Task {
                            await loader.refresh(true)
                            //await loader.refresh(withToast: true)
                        }
                    }
                    //                            .onReceive(galleryViewModel.scrollListener) {
                    //                                guard appStateManager.activeView == .thread,
                    //                                let selection = galleryViewModel.selection,
                    //                                let selectionIndex = loader.thread.posts.firstIndex(where: {$0 == selection}) else { return }
                    //                                withAnimation {
                    //                                    scrollIndex = selectionIndex
                    //                                }
                    //                                highlightedIndex = selectionIndex
                    //                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    //                                    withAnimation {
                    //                                        highlightedIndex = nil
                    //                                    }
                    //                                }
                    //                            }
                    .overlay {
                        if loader.newPostsCount > 0 {
                            FetchNewPostsToast(postCount: loader.newPostsCount, onClick: {
                                withAnimation {
                                    scrollIndex = loader.filteredThread.posts.count - 1
                                    loader.newPostsCount = 0
                                }
                            })
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    loader.newPostsCount = 0
                                }
                            }
                        }
                    }
                    //}
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if let proxy = scrollProxy {
                                UnreadCounter(scrollProxy: proxy, viewModel: loader.unreadCountViewModel)
                            } //reimplement
                        }
                    }
                }
                .onAppear {
                    loader.startTimer()
                    guard loader.scrollIndex != 0 else { return }
                    withAnimation {
                        scrollIndex = loader.scrollIndex
                    }
                }
                .onDisappear {
                    //print("disappear")
                    loader.scrollIndex = scrollIndex
                    loader.stopTimer()
                    loader.saveState()
                }
                .onOpenURL { url in //todo remove duplicate callback
                    guard let action = URLHandler().handleURL(url) else { return }
                    switch action {
                    case .reply(let id):
                        guard let id = Int(id), let post =  thread.getPost(from: id) else {return}
                        inlineViewModel.showReply(thread: thread, of: post)
                    default:
                        return
                    }
                }
                .environmentObject(inlineViewModel)
                    //}
                //}
                .navigationBarBackButtonHidden(inlineViewModel.isShowing)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        BookmarkButton(viewModel: loader)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                loader.sortType = .newestFirst
                            } label: {
                                Label("Newest first", systemImage: "arrow.clockwise.circle")
                            }
                            
                            Button {
                                loader.sortType = .oldestFirst
                            } label: {
                                Label("Oldest first", systemImage: "arrow.counterclockwise.circle")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu(content: {
                            Button(action: {
                                router.navigate(to: .galleryGrid(media: thread.media))
                            }, label: {
                                Label("View images", systemImage: "photo.stack")
                            })
                            
                            ShareLink(item: thread.threadUrl)
                        }, label: {
                            Image(systemName: "ellipsis.circle")
                        })
                    }
                }
                //
            case .error:
                Text("Error")
            }
        }
        .navigationBarTitle("Replies", displayMode: .large)
    }
//    
//    func loadMoreItems() {
//        guard currentPage * itemsPerPage < loader.filteredThread.posts.count else { return }
//
//        currentPage += 1
//        let startIndex = currentPage * itemsPerPage
//        let endIndex = min((currentPage + 1) * itemsPerPage, loader.filteredThread.posts.count)
//        let newItems = Array(loader.filteredThread.posts[startIndex..<endIndex])
//        displayedItems.append(contentsOf: newItems)
//    }
}


//extension ThreadViewModel {
//    static var preview: ThreadViewModel {
//        let preview = ThreadViewModel(board: "a", id: 252301438)
//        preview.setThread_Preview()
//        preview.setLoaded_Preview()
//        return preview
//    }
//}

//#Preview {
//    Group {
//        ThreadView(board: "a", id: 252301438)
//            .environmentObject(Router())
//            .environmentObject(GalleryViewModel())
//            .environmentObject(AppStateManager())
//            .environmentObject(InlineViewModel())
//        
//        NavigationView {
//            ThreadView(board: "a", id: 252301438)
//                .environmentObject(Router())
//                .environmentObject(GalleryViewModel())
//                .environmentObject(AppStateManager())
//                .environmentObject(InlineViewModel())
//        }.previewDisplayName("with Navigation")
//    }
//}
/*
#if DEBUG
struct ThreadView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ThreadView(board: "a", id: 252301438, threadViewModel: AbstractPostViewModel.preview as! ThreadViewModel)
                .environmentObject(GalleryViewModel())
                .environmentObject(AppStateManager())
                .environmentObject(InlineViewModel())
            
            NavigationView {
                ThreadView(board: "a", id: 252301438, threadViewModel: AbstractPostViewModel.preview)
                    .environmentObject(GalleryViewModel())
                    .environmentObject(AppStateManager())
                    .environmentObject(InlineViewModel())
            }.previewDisplayName("with Navigation")
        }
    }
}
*/

//#if DEBUG
//extension AbstractPostViewModel {
//    static var preview: AbstractPostViewModel {
//        let preview = ThreadViewModel(board: "a", threadId: 252301438)
//        preview.setThread_Preview()
//        preview.setLoaded_Preview()// Set the state you want for the preview
//        return preview
//    }
//}
//#endif
