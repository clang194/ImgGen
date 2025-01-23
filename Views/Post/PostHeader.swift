import SwiftUI

struct PostHeader: View {
    
    @EnvironmentObject var galleryViewModel: GalleryViewModel

    @State var showingSpoiler: Bool
    
    let viewModel: PostRowViewModel
    
    init(viewModel: PostRowViewModel) {
        self.viewModel = viewModel
        self.showingSpoiler = viewModel.post.containsSpoiler
    }
    
    var body: some View {
        let board = viewModel.thread.boardName
        let thread = viewModel.thread
        let post = viewModel.post
        let synchronousThumbnail = false //todo
        let formattedDate = DateHandler.formatPostElement(from: Double(post.time))
        let cornerRadius = CGFloat(7)
        HStack(alignment: .top) {
            if let media = MediaFetcher.getMedia(forPost: post, boardId: board) {
                ZStack {
                    ThumbnailView(media: media, synchronous: synchronousThumbnail)
                        .onTapGesture {
                            withAnimation {
                                galleryViewModel.showGallery(parentThread: thread, selection: post, in: thread.posts)
                            }
                        }
                    if showingSpoiler { //todo make modifier
                        Button(action: {
                            withAnimation {
                                showingSpoiler = false
                            }
                        }) {
                            Text("Spoiler")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.ultraThinMaterial)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 3, x: 1, y: 1)
                        }
                    }
                } //todo rework this
                .cornerRadius(cornerRadius)
                .frame(width: UIScreen.main.bounds.width * 0.17, height: UIScreen.main.bounds.width * 0.17)
            }
            VStack(alignment: .leading) {
                PostSubject(post.sub)
                HStack(spacing: 4) {
                    //HeaderText("#\(indice ?? 0),") //todo
                    HeaderText("No: \(post.no)")
                    HeaderText(formattedDate)
                    if let country = post.country {
                        HeaderText(flag(country: country))
                    }
                    if post.sticky == 1 {
                        HeaderText("📌")
                    }
                    if post.closed == 1 {
                        HeaderText("🔒")
                    }
                }
                if let filename = post.filename, let ext = post.ext {
                    HStack(spacing: 4) {
                        HeaderText("\(filename)\(ext)").underline().lineLimit(1)
                    }
                }
                if let ext = post.ext, let fsize = post.fsize, let h = post.h, let w = post.w {
                    HStack(spacing: 4) {
                        HeaderText(String(ext.uppercased().dropFirst()))
                        HeaderText(String(fsize/1000) + " KiB")
                        HeaderText("\(w)x\(h)")
                    }
                }
            }
        }
        
    }
}

//#if DEBUG
//struct PostHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        PostHeader(post: AbstractPostViewModel.preview.thread.posts[0], indice: 0)
//    }
//}
//#endif
