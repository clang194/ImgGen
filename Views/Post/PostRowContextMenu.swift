import SwiftUI
import Combine

//struct PostContextMenu<T: View>: View {
    
struct PostRowContextMenu: View {
    let viewModel: PostRowViewModel
    //let view: T
    @EnvironmentObject var appState: AppStateManager
    
    @State private var isThreadSaved: Bool = false
    //private var cancellable: AnyCancellable?
    
//    init(thread: ThreadModel, postId: Int, view: T) {
//        self.thread = thread
//        self.postId = postId
//        self.view = view
//    }
    
    var isOp: Bool {
        return (viewModel.thread.getPost(from: viewModel.post.no)?.resto == 0)
    }
    
    var body: some View {
        let postUrl = viewModel.getUrl()
        
        Button(action: {
            if let com = viewModel.thread.getPost(from: viewModel.post.no)?.com {
                appState.textSheetComment = com
            }
            appState.showingTextSheet = true
        }) {
            HStack {
                Text("Select Text")
                Spacer()
                Image(systemName: "selection.pin.in.out")
            }
        }
        
        Divider()
        
        Menu("Share") {
            ShareLink(item: postUrl,
                      subject: Text(viewModel.post.sub ?? String(viewModel.post.no)),
                      message: Text(viewModel.post.com ?? "")
            ) {
                Label("Share this post", systemImage: "note.text")
            }
            
            ShareLink(item: postUrl)
            {
                Label("Share this link", systemImage: "link")
            }
        }
        
        Button { UIApplication.shared.open(postUrl) } label: {
            Label("Open in Browser", systemImage: "safari")
        }
        
        Button {
            UIPasteboard.general.string = viewModel.post.com
        } label: {
          Label("Copy text", systemImage: "doc.on.doc")
        }

        Button {
            UIPasteboard.general.string = postUrl.absoluteString
        } label: {
          Label("Copy link", systemImage: "link")
        }
        
        Button {
            appState.infoSheetViewModel = viewModel
            appState.showingInfoSheet = true
        } label: {
            Label("Show info", systemImage: "info")
        }
//        if (thread.id == postId) || isOp {
//            Button(action: {
//                if !isThreadSaved {
//                    ThreadSavedManager.shared.addThreadToSaved(thread.posts, withId: postId, forBoard: thread.boardName)
//                } else {
//                    ThreadSavedManager.shared.removeThreadFromSaved(withId: thread.id, forBoard: thread.boardName)
//                }
//                isThreadSaved = ThreadSavedManager.shared.isThreadSaved(withId: postId, forBoard: thread.boardName)
//            }) {
//                HStack {
//                    Text(isThreadSaved ? "Remove from Bookmarks" : "Add to Bookmarks")
//                    Spacer()
//                    Image(systemName: isThreadSaved ? "bookmark.slash.fill" : "bookmark")
//                }
//            }
//            .onReceive(ThreadSavedManager.shared.savedStateChange) { _ in
//                isThreadSaved = ThreadSavedManager.shared.isThreadSaved(withId: postId, forBoard: thread.boardName)
//            }
//            .onAppear {
//                isThreadSaved = ThreadSavedManager.shared.isThreadSaved(withId: postId, forBoard: thread.boardName)
//            }
//        }
//        
//        Button(action: {
//            MediaHandler.shared.renderViewAndSave(view: view) { status in
//                switch status {
//                case .success:
//                    print("show succss toast")
//                case .failure(let error):
//                    print("show failure \(error)")
//                }
//            }
//        }) {
//            HStack {
//                Text("Save Post to Photos")
//                Spacer()
//                Image(systemName: "photo.on.rectangle")
//            }
//        }
//        
//        Button(action: {
//            if let com = thread.getPost(fromId: postId)?.content.com {
//                appState.textSheetComment = com
//            }
//            appState.showingTextSheet = true
//        }) {
//            HStack {
//                Text("Select Text")
//                Spacer()
//                Image(systemName: "selection.pin.in.out")
//            }
//        }
    }
}

//#if DEBUG
//struct PostContextMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        let thread = AbstractPostViewModel.preview.thread
//        Text("Test").contextMenu {
//            PostContextMenu(
//                thread: thread,
//                postId: thread.op.content.no,
//                view: Text("Hello")
//            )
//        }
//    }
//}
//#endif
