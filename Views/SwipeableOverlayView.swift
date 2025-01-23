import SwiftUI

struct GallerySwipeableOverlayView<Content: View>: View {
    @EnvironmentObject var galleryViewModel: GalleryViewModel
    @State var lastDetailedView: Bool = true
    @State var isGestureStarted: Bool = false
    @State private var animateDismissal = false
    @Binding var dragOffset: CGFloat
    let geometry: GeometryProxy
    let onSwipe: (() -> Void)?
    let onDismiss: (() -> Void)?
    let onBackgroundTap: (() -> Void)?
    let backgroundOpacity: Double
    let content: Content
    @State var dragDirection: DragDirection? = nil
    enum DragDirection {
        case horizontal
        case vertical
    }

    init(dragOffset: Binding<CGFloat>, geometry: GeometryProxy, onSwipe: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil, onBackgroundTap: (() -> Void)? = nil, backgroundOpacity: Double = 1, @ViewBuilder content: () -> Content) {
        self._dragOffset = dragOffset
        self.geometry = geometry
        self.onSwipe = onSwipe
        self.onDismiss = onDismiss
        self.onBackgroundTap = onBackgroundTap
        self.backgroundOpacity = backgroundOpacity
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(min(opacityFrom(dragOffset), opacityFrom(dragOffset)-(1-backgroundOpacity)))
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dragOffset = 0
                    onBackgroundTap?()
                }

            content
                .offset(y: self.dragOffset)
        }
        .simultaneousGesture(
            swipeToGoBack(geometry: geometry, dragOffset: $dragOffset, onDismiss: onDismiss)
        )
        .onDisappear {
            dragOffset = 0
        }
    }

    private func swipeToGoBack(geometry: GeometryProxy, dragOffset: Binding<CGFloat>, minimumDistance: CGFloat = 50, onDismiss dismiss: (() -> Void)?) -> some Gesture {
        
        DragGesture(minimumDistance: minimumDistance, coordinateSpace: .global)
            .onChanged { value in
                if dragDirection == nil {
                    dragDirection = abs(value.translation.width) > abs(value.translation.height) ? .horizontal : .vertical
                }
                if dragDirection == .vertical && value.translation.height > 0 {
                    dragOffset.wrappedValue = value.translation.height
                    if !isGestureStarted {
                        isGestureStarted = true
                        lastDetailedView = galleryViewModel.showingDetailedView
                        //withoutAnimation {
                            galleryViewModel.showingDetailedView = false
                        //}
                    }
                }
            }
            .onEnded { value in
                dragDirection = nil
                isGestureStarted = false
                galleryViewModel.showingDetailedView = lastDetailedView
                if value.predictedEndTranslation.height > geometry.size.height / 3 {
                    let swipeDistance = value.startLocation.y - value.location.y
                    if abs(swipeDistance) > 0 {
                        dragOffset.wrappedValue = geometry.size.height
                        galleryViewModel.disappearing.send()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dragOffset.wrappedValue = 0
                            dismiss?()
                        }
                    } else {
                        dragOffset.wrappedValue = 0
                    }
                } else {
                    dragOffset.wrappedValue = 0
                }
            }
    }
    private func opacityFrom(_ dragDistance: CGFloat) -> Double {
        let maxDragDistance = CGFloat(UIScreen.main.bounds.height)/2
        let positiveDragDistance = abs(dragDistance)
        let normalizedDragDistance = min(positiveDragDistance / maxDragDistance, 1)
        return Double(1 - normalizedDragDistance)
    }
}


struct SwipeableOverlayView<Content: View>: View {
    @Binding var dragOffset: CGFloat
    let geometry: GeometryProxy
    let onSwipe: (() -> Void)?
    let onDismiss: (() -> Void)?
    let onBackgroundTap: (() -> Void)?
    let backgroundOpacity: Double
    let content: Content

    init(dragOffset: Binding<CGFloat>, geometry: GeometryProxy, onSwipe: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil, onBackgroundTap: (() -> Void)? = nil, backgroundOpacity: Double = 1, @ViewBuilder content: () -> Content) {
        self._dragOffset = dragOffset
        self.geometry = geometry
        self.onSwipe = onSwipe
        self.onDismiss = onDismiss
        self.onBackgroundTap = onBackgroundTap
        self.backgroundOpacity = backgroundOpacity
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(min(opacityFrom(dragOffset), opacityFrom(dragOffset)-(1-backgroundOpacity)))
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dragOffset = 0
                    onBackgroundTap?()
                }
            content
                .offset(x: self.dragOffset)
        }
        .gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .global)
                .onChanged { value in
                    if value.startLocation.x < geometry.size.width / 10 {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    if value.translation.width > geometry.size.width / 4 {
                        let swipeDistance = value.startLocation.x - value.location.x
                        let isSwipeStartedFromEdge = value.startLocation.x < geometry.size.width * 0.10
                        if (abs(swipeDistance) > 0) && isSwipeStartedFromEdge {
                            dragOffset = 0
                            onDismiss?()
                        }
                    }
                }
        )
        .onDisappear {
            dragOffset = 0
        }
    }

    private func opacityFrom(_ dragDistance: CGFloat) -> Double {
        let maxDragDistance = CGFloat(UIScreen.main.bounds.width)
        let positiveDragDistance = abs(dragDistance)
        let normalizedDragDistance = min(positiveDragDistance / maxDragDistance, 1)
        return Double(1 - normalizedDragDistance)
    }
}
