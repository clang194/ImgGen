import SwiftUI

struct GalleryGridView: View {

    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @EnvironmentObject var appStateManager: AppStateManager
    
    @State var lastIndex = 0
    @State var dragOffset: CGFloat = .zero
    @State var showingSaveAlert: Bool = false
    @State var highlightedIndex: Int? = nil
    
    let media: [Media]

    var body: some View {
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
        GeometryReader { geometry in
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(Array(media.enumerated()), id: \.offset) { index, mediaElement in
                            ThumbnailView(media: mediaElement, loadFull: true)
                                .aspectRatio(1, contentMode: .fill)
//                                .onTapGesture {
//                                    galleryViewModel.showGallery(parentThread: thread, showingPostId: thread.getPostId(fromMedia: media) ?? 0)
//                                } reimplement
                                .border((highlightedIndex == index) ? Color.yellow.opacity(0.5) : Color.clear, width: (highlightedIndex == index) ? 6 : 0)
                                    .animation(.easeInOut(duration: 1), value: highlightedIndex)
                        }
                    }
                    .padding(.horizontal)
                }
//                .onReceive(galleryViewModel.objectWillChange) {
//                    if (lastIndex != galleryViewModel.showingMediaIndex) && (appStateManager.activeView == .gallerygrid) {
//                        withAnimation {
//                            scrollView.scrollTo(galleryViewModel.showingMediaIndex, anchor: .center)
//                        }
//                        lastIndex = galleryViewModel.showingMediaIndex
//                    }
//                }
//                .onReceive(galleryViewModel.scrollListener) {
//                    if appStateManager.activeView == .gallerygrid {
//                        if let showingPostIndex  = thread.postIdToIndex[galleryViewModel.showingPostId] {
//                            withAnimation {
//                                scrollView.scrollTo(showingPostIndex, anchor: .center)
//                            }
//                            highlightedIndex = showingPostIndex
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                withAnimation {
//                                    highlightedIndex = nil
//                                }
//                            }
//                        }
//                    }
//                } reimplement
                .onAppear {
                    appStateManager.activeView = .gallerygrid
                    //catalogViewModel.prefetch(thumbnail: true)
                }
//                .overlay {
//                    if galleryViewModel.presentingGallery {
//                        SwipeableOverlayView(dragOffset: $dragOffset, geometry: geometry, onDismiss: {
//                            galleryViewModel.presentingGallery = false
//                        }) {
//                            GalleryDetailedView()
//                        }.edgesIgnoringSafeArea(.all)
//                    }
//                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingSaveAlert.toggle()
                }) {
                    Image(systemName: "square.and.arrow.down.on.square")
                }
            }
        }
        .alert(isPresented: $showingSaveAlert) {
            Alert(
                title: Text("Save all images"),
                message: Text("Are you sure you want to save all \(media.count) images?"),
                primaryButton: .default(
                    Text("Cancel"),
                    action: {}
                ),
                secondaryButton: .default(
                    Text("Save"),
                    action: {}
                )
            )
        }
    }
}
//
//#if DEBUG
//struct GalleryGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            GalleryGridView(thread: AbstractPostViewModel.preview.thread, mediaArray: AbstractPostViewModel.preview.media)
//                .environmentObject(AppStateManager())
//                .environmentObject(GalleryViewModel.preview)
//                .environmentObject(AbstractPostViewModel.preview)
//            
//            NavigationView {
//                GalleryGridView(thread: AbstractPostViewModel.preview.thread, mediaArray: AbstractPostViewModel.preview.media)
//                    .environmentObject(AppStateManager())
//                    .environmentObject(GalleryViewModel.preview)
//                    .environmentObject(AbstractPostViewModel.preview)
//            }.previewDisplayName("with Navigation")
//        }
//    }
//}
//#endif
