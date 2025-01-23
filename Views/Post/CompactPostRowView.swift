import SwiftUI

struct CompactPostRowView: View {
    
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
        HStack(spacing: 10) {
            if let op = thread.op, let media = MediaFetcher.getMedia(forPost: op, boardId: thread.boardName) {
                //FullscreenMediaView(media: media, thumbnail: true)
                ThumbnailView(media: media)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
//                    .frame(maxHeight: 30)
                    .padding(.trailing, 10)
            }
                VStack(alignment: .leading, spacing: -6) {
                    HStack {
                        TagElement(text: "/\(thread.boardName)/", backgroundColor: Color.gray)
                        if let sub = thread.op?.sub {
                            Text(sub)
                                .font(Font.system(size: 15, weight: .bold))
                                .lineLimit(1)
                        }
                    }
                    if let com = thread.op?.com {
                        CommentView(comment: com)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    //Spacer()
                    //HeaderText("Last visited at \(DateHandler.formatHistoryElement(from: thread.lastOpened))")
                }.frame(maxHeight: 75)
            Spacer()
        }
        .onTapGesture {
            viewModel.navigateToThread(board: thread.boardName, id: thread.id) //rework
        }
    }
}

//#Preview {
//    CompactPostRowView()
//}
