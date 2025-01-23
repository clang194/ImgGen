import Photos
import UIKit

class PhotoLibraryHandler {
    func requestPhotoAccess() async -> PHAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            let currentStatus = PHPhotoLibrary.authorizationStatus()

            if currentStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    continuation.resume(returning: status)
                }
            } else {
                continuation.resume(returning: currentStatus)
            }
        }
    }

    func saveImageToPhotosLibrary(image: UIImage) async throws -> ImageSaveStatus {
        do {
            try await PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            })
            return .success
        } catch {
            throw ImageSaveError.saveError
        }
    }
}
