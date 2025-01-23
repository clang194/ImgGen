mport SwiftUI

struct Message {
    let id = UUID()
    let content: String
}

struct BoardListRow: View {
    let board: Board
    let showNsfwTag: Bool
    let expandedPreview: Bool
    let router: Router
    @EnvironmentObject var viewModel: BoardViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("/\(board.board)/ • \(board.title)")
                    .font(Font.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .padding(.trailing, showNsfwTag ? 5 : 0)
                if showNsfwTag {
                    // Spacer()
                    TagElement(text: "NSFW", backgroundColor: .red)
                }
            }
            Text(board.meta_description.replacingOccurrences(of: "&quot;", with: "\""))
                .font(Font.system(size: 13))
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .contextMenu {
            BoardContextMenu(board: board)
        }
        .onTapGesture {
            router.navigate(to: .catalog(id: board.board, searchTerm: ""))
        }
    }
}

struct TagElement: View {
    var text: String
    var backgroundColor: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(backgroundColor)
            )
    }
}

//#if DEBUG
//struct BoardListElement_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            BoardListRow(
//                board: "sci",
//                title: "Science & Math",
//                meta_description: "A place to discuss science and math, A place to discuss science and math, A place to discuss science and math, A place to discuss science and math, A place to discuss science and math",
//                showNsfwTag: false,
//                expandedPreview: false
//            )
//            .previewDisplayName("SFW Board")
//
//            BoardListRow(
//                board: "b",
//                title: "Random",
//                meta_description: "The random board for discussing various topics",
//                showNsfwTag: true,
//                expandedPreview: false
//            )
//            .previewDisplayName("NSFW Board")
//        }
//    }
//}
//#endif
////
