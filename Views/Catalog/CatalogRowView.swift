import SwiftUI

struct HeaderText: View {
    let text: String

    init(_ text: String) {
            self.text = text
        }

    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(Color.gray)
    }
}

struct CatalogRowView: View {
    
    @State private var showingPopover = false
    
    @EnvironmentObject var inlineViewModel: InlineViewModel
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @ObservedObject var viewModel: PostRowViewModel
    @EnvironmentObject var router: Router
 
    init(viewModel: PostRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        let thread = viewModel.thread
        let post = viewModel.post
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                PostHeader(viewModel: viewModel)
                    .onTapGesture {
                        router.navigate(to: .thread(board: thread.boardName, id: post.no))
                        //viewModel.navigateToThread(board: thread.boardName, id: post.no)
                    }
                if let com = post.com {
                    CommentView(comment: com)
                        .multilineTextAlignment(.leading)
                        .lineLimit(15)
                        .onTapGesture {
                            print("before CRV navigate!: \(viewModel.router.navPath)")
                            router.navigate(to: .thread(board: thread.boardName, id: post.no))
                            //viewModel.navigateToThread(board: thread.boardName, id: post.no) //fix id
                        }
                }
                Spacer()
                CatalogFooter(viewModel: viewModel)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("Default Scheme/ListElementBackground"))
                .onTapGesture {
                    router.navigate(to: .thread(board: thread.boardName, id: post.no))
                    //viewModel.navigateToThread(board: thread.boardName, id: post.no)//fix id
                }
        )
        .contextMenu {
            PostRowContextMenu(viewModel: viewModel)
        }
        .scrollContentBackground(.hidden)
    }
}

func flag(country: String) -> String {
    let base: UInt32 = 127397
    var s = ""
    for v in country.unicodeScalars {
        s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
}

//#if DEBUG
//struct OPListPostView_Previews: PreviewProvider {
//    static var previews: some View {
//        CatalogRowView(thread: AbstractPostViewModel.preview.thread, postId: AbstractPostViewModel.preview.thread.posts.first!.content.no)
//            .environmentObject(GalleryViewModel())
//            .environmentObject(InlineViewModel())
//            .environmentObject(AbstractPostViewModel.preview)
//    }
//}
//#endif
