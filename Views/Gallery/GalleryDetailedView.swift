import SwiftUI

struct GalleryDetailedView: View {
    
    //@EnvironmentObject var catalogViewModel: AbstractPostViewModel
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let router: Router
    
    var body: some View {
        let thread = galleryViewModel.parentThread
        let posts = galleryViewModel.posts
        //GeometryReader { _ in
            ZStack {
                //HStack(alignment: .center) {
                    //if (galleryViewModel.selection != nil) {
                        GalleryView() { media in
                            FullscreenMediaView(media: media)
                            //.transition(.move(edge: .bottom))
                        }
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                    //}
//                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                    //.animation(.easeInOut)
                //}
//                .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
//                .animation(.easeIn, value: galleryViewModel.selection)
                if galleryViewModel.showingDetailedView {
                    if let post = galleryViewModel.selection {
                        VStack {
                            GalleryNavigationBar()
                            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
                            Spacer()
                            GalleryPostView(viewModel: PostRowViewModel(thread: thread, post: post, router: router))
                                .padding(.leading, 15)
                                .padding(.trailing, 15)
                                .onTapGesture {
                                    var transaction = Transaction()
                                    transaction.disablesAnimations = true
                                    withTransaction(transaction) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                            
                        }
                    }
                }
            }
            .onAppear {
                galleryViewModel.showingDetailedView = true
            }
        //}
    }
}

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}

    /*
#if DEBUG
struct GalleryDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryDetailedView()
            .environmentObject(GalleryViewModel.preview)
            .environmentObject(AbstractPostViewModel.preview)
    }
}
#endif
*/
