import SwiftUI

struct GalleryOverlayView: View {

    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @EnvironmentObject var catalogViewModel: AbstractPostViewModel
    @State var dragOffset: CGFloat = .zero
    let geometry: GeometryProxy

    var body: some View {
        if galleryViewModel.presentingGallery {
            SwipeableOverlayView(dragOffset: $dragOffset, geometry: geometry, onDismiss: {
                galleryViewModel.presentingGallery = false
            }) {
                ZStack {
                    Color.clear
                        .frame(maxHeight: .infinity)
                    GalleryDetailedView()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}


struct GallerOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            GalleryOverlayView(geometry: geometry)
                .environmentObject(GalleryViewModel.preview)
                .environmentObject(AbstractPostViewModel.preview)
        }
    }
}

