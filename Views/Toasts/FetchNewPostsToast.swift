import SwiftUI

struct FetchNewPostsToast: View {
    
    @State var postCount: Int
    let onClick: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer() // Added Spacer
                    HStack {
                        Image(systemName: "arrow.down.to.line")
                        Text("Fetched \(postCount) new posts")
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    Spacer() // Added Spacer
                }.padding(.bottom, 20)
            }
            .onTapGesture {
                onClick()
            }
        }
    }
}


#if DEBUG
struct FetchThreadsToast_Previews: PreviewProvider {
    static var previews: some View {
        FetchNewPostsToast(postCount: 5, onClick: {})
    }
}
#endif
