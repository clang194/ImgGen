import SwiftUI

struct BoardListView: View {
    
    @EnvironmentObject var boardViewModel: BoardViewModel
    @EnvironmentObject var toastViewModel: ToastViewModel
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @EnvironmentObject var inlineViewModel: InlineViewModel
    
    private var router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    var body: some View {
        let favoriteBoards = boardViewModel.filteredBoards.filter { UserSettings.shared.favoriteBoards.contains($0.board) }
        let nonFavoriteBoards = boardViewModel.filteredBoards.filter { !UserSettings.shared.favoriteBoards.contains($0.board) }
        ZStack {
            Color("Default Scheme/AppBackground").ignoresSafeArea()
            List {
                Section(header:
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("Favorites")
                    }
                ) {
                    ForEach(favoriteBoards.indices, id: \.self) { index in
                        let element = favoriteBoards[index]
                        ZStack {
                            BoardListRow(
                                board: element,
                                showNsfwTag: boardViewModel.isNsfw(board: element.board),
                                expandedPreview: false,
                                router: router
                            )
                            //.frame(maxWidth: .infinity)
                            .id(element.board)
                        }
                        .swipeActions {
                            BoardSwipeButton(board: element)
                        }
                    }
                }
                .headerProminence(.increased)
                .id("FavoritesSection")
                
                // All boards
                Section(header:
                    HStack {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .foregroundStyle(.blue)
                        Text("Boards")
                    }
                ) {
                    ForEach(nonFavoriteBoards.indices, id: \.self) { index in
                        let element = nonFavoriteBoards[index]
                        ZStack {
                            BoardListRow(
                                board: element,
                                showNsfwTag: boardViewModel.isNsfw(board: element.board),
                                expandedPreview: false,
                                router: router
                            )
                            .id(element.board)
                        }
                        .contextMenu {
                            BoardContextMenu(board: element)
                        }
                        .swipeActions {
                            BoardSwipeButton(board: element)
                        }
                    }
                    //.onMove(perform: boardViewModel.reorderNonFavoriteBoards)
                }
                .headerProminence(.increased)
                .id("AllBoardsSection")
            }
            .searchable(text: $boardViewModel.searchText)
        }
        .id(boardViewModel.boardId)
    }
}

//#if DEBUG
//struct BoardListView_Preview: PreviewProvider {
//    static var previews: some View {
//        BoardListView()
//            .environmentObject(BoardViewModel.preview)
//            .environmentObject(ToastViewModel())
//    }
//}
//#endif
