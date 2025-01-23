import SwiftUI
import Combine

enum PresentedView {
    case boards, catalog, thread, gallerygrid
}

class GalleryViewModel: ObservableObject {
    @Published var presentingGallery: Bool = false
    @Published var showingDetailedView: Bool = true
    @Published var showingWindowView: Bool = false
    @Published var presentedView: PresentedView = .boards
    @Published var shouldScroll: Bool = false
    @Published var disappearing = PassthroughSubject<Void, Never>()
    @Published var showingImageListSheet: Bool = false
    @Published var qlURL: URL?
    
    @Published var parentThread: ThreadModel = ThreadModel()
    @Published var posts: [Post] = []
    @Published var selection: Post?
    
    var selectionBinding: Binding<Post?> {
        Binding<Post?>(
            get: { self.selection },
            set: { self.selection = $0 }
        )
    }
    
    var selectedIndex: Int {
        return posts.firstIndex(where: { $0 == selection }) ?? 0
    }
    
    @Published var scrollListener = PassthroughSubject<Void, Never>()
    let showingPostIndexSubject = PassthroughSubject<Int, Never>()
    
    func showQL(media: Media) async {
        guard let url = media.url else { return }

        do {
            let localSelection = try await MediaHandler().retrieveImage(from: url)
            DispatchQueue.main.async {
                self.qlURL = localSelection
            }
        } catch {
            print(error)
        }
    }
    
    func showGallery(parentThread: ThreadModel, selection: Post, in posts: [Post]? = nil) {
        if let posts = posts {
            self.posts = posts.filter{$0.containsMedia}
        } else {
            self.posts = parentThread.posts.filter{$0.containsMedia}
        }
        self.parentThread = parentThread
        //withAnimation {
            self.selection = selection
        //}
        self.presentingGallery = true
    }
}
//#if DEBUG
//    static var preview: GalleryViewModel {
//        let galleryViewModel = GalleryViewModel()
//        galleryViewModel.data = AbstractPostViewModel.preview.thread
//        galleryViewModel.presentingGallery = true
//        return galleryViewModel
//    }
//#endif
//}
