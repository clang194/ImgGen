import SwiftUI
import Combine

struct InlineView: View {

    @EnvironmentObject var inlineViewModel: InlineViewModel
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @State private var contentSize: CGSize = .zero
    @State private var isLoaded: Bool = false
    
    let router: Router
    
    var body: some View {
        if let inlineThread = inlineViewModel.inlineStack.last {
            let thread = inlineThread.parentThread
            let posts = inlineThread.posts
            VStack {
                ScrollingStack(contentSize: $contentSize) {
                    VStack(spacing: 0) {
                        ForEach(posts.indices, id: \.self) { index in
                            let post = posts[index]
                            InlinePostElement(viewModel: PostRowViewModel(thread: thread, post: post, router: router
                            ))
                            .id(index)
                            if index != posts.count - 1 {
                                Divider()
                                    .padding(.leading, 20)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                }
                .id(UUID())
                Divider().frame(maxWidth: .infinity)
                HStack(spacing: 0) {
                    Button(action: {
                        inlineViewModel.removeLastThread()
                    }) {
                        Text("BACK")
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 0.5)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    Button(action: { // not this
                        inlineViewModel.removeAllThreads()
                    }) {
                        Text("CLOSE")
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.top, -10)
                .frame(height: 40) // Set a fixed height for the buttons
            }
            .background(.ultraThinMaterial) //modifier
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(maxHeight: min(contentSize.height + 65, 665))
            .onReceive(Just(contentSize)) { newSize in
                AppLogger.info("Content size: \(newSize)")
            }
            .animation(.easeInOut(duration: 0.1), value: contentSize)
        }
    }

}


struct ScrollingStack<Content: View>: UIViewRepresentable {
    var content: Content
    @Binding var contentSize: CGSize

    init(contentSize: Binding<CGSize>, @ViewBuilder content: () -> Content) {
        self._contentSize = contentSize
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        //scrollView.backgroundColor = UIColor.clear
        scrollView.bounces = false
        // SwiftUI view is embedded into a UIHostingController
        let hostVC = TransparentHostingController(rootView: content)
        hostVC.view.translatesAutoresizingMaskIntoConstraints = false  // Allow AutoLayout

        // Embed UIHostingController's view as subview of UIScrollView
        scrollView.addSubview(hostVC.view)

        // Setup constraints for the hosting view to fill the entire scroll view
        NSLayoutConstraint.activate([
            hostVC.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostVC.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostVC.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostVC.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            // Important: Make hosting view width to match scroll view's width
            // Not doing this might cause unexpected behaviors due to free horizontal scrollability
            hostVC.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // This makes the binding reflect the actual content size whenever it changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.contentSize = scrollView.contentSize
        }
    }
}

class TransparentHostingController<Content: View>: UIHostingController<Content> {
    override init(rootView: Content) {
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//#if DEBUG
//struct InlineView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            InlineView()
//                .environmentObject(InlineViewModel.preview)
//                .environmentObject(AbstractPostViewModel.preview)
//            
//            ZStack {
//                VStack(spacing:0) {
//                    Rectangle().fill(.orange.gradient)
//                    Rectangle().fill(.blue.gradient)
//                    Rectangle().fill(.green.gradient)
//                    Rectangle().fill(.pink.gradient)
//                }
//                InlineView()
//                    .environmentObject(InlineViewModel.preview)
//                    .environmentObject(AbstractPostViewModel.preview)
//            }
//        }
//    }
//}
//#endif
