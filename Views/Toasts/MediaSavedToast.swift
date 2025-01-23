import SwiftUI

struct MediaSavedToast: View {
    var body: some View {
            VStack {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 40, height: 30)
                    .foregroundColor(.white)

                Text("Saved")
                    .font(.title)
                    .foregroundColor(.white)
            }.background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray)
                    .frame(width: 120, height: 120)
            ).opacity(0.75)
    }
}

#if DEBUG
struct MediaSavedToast_Previews: PreviewProvider {
    static var previews: some View {
        MediaSavedToast()
    }
}
#endif
