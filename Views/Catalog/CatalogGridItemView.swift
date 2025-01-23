import SwiftUI

struct CatalogGridItemView: View {
    
    @EnvironmentObject var inlineViewModel: InlineViewModel
    @EnvironmentObject var galleryViewModel: GalleryViewModel

    @ObservedObject var viewModel: PostRowViewModel
    
    init(viewModel: PostRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        let board = viewModel.thread.boardName
        let post = viewModel.post
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                if let media = MediaFetcher.getMedia(forPost: post, boardId: board) {
                    ThumbnailView(media: media)
                        .padding(.bottom, 5)
                }
                if post.sub != nil {
                    HStack {
                        Spacer()
                        Text(post.sub!)
                            .font(Font.system(size: 18))
                            .foregroundColor(
                                Color(red: 154/255, green: 185/255, blue: 242/255)
                            )
                        Spacer()
                    }
                    .multilineTextAlignment(.center)
                }
                if let com = post.com {
                    CommentView(comment: com)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
            }
            .onTapGesture {
                viewModel.navigateToThread(board: viewModel.thread.boardName, id: post.no) //rework
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                // .background(.clear)
                    .foregroundColor(Color("Default Scheme/ListElementBackground"))

            )
        }
    }
}

//#if DEBUG
//struct OPGridPostView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { geometry in
//            CatalogGridItemView(thread: AbstractPostViewModel.preview.thread, postId: 253092587)
//                .environmentObject(GalleryViewModel())
//                .environmentObject(InlineViewModel())
//                .environmentObject(AbstractPostViewModel.preview)
//                .frame(width: geometry.size.width/2, height: geometry.size.width/1.6)
//        }
//    }
//}
//#endif
