import Foundation
import UIKit

class ImagePrefetcher {
    private var urls: [URL]
    private var mediaHandler: MediaHandler
    private var completion: (() -> Void)?

    init(urls: [URL]) {
        self.urls = urls
        self.mediaHandler = MediaHandler.shared
    }

    func start(completion: @escaping () -> Void) async {
        self.completion = completion
        await prefetchNext()
    }

    private func prefetchNext() async {
        while let url = urls.popLast() {
            do {
                let _ = try await mediaHandler.retrieveImage(from: url, cacheImage: true)
            } catch {
                AppLogger.error("Failed to prefetch image from \(url): \(error)")
                continue
            }
        }
        print("No more URLs to prefetch")
    }


    func stop() {
        // Clear the URL array to stop prefetching.
        urls.removeAll()
    }
}
