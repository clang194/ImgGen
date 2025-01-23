import SwiftUI

struct ToastView: View {
    
    @EnvironmentObject var toastViewModel: ToastViewModel
    
    var body: some View {
        switch toastViewModel.toastState {
        case .saving:
            MediaSavingToast()
        case .saved:
            MediaSavedToast()
        case .loading:
            ProgressToast()
        case .error:
            MediaSaveErrorToast() //TODO
        case .none:
            EmptyView()
        }
    }
}

//#Preview {
//    ToastView()
//}
