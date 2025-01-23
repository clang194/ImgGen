import SwiftUI

@main
struct BoardApp: App {
    
    @ObservedObject var router = Router()
    @StateObject var toastViewModel = ToastViewModel.shared
    @StateObject var galleryViewModel = GalleryViewModel()
    @StateObject var appStateManager = AppStateManager.shared
    @StateObject var inlineViewModel: InlineViewModel = InlineViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                TabControllerView()
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                ToastView()
                InlineOverlayView(router: router)
                    .ignoresSafeArea()
                GalleryOverlayView(router: router)
                    .ignoresSafeArea()
//                    .animation(.easeIn, value: galleryViewModel.selection)
                SelectableCommentOverlay()
                    .ignoresSafeArea()
                .sheet(isPresented: $appStateManager.showingInfoSheet) {
                    if let viewModel = appStateManager.infoSheetViewModel {
                        PostInfoView(viewModel: viewModel)
                    }
                }
                .sheet(isPresented: $galleryViewModel.showingImageListSheet) {
                    GalleryImageList()
                }
            }
            .onAppear {
                //Persistence.shared.deletePersistentStore()
//                Persistence.shared.clearPersistentThreads()
////                let per = PersistentThread(board: "a", id: 0)
////                per.lastOpened = Date(timeIntervalSince1970: 1234567890)
////                per.save()
            }
            .onOpenURL { url in
                handleURL(url)
            }
            .environmentObject(toastViewModel)
            .environmentObject(galleryViewModel)
            .environmentObject(appStateManager)
            .environmentObject(inlineViewModel)
        }
    }
    
    func handleURL(_ url: URL) {
        guard let action = URLHandler().handleURL(url) else { return }

        switch action {
        case .catalog(let boardName, let searchTerm):
            print(searchTerm)
            AppLogger.info(boardName)
            router.navigate(to: .catalog(id: boardName, searchTerm: searchTerm))
        case .thread(let boardName, let threadId):
            AppLogger.info("Navigating to \(boardName) \(threadId)")
            router.navigate(to: .thread(board: boardName, id: Int(threadId)!)) //TODO
        case .reply:
            break
        case .regular(let regularUrl):
            UIApplication.shared.open(regularUrl)
        }
    }
}

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 1 / 255, blue: 235 / 255)
}
