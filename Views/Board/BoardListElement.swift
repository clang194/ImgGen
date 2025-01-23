import SwiftUI

struct Message {
    let id = UUID()
    let content: String
}

struct BoardListRow\: View {
    let board: String
    let title: String
    let meta_description: String
    let showNsfwTag: Bool
    let expandedPreview: Bool
    @EnvironmentObject var viewModel: BoardViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("/" + board + "/ • " + title)
                    .font(Font.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .padding(.trailing, showNsfwTag ? 5 : 0)
                if showNsfwTag {
                    // Spacer()
                    TagElement(text: "NSFW", backgroundColor: .red)
                }
            }
            Text(meta_description.replacingOccurrences(of: "&quot;", with: "\""))
                .font(Font.system(size: 13))
                .foregroundColor(.gray)
                .lineLimit(expandedPreview ? 4 : 2)
                .multilineTextAlignment(.leading)
        }
        .onTapGesture {
            print("tsb")
            viewModel.navigateToCatalog(board: board)
        }
        //.scrollContentBackground(.hidden)
    }
}

struct TagElement: View {
    var text: String
    var backgroundColor: Color

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(backgroundColor)
            )
    }
}

#if DEBUG
struct BoardListElement_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BoardListRow\(
                board: "sci",
                title: "Science & Math",
                meta_description: "A place to discuss science and math, A place to discuss science and math, A place to discuss science and math, A place to discuss science and math, A place to discuss science and math",
                showNsfwTag: false,
                expandedPreview: false
            )
            .previewDisplayName("SFW Board")

            BoardListRow\(
                board: "b",
                title: "Random",
                meta_description: "The random board for discussing various topics",
                showNsfwTag: true,
                expandedPreview: false
            )
            .previewDisplayName("NSFW Board")
        }
    }
}
#endif
//
