import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    private enum Keys {
        static let favoriteBoards = "favoriteBoards"
        static let nonFavoriteBoards = "allBoards"
        static let showAdultBoards = "showAdultBoards"
        static let showMiscBoards = "showMiscBoards"
        static let photosAuthorized = "photosAuthorized"
    }

    @Published var favoriteBoards: Set<String> = []
    @Published var showAdultBoards: Bool = false
    @Published var showMiscBoards: Bool = false

    static let shared = UserSettings()

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadState()
        showAdultBoards = defaults.bool(forKey: Keys.showAdultBoards)
        showMiscBoards = defaults.bool(forKey: Keys.showMiscBoards)
    }
    
    private func saveState() {
        let encoder = JSONEncoder()
        if let encodedFavoriteBoards = try? encoder.encode(favoriteBoards) {
            defaults.set(encodedFavoriteBoards, forKey: Keys.favoriteBoards)
        }
    }

    private func loadState() {
        let decoder = JSONDecoder()
        if let favoriteBoardsData = defaults.data(forKey: Keys.favoriteBoards),
           let decodedFavoriteBoards = try? decoder.decode(Set<String>.self, from: favoriteBoardsData) {
            favoriteBoards = decodedFavoriteBoards
        }
    }

    func addToFavoriteBoards(_ board: Board) {
        let newPosition = favoriteBoards.count
        favoriteBoards.insert(board.board)
        saveState()
    }
    
    func removeFromFavoriteBoards(_ board: Board) {
        favoriteBoards.remove(board.board)
        saveState()
    }

    func toggleAdultBoards() {
        showAdultBoards.toggle()
        defaults.set(_showAdultBoards, forKey: Keys.showAdultBoards)
    }

    func setAdultBoards(to value: Bool) {
        showAdultBoards = value
        defaults.set(_showAdultBoards, forKey: Keys.showAdultBoards) //todo ?
    }

    func showAdultBoardsBinding() -> Binding<Bool> {
        return Binding<Bool>(
            get: { self.showAdultBoards },
            set: { self.setAdultBoards(to: $0) }
        )
    }

    func toggleMiscBoards() {
        showMiscBoards.toggle()
        defaults.set(_showMiscBoards, forKey: Keys.showMiscBoards)
    }

    func setMiscBoards(to value: Bool) {
        showMiscBoards = value
        defaults.set(_showMiscBoards, forKey: Keys.showMiscBoards)
    }

    func showMiscBoardsBinding() -> Binding<Bool> {
        return Binding<Bool>(
            get: { self.showMiscBoards },
            set: { self.setMiscBoards(to: $0) }
        )
    }

    var photosAuthorized: PhotosAccessPerm {
        get {
            let value = defaults.integer(forKey: Keys.photosAuthorized)
            return PhotosAccessPerm(rawValue: value) ?? .notDetermined
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.photosAuthorized) }
    }

}
