import SwiftUI

struct GalleryView<CustomImage: View>: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    let content: (Media?) -> CustomImage

    @State private var translation: CGSize = .zero
    @State private var lastTranslation: CGSize = .zero
    @State private var showingActionSheet = false
    @State private var showShareSheet = false
    @State private var itemToShare: UIImage?
    @State private var hapticPerformed = false

    @State private var initialIndex = 0 // does it need to be state
    @State private var lastIndex = 0 // does it nee
    @State private var lastShowingDetailed = false
    @State private var isGestureActive = false

    @State private var dragUpIntensity: CGFloat = .zero
    @State private var dragDownIntensity: CGFloat = .zero
    @State private var shouldCloseView: Bool = false
    @State private var shouldSaveImage: Bool = false
    @State private var dragDirection: DragDirection?

    enum DragDirection {
        case horizontal
        case vertical
    }

    @State private var swipeDisabled: Bool = false
    
    @State var showingMediaIndex: Int = 0
    @State private var scrollID: Int?
    
    let indexOffset = 0
    
    init(@ViewBuilder content: @escaping (Media?) -> CustomImage) {
        self.content = content
    }

    var body: some View {
        let thread = galleryViewModel.parentThread
        let posts = galleryViewModel.posts
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(posts.indices, id: \.self) { index in
                            let post = posts[index]
                            ZoomableScrollView {
                                let media = MediaFetcher.getMedia(forPost: post, boardId: thread.boardName)
                                self.content(media)
                            }
                            .frame(width: geometry.size.width)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrollID)

            if dragDownIntensity > 0 {
                SwipeGauge(intensity: dragDownIntensity, icon: "square.and.arrow.down")
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }

            if dragUpIntensity > 0 {
                SwipeGauge(intensity: dragUpIntensity, icon: "xmark")
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
                
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            if dragDirection == nil {
                                // Determine the drag direction on the initial movement
                                dragDirection = abs(value.translation.width) > abs(value.translation.height) ? .horizontal : .vertical
                            }
                        }
                        .onEnded { _ in
                            dragDirection = nil
                        }
                )
                .simultaneousGesture(
                    gallerySingleTapGesture()
                )
        }

        }
        .onAppear {
            refreshScroll()
            initialIndex = showingMediaIndex
            galleryViewModel.shouldScroll = false
        }
        
        .onChange(of: galleryViewModel.selection) {
            refreshScroll()
        }
        
        .onChange(of: scrollID) {
            showingMediaIndex = scrollID ?? 0
            galleryViewModel.selection = posts[showingMediaIndex]
        }
        
        .onReceive(galleryViewModel.disappearing) {
            if showingMediaIndex != initialIndex {
                galleryViewModel.scrollListener.send()
            }
        }
        .clipped()
    }

    func closeGalleryView() {
        galleryViewModel.presentingGallery = false
    }

    func saveGalleryImage() async {
        if let post = galleryViewModel.selection, let mediaUrl = MediaFetcher.getMediaUrl(forPost: post, boardId: galleryViewModel.parentThread.boardName) {
            await MediaHandler.shared.saveImage(mediaUrl)
        }
    }

    func refreshScroll() {
        if let selection = galleryViewModel.selection {
            showingMediaIndex = galleryViewModel.posts.firstIndex(of: selection) ?? 0
            withoutAnimation {
                scrollID = showingMediaIndex
            }
        }
    }
    
    func gallerySingleTapGesture() -> some Gesture {
        TapGesture(count: 2).exclusively(before:
            TapGesture(count: 1)
                .onEnded {
                    galleryViewModel.showingDetailedView.toggle()
                }
        )
    }

//    func imageActionsGesture(geometry: GeometryProxy) -> some Gesture {
//        DragGesture()
//            .onChanged { value in
//                let translation = value.location.y - value.startLocation.y
//                if dragDirection == .vertical {
//                    let threshold = geometry.size.height
//                    if value.translation.height > 0 {
//                        self.dragUpIntensity = 0
//                        self.dragDownIntensity = min(abs(value.translation.height/threshold)*4, 1)
//                        print(value.translation.height)
//                    } else {
//                        self.dragDownIntensity = 0
//                        self.dragUpIntensity = min((abs(value.translation.height)/threshold)*4, 1)
//                    }
//                    if (self.dragUpIntensity == 1 || self.dragDownIntensity == 1) && self.hapticPerformed == false {
//                        let generator = UIImpactFeedbackGenerator(style: .medium)
//                        generator.impactOccurred()
//                        self.hapticPerformed = true
//                    }
//                }
//            }
//            .onEnded { _ in
//                if dragDirection == .vertical {
//                    if self.dragUpIntensity == 1 {
//                        closeGalleryView()
//                    }
//
//                    if self.dragDownIntensity == 1 {
//                        saveGalleryImage()
//                    }
//                    self.hapticPerformed = false
//                    self.dragUpIntensity = 0
//                    self.dragDownIntensity = 0
//                }
//            }
//
//    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
  private var content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  func makeUIView(context: Context) -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.delegate = context.coordinator
    scrollView.maximumZoomScale = 20
    scrollView.minimumZoomScale = 1
    scrollView.bouncesZoom = true
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
          //scrollView.backgroundColor = UIColor.white

    let hostedView = context.coordinator.hostingController.view!
    //hostedView.translatesAutoresizingMaskIntoConstraints = true
    hostedView.backgroundColor = UIColor.clear
    hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostedView.frame = scrollView.bounds
    scrollView.addSubview(hostedView)

  let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
      doubleTapGesture.numberOfTapsRequired = 2
      scrollView.addGestureRecognizer(doubleTapGesture)

    return scrollView
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(hostingController: UIHostingController(rootView: self.content))
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    context.coordinator.hostingController.rootView = self.content
    assert(context.coordinator.hostingController.view.superview == uiView)
  }

  class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>

        init(hostingController: UIHostingController<Content>) {
          self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
          return hostingController.view
        }

      @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
          guard let scrollView = gesture.view as? UIScrollView else { return }
          if scrollView.zoomScale == 1 {
              scrollView.zoom(to: zoomRectForScale(4, center: gesture.location(in: gesture.view)), animated: true)
          } else {
              scrollView.setZoomScale(1, animated: true)
          }
      }
      private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
          let width = hostingController.view.frame.size.width / scale
          let height = hostingController.view.frame.size.height / scale
          let originX = center.x - (width / 2)
          let originY = center.y - (height / 2)
          return CGRect(x: originX, y: originY, width: width, height: height)
      }

  }
}

/*
#if DEBUG
struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView(thread: AbstractPostViewModel.preview.thread) { url in
            AsyncCachedImage(url: url)
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
                .aspectRatio(contentMode: .fit)
                .contextMenu {
                    ThumbnailContextMenu(url: url)
                } preview: {
                    AsyncCachedImage(url: url)
                        .resizable()
                        .cornerRadius(7)
                        .scaledToFill()
                }
        }
        .environmentObject(ToastViewModel())
        .environmentObject(GalleryViewModel.preview)
    }
}
#endif
*/
