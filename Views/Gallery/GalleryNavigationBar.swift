import SwiftUI

struct GalleryNavigationBar: View {
    
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    
    var body: some View {
        let posts = galleryViewModel.posts
        let post = galleryViewModel.selection
        if let post = post {
            let mediaIndex = (posts.firstIndex(of: post) ?? 0) + 1
            let mediaCount = posts.count
            HStack {
                ZStack {
                    Button(action: {
                        galleryViewModel.showingImageListSheet = true
                    }, label: {
                        Image(systemName: "list.bullet")
                    })
                    .frame(width: 50, height: 50)
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .padding()
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Spacer()
                ZStack {
                    Text("\(mediaIndex)/\(mediaCount)")
                        .padding(.horizontal, 2)
                        .frame(width: 60, height: 50)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .padding()
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

}
