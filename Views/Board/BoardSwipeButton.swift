import SwiftUI

struct BoardSwipeButton: View {
    
    let board: Board
    @ObservedObject private var userSettings = UserSettings.shared
    @EnvironmentObject var boardViewModel: BoardViewModel

    var favorited: Bool {
        userSettings.favoriteBoards.contains { $0 == board.board }
    }
    
    var body: some View {
        if favorited {
            Button(role: .destructive, action: {
                withAnimation {
                    boardViewModel.removeFromFavorites(board)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }) {
                Image(systemName: "star.slash.fill")
            }
        } else {
            Button(action: {
                withAnimation {
                    boardViewModel.addToFavorites(board)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }) {
                Image(systemName: "star")
            }
        }
    }
}

//#if DEBUG
//struct BoardSwipeButton_Previews: PreviewProvider {
//    static var previews: some View {
//        BoardSwipeButton(board: BoardViewModel.preview.boards.first!)
//    }
//}
//#endif
