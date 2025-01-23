import SwiftUI

struct InlinePostElement: View {

    let viewModel: PostRowViewModel
    
    @EnvironmentObject var inlineViewModel: InlineViewModel
    @EnvironmentObject var galleryViewModel: GalleryViewModel

    var body: some View {
        let thread = viewModel.thread
        let post = viewModel.post
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                PostHeader(viewModel: viewModel)
                if let com = post.com {
                    CommentView(comment: com)
                }
                Spacer()
                ThreadFooter(viewModel: viewModel)
            }
            Spacer()
            VStack {
                Menu {
                    PostRowContextMenu(viewModel: viewModel)
                } label: {
                    Image(systemName: "ellipsis")
                        .contentShape(Rectangle())
                        .frame(width: 25, height: 25)
                }
                Spacer()
                ShareLink(item: thread.threadUrl) {
                    Image(systemName: "square.and.arrow.up")
                        .contentShape(Rectangle())
                        .frame(width: 25, height: 25)
                }
            }
        }
        .padding(7)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .scrollContentBackground(.hidden)
        .contextMenu { PostRowContextMenu(viewModel: viewModel) }
    }
}

/*

#if DEBUG
struct InlinePostView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InlinePostElement(thread: AbstractPostViewModel.preview.thread, postId: AbstractPostViewModel.preview.thread.posts.first!.no, mediaTapGesture: {})
                .environmentObject(GalleryViewModel())
                .environmentObject(InlineViewModel.preview)
                //.environmentObject(AbstractPostViewModel.preview)
            
            ZStack {
                VStack(spacing:0) {
                    Rectangle().fill(.orange.gradient)
                    Rectangle().fill(.blue.gradient)
                    Rectangle().fill(.green.gradient)
                    Rectangle().fill(.pink.gradient)
                }
                
                InlinePostElement(thread: AbstractPostViewModel.preview.thread, postId: AbstractPostViewModel.preview.thread.posts.first!.no)
                    .environmentObject(GalleryViewModel())
                    .environmentObject(InlineViewModel.preview)
                    .environmentObject(AbstractPostViewModel.preview)
                
            }
        }
    }
}
#endif
*/
