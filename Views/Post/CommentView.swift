import SwiftUI

struct CommentView: View {

    let comment: String

    var body: some View {
        let commentHandler = HTMLParser(comment: comment)
        if let parsedComment = try? commentHandler.parseHTML() {
            Text(parsedComment)
                //.padding(.top, 3)
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(comment: "Hello")
    }
}
