import SwiftUI

struct GalleryOverlayView: View {

    @EnvironmentObject var galleryViewModel: GalleryViewModel
    //@EnvironmentObject var catalogViewModel: AbstractPostViewModel
    @State var dragOffset: CGFloat = .zero
    let router: Router
    
    var body: some View {
        Group {
            if galleryViewModel.selection != nil {
                GeometryReader { geometry in
                    GallerySwipeableOverlayView(dragOffset: $dragOffset, geometry: geometry, onDismiss: {
                        withAnimation {
                            galleryViewModel.selection = nil
                        }
                    }) {
                        //ZStack {
                        //  Color.clear
                        //    .frame(maxHeight: .infinity)
                        GalleryDetailedView(router: router)
                        //.transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                        //}
                    }
                    //                .transition(.move(edge: .bottom))
                }
                
            }
        }//.transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
    }
}

//#if DEBUG
//struct GalleryOverlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { geometry in
//            GalleryOverlayView()
//                .environmentObject(GalleryViewModel.preview)
//                .environmentObject(AbstractPostViewModel.preview)
//        }
//    }
//}
//#endif
