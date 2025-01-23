import SwiftUI

struct MediaSaveErrorToast: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray)
                .frame(width: 120, height: 120)

            VStack {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)

                Text("Error")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }.opacity(0.75)
    }
}

#if DEBUG
struct MediaSaveErrorToast_Previews: PreviewProvider {
    static var previews: some View {
        MediaSavedToast()
    }
}
#endif
