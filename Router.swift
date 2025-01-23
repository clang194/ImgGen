import Foundation
import SwiftUI

@MainActor
final class Router: ObservableObject {
    
    public enum Endpoint: Codable, Hashable {
        case catalog(id: String, searchTerm: String)
        case thread(board: String, id: Int)
        case bookmarks
        case history
        case galleryGrid(media: [Media])
        case settings
    }
    
    var appState = AppStateManager.shared
    
    @Published var navPath: [Endpoint]
    {
        didSet {
            saveState()
            print("\(appState.selectedTab)_navPath was SET with \(navPath) \n")
            //self.objectWillChange.send()
        }
    }
    
    init() {
        print("Initalization Started")
        do {
            if let encodedData = UserDefaults.standard.data(forKey: "\(appState.selectedTab)_navPath") {
                let decodedPath = try JSONDecoder().decode([Endpoint].self, from: encodedData)
                self.navPath = decodedPath
            } else {
                print("Reset1")
                self.navPath = []
            }
            
        } catch {
            print("Reset2")
            self.navPath = []
        }
        
        print("Initialized \(appState.selectedTab)_navPath with \(navPath) \n")
    }
    
    func navigate(to endpoint: Endpoint) {
        print("Navigate FUNC CALLED! \n")
        print("Nav before endpoint \(navPath) \n")
        print("Nav endpoint \(endpoint) \n")
        navPath.append(endpoint)
    }
    
    func replaceLast(with endpoint: Endpoint) {
        print("before \(navPath)")
        if !navPath.isEmpty {
            navPath[navPath.count - 1] = endpoint
        }
        print("after \(navPath)")
    }
    
    func navigateBack() {
        navPath.removeLast()
        print("Navigated back. ")
        print("\(appState.selectedTab)_navPath was BACK SET with \(navPath) \n")
    }
    
    func navigateToRoot() {
        print("Navigated to root. ")
        navPath.removeLast(navPath.count)
    }
    
    private func saveState() {
        do {
            let encodedData = try JSONEncoder().encode(navPath)
            UserDefaults.standard.set(encodedData, forKey: "\(appState.selectedTab)_navPath")
            print("Encoded navState of \(navPath)")
        } catch {
            print("Failed to save navigation state: \(error)")
        }
    }
    
//    private func restoreState() {
//        do {
//            if let encodedData = UserDefaults.standard.data(forKey: "\(appState.selectedTab)_navPath") {
//                let decodedPath = try JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: encodedData)
//                navPath = decodedPath
//            }
//        } catch {
//            navPath = NavigationPath()
//        }
//    }
}
