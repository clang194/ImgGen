import SwiftUI

struct GalleryPostView: View {

    let viewModel: PostRowViewModel

    var body: some View {
        let thread = viewModel.thread
        let post = viewModel.post
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                PostSubject(post.sub)
                HStack(spacing: 4) {
                    let formattedDate = DateHandler.formatPostElement(from: Double(post.time))
                    let indice = thread.posts.firstIndex(of: post)
                    HeaderText("#\(indice ?? 0),")
                    HeaderText("No: \(String(post.no))")
                    HeaderText(formattedDate)
                }
            }
            if let com = post.com {
                CommentView(comment: com).lineLimit(4)
            }
        }
//        .onTapGesture {
//            viewModel.navigateToThread(board: viewModel.thread.boardName, id: thread.id)
//        }
        .padding(7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .scrollContentBackground(.hidden)
        .contextMenu { PostRowContextMenu(viewModel: viewModel) }
    }
}

//#if DEBUG
//struct GalleryPostView_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryPostView(thread: AbstractPostViewModel.preview.thread, postId: AbstractPostViewModel.preview.thread.posts.first!.content.no)
//    }
//}
//#endif
