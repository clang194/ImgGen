import SwiftUI

enum MediaTypes {
    case image, webm, gif, none
}

struct ThumbnailView: View {

    let media: Media
    let loadFull: Bool
    //let cornerRadius: CGFloat
    let synchronous: Bool

    init(media: Media, loadFull: Bool = false, synchronous: Bool = false) {
        self.media = media
        self.loadFull = loadFull
        self.synchronous = synchronous
        //self.cornerRadius = cornerRadius
    }

    var body: some View {
        let url = media.url
        let thumbnailUrl = media.thumbnailUrl
        GeometryReader { geometry in
            let mediaType = detectExtension(url: url)
            switch mediaType {
            case .image:
                if let url = url, let thumbnailUrl = thumbnailUrl {
                    if synchronous {
                        CachedImage(url: loadFull ? url : thumbnailUrl)
                            .resizable()
                            .scaledToFill()
                            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                            //.cornerRadius(cornerRadius)
                            .contextMenu {
                                ThumbnailContextMenu(url: url)
                            } preview: {
                                CachedImage(url: url)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(7)
                            }
                    } else {
                        AsyncCachedImage(url: loadFull ? url : thumbnailUrl)
                            .resizable()
                            .scaledToFill()
                            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                            //.cornerRadius(cornerRadius)
                            .contextMenu {
                                ThumbnailContextMenu(url: url)
                            } preview: {
                                AsyncCachedImage(url: url)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(7)
                            }
                    }

                } else {

                }
            default:
                ProgressView().frame(width: 75, height: 75)
            }
        }
    }
}

func detectExtension(url: URL?) -> MediaTypes {
    guard let urlString = url?.absoluteString else {
        return .none
    }

    if  urlString.hasSuffix(".jpeg") ||
        urlString.hasSuffix(".jpg") ||
        urlString.hasSuffix(".png") {
        return .image
    } else if urlString.hasSuffix(".webm") {
        return .webm
    } else if urlString.hasSuffix(".gif") {
        return .gif
    } else {
        return .none
    }
}


/*
struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        let media = AbstractPostViewModel.preview.media.first
        if let media = media {
            ThumbnailView(media: media)
        } else {
            Text("Nil media")
        }
    }
}*/
