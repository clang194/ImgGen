import Foundation

enum ToastState {
    case saving, saved
    case loading
    case error
}

final class ToastViewModel: ObservableObject {
    
    static let shared = ToastViewModel()
    
    @Published var toastState: ToastState?
    
    private init() { }
}
