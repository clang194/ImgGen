import Foundation

enum ViewType: Hashable {
    case boards, catalog, thread, gallerygrid
}


enum TabState: Int, Codable {
    case browse = 0
    case saved
    case history
    case settings
}

class AppStateManager: ObservableObject {
    
    static let shared = AppStateManager()
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: "selectedTab"),
           let initialTab = try? JSONDecoder().decode(TabState.self, from: data) {
            self.selectedTab = initialTab
        } else {
            self.selectedTab = .saved
        }
        
        if let board = UserDefaults.standard.string(forKey: "lastBoard"){
            self.selectedBoard = board
        } else {
            self.selectedBoard = "a"
        }
    }
    
    @Published var selectedTab: TabState {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(selectedTab) {
                UserDefaults.standard.set(encoded, forKey: "selectedTab")
            }
        }
    }
    @Published var selectedBoard: String {
        didSet {
            UserDefaults.standard.set(selectedBoard, forKey: "lastBoard")
        }
    }
    
    
    @Published var tabRootSignal: Bool = false
    @Published var activeView: ViewType = .boards
    @Published var showingTextSheet: Bool = false
    @Published var textSheetComment: String = ""
    
    @Published var showingInfoSheet: Bool = false
    @Published var infoSheetViewModel: PostRowViewModel?
}

