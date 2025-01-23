import SwiftUI

struct MediaSavingToast: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray)
                .frame(width: 120, height: 120)

            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)

                Text("Saving")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }.opacity(0.6)
    }
}

#if DEBUG
struct MediaSavingToast_Previews: PreviewProvider {
    static var previews: some View {
        MediaSavingToast()
    }
}
#endif
