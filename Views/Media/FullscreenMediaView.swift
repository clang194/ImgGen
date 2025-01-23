import SwiftUI

struct FullscreenMediaView: View {
    
    let media: Media?
    let thumbnail: Bool
    
    init(media: Media?, thumbnail: Bool = false) {
        self.media = media
        self.thumbnail = thumbnail
    }
    
    var body: some View {
        if let media = media {
            switch media.detectExtension() {
            case .image:
                AsyncCachedImage(url: media.url!)
                    .resizable()
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: .fit)
                    .contextMenu {
                        ThumbnailContextMenu(url: media.url!)
                    } preview: {
                        AsyncCachedImage(url: media.url!)
                            .resizable()
                            .cornerRadius(7)
                            .scaledToFill()
                    }
            case .webm:
                WebM(media: media)
            case .gif:
                EmptyView()
            case .none:
                EmptyView()
            }
        }
    }
}
