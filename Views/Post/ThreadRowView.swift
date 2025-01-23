import SwiftUI

struct ThreadRowView: View {
    
    let viewModel: PostRowViewModel
    let synchronousThumbnail: Bool
    
    @EnvironmentObject var inlineViewModel: InlineViewModel
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    
    init(viewModel: PostRowViewModel, synchronousThumbnail: Bool = false) {
        self.viewModel = viewModel
        self.synchronousThumbnail = synchronousThumbnail
    }

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
            //VStack {
                Menu {
                    PostRowContextMenu(viewModel: viewModel)
                } label: {
                    Image(systemName: "ellipsis")
                        .contentShape(Rectangle())
                        .frame(width: 25, height: 25)
                        .padding(.top, -6)
                }
//                Spacer()
//                ShareLink(item: thread.threadUrl) {
//                    Image(systemName: "square.and.arrow.up")
//                        .contentShape(Rectangle())
//                        .frame(width: 25, height: 25)
//                }
            //}
        }
        //.padding(7)
        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(
//            RoundedRectangle(cornerRadius: 10)
//                .foregroundColor(Color("Default Scheme/ListElementBackground"))
//        )
        .scrollContentBackground(.hidden)
        .contextMenu { PostRowContextMenu(viewModel: viewModel) }
    }
}

//#if DEBUG
//struct ThreadPostView_Previews: PreviewProvider {
//    static var previews: some View {
//        ThreadPostView(thread: AbstractPostViewModel.preview.thread, postId: 253092587)
//            .environmentObject(GalleryViewModel())
//            .environmentObject(InlineViewModel())
//            .environmentObject(AbstractPostViewModel.preview)
//    }
//}
//#endif
