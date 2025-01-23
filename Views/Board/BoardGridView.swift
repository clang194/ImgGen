import SwiftUI

struct BoardGridView: View {
    
    @EnvironmentObject var boardViewModel: BoardViewModel
    @EnvironmentObject var toastViewModel: ToastViewModel
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @EnvironmentObject var inlineViewModel: InlineViewModel
    @EnvironmentObject var appStateManager: AppStateManager
    
    private var router: Router
    @Binding var showingBoards: Bool
    
    
    init(router: Router, showingBoards: Binding<Bool>) {
        self.router = router
        _showingBoards = showingBoards
    }
    
    let columns = [
        GridItem(.fixed(100), spacing: 6),
        GridItem(.fixed(100), spacing: 6),
        GridItem(.fixed(100), spacing: 6),
        GridItem(.fixed(100), spacing: 6)
    ]
    
    var body: some View {
        let favoriteBoards = boardViewModel.filteredBoards.filter { UserSettings.shared.favoriteBoards.contains($0.board)
        }
        VStack (alignment: .leading, spacing: 10) {
                Text("Favorite Boards")
                    .padding(.leading, 5)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(favoriteBoards.indices, id: \.self) { index in
                        let element = favoriteBoards[index]
                        let isNsfw = boardViewModel.isNsfw(board: element.board)
                        GeometryReader { geometry in
                            VStack(alignment: .center) {
                                Text("/\(element.board)/")
                                    .font(.system(size: 28))
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2.2)
                                Text(element.title)
                                    .frame(maxHeight: geometry.size.height / 3.5)
                                    .font(.system(size: 13))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        .padding(5)
                        .frame(width: 100, height: 100)
                        .background(isNsfw ? Color.red.opacity(0.15) : Color.blue.opacity(0.15))
                        .foregroundColor(Color.white)
                        .cornerRadius(6)
                        .contextMenu {
                            BoardContextMenu(board: element)
                        }
                        .onTapGesture {
                            appStateManager.selectedBoard = element.board
                            showingBoards = false
                        }
                    }
                    VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                        Image(systemName: "plus")
                            .font(.system(size: 28))
                        Text("Add Favorite")
                            .font(.system(size: 13))
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 100, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 6).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [16, 16]))
                    )
                    .foregroundStyle(.white)
                }
                .padding(.bottom, 15)
                Text("All Boards")
                    .padding(.leading, 5)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(boardViewModel.filteredBoards.indices, id: \.self) { index in
                        let element = boardViewModel.filteredBoards[index]
                        let isNsfw = boardViewModel.isNsfw(board: element.board)
                        GeometryReader { geometry in
                            VStack(alignment: .center) {
                                Text("/\(element.board)/")
                                    .font(.system(size: 28))
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2.2)
                                Text(element.title)
                                    .frame(maxHeight: geometry.size.height / 3.5)
                                    .font(.system(size: 13))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        .padding(5)
                        .frame(width: 100, height: 100)
                        .background(isNsfw ? Color.red.opacity(0.15) : Color.blue.opacity(0.15))
                        .foregroundColor(Color.white)
                        .cornerRadius(6)
                        .contextMenu {
                            BoardContextMenu(board: element)
                        }
                        .onTapGesture {
                            appStateManager.selectedBoard = element.board
                            showingBoards = false
//                                    router.replaceLast(with: .catalog(id: element.board, searchTerm: ""))
                        }
                    }
                }
                .padding(.bottom, 15)
            }
        }
    }


//#Preview {
//    BoardGridView(router: Router())
//        .environmentObject(Router())
//       // .environmentObject(ToastViewModel())
//    
//}
