import Foundation
import SwiftUI
import UIKit
import Photos

enum PhotosAccessPerm: Int {
    case authorized, denied, restricted, notDetermined

    init(from status: PHAuthorizationStatus) {
        switch status {
        case .authorized: self = .authorized
        case .denied: self = .denied
        case .restricted: self = .restricted
        case .notDetermined: self = .notDetermined
        default: self = .notDetermined
        }
    }
}

enum ImageSaveStatus {
    case success
    case failure(ImageSaveError)
}

enum ImageSaveError: Error {
    case downloadError
    case saveError
    case accessNotGranted
}

enum ImageDownloadStatus {
    case succcess(Data), failed
}

class MediaHandler: ObservableObject {
    let maxRetryCount = 3
    private var tasks: [URL: URLSessionDataTask] = [:]

    static let shared = MediaHandler()
    private var cacheManger: CacheManager = CacheManager()
    private var photoLibraryService: PhotoLibraryHandler = PhotoLibraryHandler()
    
    private var photosAuthorized: PhotosAccessPerm? {
        get {
            return UserSettings.shared.photosAuthorized
        }
        set {
            UserSettings.shared.photosAuthorized = newValue ?? .notDetermined
        }
    }

    private func requestPhotoAccess(completion: @escaping (PHAuthorizationStatus) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                completion(status)
            }
        } else {
            completion(PHPhotoLibrary.authorizationStatus())
        }
    }

    func retrieveImage(from url: URL, cacheImage: Bool = true) async throws -> URL {
        if self.cacheManger.isCached(url: url) {
            return try self.cacheManger.localUrl(for: url)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        if cacheImage {
            try self.cacheManger.store(data: data, for: url)
        }
        let localUrl = try self.cacheManger.localUrl(for: url)
        return localUrl
    }
    
    func retrieveImageSync(from url: URL) -> UIImage? {
        do {
            if let data = try self.cacheManger.retrieveData(for: url) {
                return UIImage(data: data)
            }
        } catch {
            AppLogger.error("Failed to retrieve data for url: \(url). Error: \(error)")
        }
        return nil
    }
    
    func cancel(url: URL) {
        tasks[url]?.cancel()
        tasks.removeValue(forKey: url)
    }

    func cancelAll() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    func downloadImageData(from url: URL, completion: @escaping (ImageDownloadStatus) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if error != nil {
                completion(.failed)
            } else if let data = data {
                completion(.succcess(data))
            }
        }
        task.resume()
    }
    
    func saveImage(_ imageURL: URL, fromCache: Bool = true, retryCount: Int = 0) async { //saveImageFromURL
        if fromCache {
            await self.saveImageFromCache(imageURL: imageURL)
        } else {
            await self.saveImageFromUrl(imageURL: imageURL, retryCount: retryCount)
        }
    }
    
    private func saveImageFromUrl(imageURL: URL, retryCount: Int) async {
        do {
            let localURL = try await retrieveImage(from: imageURL, cacheImage: true)
            let image = try imageFromLocalURL(localURL)
            do {
                try await _saveImage(image)
            } catch {
                AppLogger.error("Failed to save image from URL")
            }
        } catch {
            if retryCount < maxRetryCount {
                AppLogger.info("Retrying download...")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await saveImageFromUrl(imageURL: imageURL, retryCount: retryCount + 1)
            } else {
                AppLogger.error("Failed to download and save image. Error: \(error)")
            }
        }
    }

    private func saveImageFromCache(imageURL: URL, retryCount: Int = 0) async {
        if let data = try? self.cacheManger.retrieveData(for: imageURL),
           let image = UIImage(data: data) {
            do {
               try await _saveImage(image)
            } catch {
                print("Failed to save image from cache")
            }
        } else {
            await saveImage(imageURL, retryCount: retryCount)
        }
    }

    
    @MainActor func renderViewAndSave<T: View>(view: T) async throws {
        let renderer = ImageRenderer(content: view)
        let screenWidth = UIScreen.main.bounds.width
        renderer.proposedSize = .init(width: screenWidth, height: .infinity)
        renderer.scale = UIScreen.main.scale
        //renderer.isOpaque = true
        if let image = renderer.uiImage {
            try await _saveImage(image)
        }
    }
        
//        let controller = UIHostingController(rootView: view)
//
//        // Load view hierarchy
//        let targetSize = controller.view.intrinsicContentSize
//        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
//        controller.view.addSubview(UIView())
//        controller.view.layoutIfNeeded()
//
//        let renderer = UIGraphicsImageRenderer(size: targetSize)
//        let image = renderer.image { _ in
//            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
//        }
//        saveImage(image, completion: completion)
//    }
    
    @MainActor
    private func _saveImage(_ image: UIImage) async throws {
        let photoLibraryService = PhotoLibraryHandler()
        let toastViewModel = ToastViewModel.shared
        toastViewModel.toastState = .saving
        do {
            let status = await photoLibraryService.requestPhotoAccess()
            switch status {
            case .authorized:
                _ = try await photoLibraryService.saveImageToPhotosLibrary(image: image)
                toastViewModel.toastState = .saved
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    toastViewModel.toastState = .none
                }
            default:
                throw ImageSaveError.accessNotGranted
            }
        } catch {
            toastViewModel.toastState = .error
            print("Toast state changed")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                toastViewModel.toastState = .none
            }
            throw error
        }
    }


    private func imageFromLocalURL(_ url: URL) throws -> UIImage {
        let pathString = url.path
        guard let image = UIImage(contentsOfFile: pathString) else {
            throw ImageSaveError.downloadError
        }
        return image
    }
}
