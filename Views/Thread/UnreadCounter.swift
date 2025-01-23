import SwiftUI

struct UnreadCounter: View {
    let scrollProxy: ScrollViewProxy
    @ObservedObject var viewModel: UnreadCounterViewModel
    
    @State var showingExpanded = false
    
    var body: some View {
        VStack(alignment: .trailing) {
            if showingExpanded {
                HStack {
                    Button(action: {
                        withAnimation {
                            scrollProxy.scrollTo(0)
                        }
                    }, label: {
                        Text("Top")
                            .padding(12)
                    })
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal, 5) //todo modifier
                    
                    Button(action: {
                        scrollProxy.scrollTo(viewModel.totalCount - 1)
                    }, label: {
                        Text("Bottom")
                            .padding(12)
                    })
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .padding(.trailing, 12) //todo modifier
                }
            }
            Button(action: {
                showingExpanded.toggle()
            }, label: {
                Text(String(viewModel.unseenCount))
                    .padding(12)
            })
            .background(.thinMaterial)
            .cornerRadius(10)
            .padding(.vertical, 5)
            .padding(.trailing, 12)
            .padding(.bottom, 50)//todo modifier
        }
    }
}

//#Preview {
//    FloatingCounterButton()
//}
