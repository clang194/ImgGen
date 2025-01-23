import SwiftUI

struct BoardContextMenu: View {

    let board: Board
    @ObservedObject private var userSettings = UserSettings.shared
    @EnvironmentObject var boardViewModel: BoardViewModel

    var favorited: Bool {
        userSettings.favoriteBoards.contains { $0 == board.board }
    }

    var body: some View {
        Button(action: {
            withAnimation {
                if favorited {
                    boardViewModel.removeFromFavorites(board)
                } else {
                    boardViewModel.addToFavorites(board)
                }
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }, label: {
            Text(favorited ? "Remove from favorites" : "Favorite")
            Image(systemName: favorited ? "star.slash.fill" : "star")
        })
    }
}

/*
#if DEBUG
struct BoardContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BoardContextMenu(board: "a")
                .previewDisplayName("Context Menu")
            BoardListElement(
                board: "sci",
                title: "Science & Math",
                meta_description: "A place to discuss science and math, A place to discuss science and math, A place to discuss science and math, A place to discuss science and math, A place to discuss science and math",
                showNsfwTag: false,
                expandedPreview: false
            )
            .fixedSize(horizontal: false, vertical: true)
            .contextMenu {
                BoardContextMenu(board: "a")
            }
            .previewDisplayName("With Post")
        }
    }
}
#endif
*/
