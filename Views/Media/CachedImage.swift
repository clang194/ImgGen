import SwiftUI

struct CachedImage: View {

    private var imageModifiers: (Image) -> Image = { $0 }

    let url: URL
    
    public init(url: URL) {
        self.url = url
    }

    var body: some View {
        Group {
            if let uiImage = MediaHandler.shared.retrieveImageSync(from: url) {
                Image(uiImage: uiImage)
            } else {
                Image(systemName: "x.circle")
            }
        }
    }

    func resizable(capInsets: EdgeInsets = EdgeInsets(), resizingMode: Image.ResizingMode = .stretch) -> CachedImage {
        configure { $0.resizable(capInsets: capInsets, resizingMode: resizingMode) }
    }

    func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> CachedImage {
        configure { $0.renderingMode(renderingMode) }
    }

    func interpolation(_ interpolation: Image.Interpolation) -> CachedImage {
        configure { $0.interpolation(interpolation) }
    }

    func antialiased(_ isAntialiased: Bool) -> CachedImage {
        configure { $0.antialiased(isAntialiased) }
    }

    func scaledToFill(_ scaledToFit: Bool) -> CachedImage {
        configure { $0.scaledToFit() as! Image }
    }

    private func configure(_ modifier: @escaping (Image) -> Image) -> CachedImage {
        var result = self
        result.imageModifiers = { image in
            modifier(self.imageModifiers(image))
        }
        return result
    }
}

struct CachedImage_Preview: PreviewProvider {
    static var previews: some View {
        CachedImage(url: URL(string: "https://i.4cdn.org/pol/1493993226750s.jpg")!)
    }
}
