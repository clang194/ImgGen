import SwiftUI

struct GalleryImageList: View {
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    var body: some View {
        let thread = galleryViewModel.parentThread
        let posts = galleryViewModel.posts
        List {
            ForEach(posts.indices, id: \.self) { index in
                let post = posts[index]
                //HStack {
                if let media = MediaFetcher.getMedia(forPost: post, boardId: thread.boardName), let filename = post.filename, var ext = post.ext, let fsize = post.fsize {
                    HStack {
                        FullscreenMediaView(media: media)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 40, maxHeight: 40)
                            .padding(.trailing, 10)
                        
                        VStack(alignment: .leading) {
                            Text(filename)
                            Text("\(ext.uppercased()) image - \(fsize) bytes")
                                .foregroundStyle(.gray)
                                .font(.footnote)
                        }
                        .lineLimit(1)
                        Spacer()
                        if index == galleryViewModel.selectedIndex {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .foregroundStyle(.green)
                                .frame(width: 12, height: 12)
                        }
                    }
                    .onTapGesture {
                        galleryViewModel.selection = post
                        galleryViewModel.showingImageListSheet = false
                    }
                }
            }
        }
    }
}

#Preview {
    GalleryImageList()
}
