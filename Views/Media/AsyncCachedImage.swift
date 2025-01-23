import SwiftUI

enum ImageState {
    case loading
    case failure
    case success(UIImage)
}

enum CacheMode {
    case none
    case disk
    case memory
}

class ImageViewModel: ObservableObject {
    @Published var imageState: ImageState = .loading

    let url: URL
    var cacheMode: CacheMode = .none
    var progressView: () -> ProgressView = { ProgressView() }

    init(url: URL) {
        self.url = url
    }

    @MainActor
    func fetchImage() async {
        do {
            let localUrl = try await MediaHandler.shared.retrieveImage(from: url, cacheImage: true)
            
            if let data = try? Data(contentsOf: localUrl),
               let image = UIImage(data: data) {
                self.imageState = .success(image)
            } else {
                self.imageState = .failure
            }
        } catch {
            self.imageState = .failure
        }
    }

}

struct AsyncCachedImage: View {
    @StateObject var viewModel: ImageViewModel

    private var imageModifiers: (Image) -> Image = { $0 }

    init(url: URL) {
        _viewModel = StateObject(wrappedValue: ImageViewModel(url: url))
    }

    var body: some View {
        Group {
            switch viewModel.imageState {
            case .loading:
                viewModel.progressView()
            case .failure:
                Text("Image loading failed!")
            case .success(let uiImage):
                imageModifiers(Image(uiImage: uiImage))
            }
        }
        .task {
            await viewModel.fetchImage()
        }
    }

    func cache(cache: CacheMode) {
        viewModel.cacheMode = cache
    }

    func resizable(capInsets: EdgeInsets = EdgeInsets(), resizingMode: Image.ResizingMode = .stretch) -> AsyncCachedImage {
        configure { $0.resizable(capInsets: capInsets, resizingMode: resizingMode) }
    }

    func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> AsyncCachedImage {
        configure { $0.renderingMode(renderingMode) }
    }

    func interpolation(_ interpolation: Image.Interpolation) -> AsyncCachedImage {
        configure { $0.interpolation(interpolation) }
    }

    func antialiased(_ isAntialiased: Bool) -> AsyncCachedImage {
        configure { $0.antialiased(isAntialiased) }
    }

    func scaledToFill(_ scaledToFit: Bool) -> AsyncCachedImage {
        configure { $0.scaledToFill() as! Image }
    }

    private func configure(_ modifier: @escaping (Image) -> Image) -> AsyncCachedImage {
        var result = self
        result.imageModifiers = { image in
            modifier(self.imageModifiers(image))
        }
        return result
    }
}
//
//struct CustomImage_Previews: PreviewProvider {
//    static var previews: some View {
//        AsyncCachedImage(url: URL(string: "https://i.4cdn.org/pol/1493993226750s.jpg")!)
//    }
//}
