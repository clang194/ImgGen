import Foundation

public class PostRowViewModel: ObservableObject {
    let thread: ThreadModel
    let post: Post
    let router: Router

    init(thread: ThreadModel, post: Post, router: Router) {
        self.thread = thread
        self.post = post
        self.router = router
    }
    
    @Published var displaySpoiler: Bool = false
    @Published var isHidden: Bool = false
    
    func getUrl() -> URL { //PostRowViewModel
        let base = "https://boards.4chan.org/\(thread.boardName)/thread/\(post.no)"
        if thread.indexOf(postId: post.no) == 0 {
            return URL(string: base)!
        } else {
            return URL(string: base + "#p\(post.no)")!
        }
    }
    
    @MainActor func navigateToThread(board: String, id: Int) {
        router.navigate(to: .thread(board: board, id: id))
        print("CatalogNavToThread")
    }
}
