import SwiftUI

struct ProgressToast: View {
    @State private var progress: CGFloat = 0.0

    var body: some View {
        Circle()
            .trim(from: 0.0, to: progress)
            .stroke(Color.blue, lineWidth: 20)
            .rotationEffect(Angle(degrees: -90))
            .padding(40)
            .animation(.easeInOut(duration: 0.2))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.progress = 0.1
                }
            }

        Slider(value: $progress, in: 0...1)
            .padding()
    }
}

#if DEBUG
struct ProgressToast_Previews: PreviewProvider {
    static var previews: some View {
        ProgressToast()
    }
}
#endif
