import SwiftUI

struct ThumbnailContextMenu: View {

    let url: URL
    @EnvironmentObject var toastViewModel: ToastViewModel

    var body: some View {
        Button(action: {
            Task {
                await MediaHandler.shared.saveImage(url)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }, label: {
            Text("Save photo")
            Image(systemName: "square.and.arrow.down")
        })
    }

}

#if DEBUG
struct ThumbnailContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailContextMenu(url: URL(string: "https://i.4cdn.org/pol/1683402997557291.jpg")!)
    }
}
#endif
