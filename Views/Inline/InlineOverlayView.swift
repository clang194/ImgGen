import SwiftUI

struct InlineOverlayView: View {

    @EnvironmentObject var inlineViewModel: InlineViewModel
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @State var dragOffset: CGFloat = .zero
    
    let router: Router

    var body: some View {
        GeometryReader { geometry in
            if inlineViewModel.isShowing {
                SwipeableOverlayView(dragOffset: $dragOffset, geometry: geometry, onDismiss: inlineViewModel.removeLastThread, onBackgroundTap: inlineViewModel.removeLastThread, backgroundOpacity: 0.75) {
                    ZStack {
                        Color.clear
                            .frame(maxHeight: .infinity)
                        InlineView(router: router)
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    galleryViewModel.showingWindowView = true
                }
                .onDisappear {
                    galleryViewModel.showingWindowView = false
                }
            }
        }
    }
}

//#if DEBUG
//struct InlineOverlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { geometry in
//            InlineOverlayView()
//                .environmentObject(GalleryViewModel())
//                .environmentObject(InlineViewModel.preview)
//        }
//    }
//}
//#endif
