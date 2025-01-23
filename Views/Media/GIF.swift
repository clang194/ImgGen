import Foundation
import SwiftUI
import UIKit

struct AnimatedImage: UIViewRepresentable {
    let imageName: String

    func makeUIView(context: Self.Context) -> UIImageView {
        let imageView = UIImageView()
        
        guard let asset = NSDataAsset(name: imageName) else {
            return imageView
        }

        guard let imageSource = CGImageSourceCreateWithData(asset.data as CFData, nil) else {
            return imageView
        }

        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(imageSource)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(imageSource, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }

        imageView.image = UIImage.animatedImage(with: images, duration: 0.5 * Double(imageCount))

        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: UIViewRepresentableContext<AnimatedImage>) {
    }
}
