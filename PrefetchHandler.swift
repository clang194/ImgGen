import Kingfisher
import Foundation

class ImagePrefetchHandler {
    static var imagePrefetcher = ImagePrefetcher(urls: [])

    private init() {}  // Prevents instantiation

    /*static func prefetch(urls: [URL]) {
        var urls = urls
        let pivot = urls.partition(by: { MediaHandler.detectExtension(url: $0) == .image })
        let imageUrls = urls[..<pivot]
        prefetchImages(urls: Array(imageUrls))
    }*/

    static func prefetchImages(urls: [URL], completion: @escaping () -> Void) {
        imagePrefetcher = ImagePrefetcher(urls: urls) {
            _, _, completedResources in
            print("These resources are prefetched: \(completedResources)")
            completion()
        }
        imagePrefetcher.start()
    }

    static func stopPrefetching() {
        imagePrefetcher.stop()
    }
}
