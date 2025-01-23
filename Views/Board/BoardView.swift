import SwiftUI

struct BoardView: View {
    
    @EnvironmentObject var router: Router
    @StateObject var viewModel: BoardViewModel = BoardViewModel()
    
    @Binding var showingBoards: Bool
    @Binding var showSearchBar: Bool
    @Binding var searchTerm: String
    //@FocusState.Binding var searching: Bool
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .initial:
                Color.clear
                    .onAppear {
                    Task {
                        await viewModel.load()
                    }
                }
            case .loading:
                Text("Loading")
            case .loaded:
                ScrollView {
                    VStack {
                        HStack {
                            Spacer()
                            Menu {
                                Button {
                                    viewModel.showingAdult.toggle()
                                } label: {
                                    HStack {
                                        if viewModel.showingAdult {
                                            Image(systemName: "checkmark")
                                        }
                                        Text("Adult boards")
                                    }
                                }
                                
                                Button {
                                    viewModel.showingMisc.toggle()
                                } label: {
                                    HStack {
                                        if viewModel.showingMisc {
                                            Image(systemName: "checkmark")
                                        }
                                        Text("Misc. boards")
                                    }
                                }
                                
                                Button {
                                    viewModel.showingFavorites.toggle()
                                } label: {
                                    HStack {
                                        if viewModel.showingFavorites {
                                            Image(systemName: "checkmark")
                                        }
                                        Text("Favorite boards")
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    Text("Filter").bold()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                            }
                            .buttonStyle(.bordered)
                            .menuActionDismissBehavior(.disabled)
                            
                            Spacer()
                            
                            Button {
                                //searching = true
                                showSearchBar.toggle()
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                    searching = true
//                                }
//                                //searching = true
//                                print(searching)
                            } label: {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text("Search").bold()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                            }
                            .buttonStyle(.bordered)
                            Spacer()
                        }.padding(.vertical, 10)
                        if showSearchBar {
                            SearchBar(searchText: $searchTerm)
                        }
                        BoardGridView(router: router, showingBoards: $showingBoards)
                    }
                }
                .background(Color.darkGray)
                .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                //}
                .environmentObject(viewModel) 
                //.transition(.move(edge: .bottom))//todo
//                .toolbar {
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Menu {
//                            Button {
//                                viewModel.showingAdult.toggle()
//                            } label: {
//                                HStack {
//                                    if viewModel.showingAdult {
//                                        Image(systemName: "checkmark")
//                                    }
//                                    Text("Adult boards")
//                                }
//                            }
//                            
//                            Button {
//                                viewModel.showingMisc.toggle()
//                            } label: {
//                                HStack {
//                                    if viewModel.showingMisc {
//                                        Image(systemName: "checkmark")
//                                    }
//                                    Text("Misc. boards")
//                                }
//                            }
//                            
//                            Button {
//                                viewModel.showingFavorites.toggle()
//                            } label: {
//                                HStack {
//                                    if viewModel.showingFavorites {
//                                        Image(systemName: "checkmark")
//                                    }
//                                    Text("Favorite boards")
//                                }
//                            }
//                        } label: {
//                            Image(systemName: "line.3.horizontal.decrease.circle")
//                        }
//                        .menuActionDismissBehavior(.disabled)
//                    }
//                }
            case .error:
                Text("Error")
            }
        }
        .animation(.default, value: viewModel.state)
        .animation(.default, value: showingBoards)
        .onChange(of: searchTerm) { _, newTerm in
            viewModel.searchText = newTerm
        }
        .navigationBarTitleDisplayMode(.inline)
//        .task {
//            viewModel.router = router
//        }
    }
}

//struct BoardDetail: View {
//    let board: Board
//
//    var body: some View {
//        Text(board.title)
//            .navigationBarTitle(board.title)
//    }
//}

//#Preview {
//    BoardView(showingBoards: <#T##Binding<Bool>#>)
//        .environmentObject(Router())
//}
//
//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        BoardView()
//            .environmentObject(Router())
//        //.environmentObject(ToastViewModel())
//    }
//}
//
//extension BoardViewModel {
//    static var preview: BoardViewModel {
//        let preview = BoardViewModel()
//        preview.setBoards()
//        preview.setLoading()// Set the state you want for the preview
//        return preview
//    }
//}
//#endif
