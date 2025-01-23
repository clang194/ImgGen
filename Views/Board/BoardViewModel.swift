import Foundation
import SwiftUI
import Combine

enum BoardSortType {
    case alphanumeric
}


class BoardViewModel: ObservableObject {
    
    enum State {
        case initial, loading, loaded, error
    }

    @Published var searchText: String = ""

    private var boardMap: [String: Board] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    @ObservedObject var userSettings = UserSettings.shared
    @Published private(set) var state = State.initial
    @Published private(set) var boards = [Board]()
    @Published var boardId = UUID()

    @Published var showingAdult: Bool = true
    @Published var showingMisc: Bool = true
    @Published var showingFavorites: Bool = true

    var filteredBoards: [Board] {
        var filteredBoards = self.boards
        
        if !searchText.isEmpty {
            filteredBoards.removeAll {
                !$0.board.contains(searchText) &&
                !$0.title.contains(searchText) &&
                !$0.meta_description.contains(searchText)
            }
        }
        
        if !showingAdult { filteredBoards.removeAll { adultBoards.contains($0.board) } }
        if !showingMisc { filteredBoards.removeAll { miscBoards.contains($0.board) } }
        if !showingFavorites { filteredBoards.removeAll { userSettings.favoriteBoards.contains($0.board) } }
        return filteredBoards
    }
    
    init() {
        setupObservers()
    }
    
    deinit {
        for cancel in cancellables {
            cancel.cancel()
        }
    }
    
    func setupObservers() {
        UserSettings.shared.$favoriteBoards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                //self?.boardId = UUID()
                self?.objectWillChange.send()
            }.store(in: &cancellables)

        userSettings.$showAdultBoards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)

        userSettings.$showMiscBoards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
            self?.objectWillChange.send()
            }.store(in: &cancellables)
    }
    
//    @MainActor func navigateToCatalog(board: String) {
//        print("Navigating to Catalog")
//        router.navigate(to: .catalog(id: board, searchTerm: ""))
//    }

    let miscBoards = ["b", "r9k", "pol", "bant", "soc", "s4s"]
    let adultBoards = ["s", "hc", "hm", "h", "e", "u", "d", "y", "t", "hr", "gif", "aco", "r"]


    /*
    let categories = [
        "Japanese Culture": Color.pink,
        "Video Games": Color.yellow,
        "Interests": Color.blue,
        "Creative": Color.green,
        "Other": Color.orange,
        "Misc. (NSFW)": Color.red,
        "Adult (NSFW)": Color.purple
    ]

    // Define the boards for each category
    let boardGroups = [
        "Japanese Culture": ["a", "c", "w", "m", "e", "cm", "f", "n", "jp", "vt"],
        "Video Games": ["v", "vg", "vm", "vmg", "vp", "vr", "vrpg", "vst"],
        "Interests": ["co", "g", "tv", "k", "o", "an", "tg", "sp", "asp", "wsg", "sci", "his", "int", "out", "toy"],
        "Creative": ["ic", "po", "p", "ck", "ic", "wg", "lit", "mu", "fa", "3", "gd", "diy", "wsg", "qst"],
        "Other": ["biz", "trv", "fit", "x", "adv", "lgbt", "mlp", "news", "wsr", "vip"],
        "Misc. (NSFW)": ["b", "r9k", "pol", "soc", "s4s"],
        "Adult (NSFW)": ["s", "hc", "hm", "h", "e", "u", "d", "y", "t", "hr", "gif", "aco", "r"]
    ]*/
    
    @MainActor
    func load() async {
        //self.state = .loading
        do {
            let fetchedBoards = try await ChanAPI.fetchBoards()
            if !fetchedBoards.isEmpty {
                self.boards = fetchedBoards
                self.state = .loaded
            }
        } catch {
            AppLogger.error("Failed to fetch boards: \(error)")
            self.state = .error
        }
    }
    
    func addToFavorites(_ board: Board) {
        UserSettings.shared.addToFavoriteBoards(board)
    }
    
    func removeFromFavorites(_ board: Board) {
        UserSettings.shared.removeFromFavoriteBoards(board)
    }
    
    func isNsfw(board: String) -> Bool {
        adultBoards.contains(board) || miscBoards.contains(board)
    }
    
//    // reorder the favorite boards
//    func reorderFavoriteBoards(from source: IndexSet, to destination: Int) {
//        var boards = favoriteBoards
//        boards.move(fromOffsets: source, toOffset: destination)
//        UserSettings.shared.updateFavoriteBoardsOrder(boards)
//    }
//
//    // reorder the non favorite boards
//    func reorderNonFavoriteBoards(from source: IndexSet, to destination: Int) {
//        var boards = nonFavoriteBoards
//        boards.move(fromOffsets: source, toOffset: destination)
//        UserSettings.shared.updateNonFavoriteBoardsOrder(boards)
//    }
    
    func setLoading() -> Void {
        state = .loaded
    }
    
    func setBoards() -> Void {
        boards = [Senkou.Board(board: "3", title: "3DCG", meta_description: "&quot;/3/ - 3DCG&quot; is 4chan\'s board for 3D modeling and imagery.", per_page: 15), Senkou.Board(board: "a", title: "Anime & Manga", meta_description: "&quot;/a/ - Anime &amp; Manga&quot; is 4chan\'s imageboard dedicated to the discussion of Japanese animation and manga.", per_page: 15), Senkou.Board(board: "aco", title: "Adult Cartoons", meta_description: "&quot;/aco/ - Adult Cartoons&quot; is 4chan\'s imageboard for posting western-styled adult cartoon artwork.", per_page: 15), Senkou.Board(board: "adv", title: "Advice", meta_description: "&quot;/adv/ - Advice&quot; is 4chan\'s board for giving and receiving advice. ", per_page: 15), Senkou.Board(board: "an", title: "Animals & Nature", meta_description: "&quot;/an/ - Animals &amp; Nature&quot; is 4chan\'s imageboard for posting pictures of animals, pets, and nature.", per_page: 15), Senkou.Board(board: "b", title: "Random", meta_description: "&quot;/b/ - Random&quot; is the birthplace of Anonymous, and where people go to discuss random topics and create memes on 4chan.", per_page: 15), Senkou.Board(board: "bant", title: "International/Random", meta_description: "&quot;/bant/ - International/Random&quot; is 4chan\'s international hanging out board, where you can have fun with Anonymous all over the world.", per_page: 15), Senkou.Board(board: "biz", title: "Business & Finance", meta_description: "&quot;/biz/ - Business &amp; Finance&quot; is 4chan\'s imageboard for the discussion of business and finance, and cryptocurrencies such as Bitcoin and Dogecoin.", per_page: 20), Senkou.Board(board: "c", title: "Anime/Cute", meta_description: "&quot;/c/ - Anime/Cute&quot; is 4chan\'s imageboard for cute and moe anime images.", per_page: 15), Senkou.Board(board: "cgl", title: "Cosplay & EGL", meta_description: "&quot;/cgl/ - Cosplay &amp; EGL&quot; is 4chan\'s imageboard for the discussion of cosplay, elegant gothic lolita (EGL), and anime conventions.", per_page: 15), Senkou.Board(board: "ck", title: "Food & Cooking", meta_description: "&quot;/ck/ - Food &amp; Cooking&quot; is 4chan\'s imageboard for food pictures and cooking recipes.", per_page: 15), Senkou.Board(board: "cm", title: "Cute/Male", meta_description: "&quot;/cm/ - Cute/Male&quot; is 4chan\'s imageboard for posting pictures of cute anime males.", per_page: 15), Senkou.Board(board: "co", title: "Comics & Cartoons", meta_description: "&quot;/co/ - Comics &amp; Cartoons&quot; is 4chan\'s imageboard dedicated to the discussion of Western cartoons and comics.", per_page: 15), Senkou.Board(board: "d", title: "Hentai/Alternative", meta_description: "&quot;/d/ - Hentai/Alternative&quot; is 4chan\'s imageboard for alternative hentai images.", per_page: 15), Senkou.Board(board: "diy", title: "Do It Yourself", meta_description: "&quot;/diy/ - Do It Yourself&quot; is 4chan\'s imageboard for DIY/do it yourself projects, home improvement, and makers.", per_page: 15), Senkou.Board(board: "e", title: "Ecchi", meta_description: "&quot;/e/ - Ecchi&quot; is 4chan\'s imageboard for suggestive (ecchi) hentai images.", per_page: 15), Senkou.Board(board: "f", title: "Flash", meta_description: "&quot;/f/ - Flash&quot; is 4chan\'s upload board for sharing Adobe Flash files (SWFs).", per_page: 30), Senkou.Board(board: "fa", title: "Fashion", meta_description: "&quot;/fa/ - Fashion&quot; is 4chan\'s imageboard for images and discussion relating to fashion and apparel.", per_page: 15), Senkou.Board(board: "fit", title: "Fitness", meta_description: "&quot;/fit/ - Fitness&quot; is 4chan\'s imageboard for weightlifting, health, and fitness.", per_page: 15), Senkou.Board(board: "g", title: "Technology", meta_description: "&quot;/g/ - Technology&quot; is 4chan\'s imageboard for discussing computer hardware and software, programming, and general technology.", per_page: 15), Senkou.Board(board: "gd", title: "Graphic Design", meta_description: "&quot;/gd/ - Graphic Design&quot; is 4chan\'s imageboard for graphic design.", per_page: 15), Senkou.Board(board: "gif", title: "Adult GIF", meta_description: "&quot;/gif/ - Adult GIF&quot; is 4chan\'s imageboard dedicated to animated adult GIFs and WEBMs.", per_page: 15), Senkou.Board(board: "h", title: "Hentai", meta_description: "&quot;/h/ - Hentai&quot; is 4chan\'s imageboard for adult Japanese anime hentai images.", per_page: 15), Senkou.Board(board: "hc", title: "Hardcore", meta_description: "&quot;/hc/ - Hardcore&quot; is 4chan\'s imageboard for the posting of adult hardcore pornography.", per_page: 15), Senkou.Board(board: "his", title: "History & Humanities", meta_description: "&quot;/his/ - History &amp; Humanities&quot; is 4chan\'s board for discussing and debating history.", per_page: 15), Senkou.Board(board: "hm", title: "Handsome Men", meta_description: "&quot;/hm/ - Handsome Men&quot; is 4chan\'s imageboard dedicated to sharing adult images of handsome men.", per_page: 15), Senkou.Board(board: "hr", title: "High Resolution", meta_description: "&quot;/hr/ - High Resolution&quot; is 4chan\'s imageboard for the sharing of high resolution images.", per_page: 15), Senkou.Board(board: "i", title: "Oekaki", meta_description: "&quot;/i/ - Oekaki&quot; is 4chan\'s oekaki board for drawing and sharing art.", per_page: 15), Senkou.Board(board: "ic", title: "Artwork/Critique", meta_description: "&quot;/ic/ - Artwork/Critique&quot; is 4chan\'s imageboard for the discussion and critique of art.", per_page: 15), Senkou.Board(board: "int", title: "International", meta_description: "&quot;/int/ - International&quot; is 4chan\'s international board, for the exchange of foreign language and culture.", per_page: 15), Senkou.Board(board: "jp", title: "Otaku Culture", meta_description: "&quot;/jp/ - Otaku Culture&quot; is 4chan\'s board for discussing Japanese otaku culture.", per_page: 15), Senkou.Board(board: "k", title: "Weapons", meta_description: "&quot;/k/ - Weapons&quot; is 4chan\'s imageboard for discussing all types of weaponry, from military tanks to guns and knives.", per_page: 15), Senkou.Board(board: "lgbt", title: "LGBT", meta_description: "&quot;/lgbt/ - LGBT&quot; is 4chan\'s imageboard for Lesbian-Gay-Bisexual-Transgender-Queer and sexuality discussion.", per_page: 15), Senkou.Board(board: "lit", title: "Literature", meta_description: "&quot;/lit/ - Literature&quot; is 4chan\'s board for the discussion of books, authors, and literature.", per_page: 15), Senkou.Board(board: "m", title: "Mecha", meta_description: "&quot;/m/ - Mecha&quot; is 4chan\'s imageboard for discussing Japanese mecha robots and anime, like Gundam and Macross.", per_page: 15), Senkou.Board(board: "mlp", title: "Pony", meta_description: "&quot;/mlp/ - Pony&quot; is 4chan\'s imageboard dedicated to the discussion of My Little Pony: Friendship is Magic.", per_page: 15), Senkou.Board(board: "mu", title: "Music", meta_description: "&quot;/mu/ - Music&quot; is 4chan\'s imageboard for discussing all types of music.", per_page: 15), Senkou.Board(board: "n", title: "Transportation", meta_description: "&quot;/n/ - Transportation&quot; is 4chan\'s imageboard for discussing modes of transportation like trains and bicycles.", per_page: 15), Senkou.Board(board: "news", title: "Current News", meta_description: "&quot;/news/ - Current News; is 4chan\'s board for current news. ", per_page: 15), Senkou.Board(board: "o", title: "Auto", meta_description: "&quot;/o/ - Auto&quot; is 4chan\'s imageboard for discussing cars and motorcycles.", per_page: 15), Senkou.Board(board: "out", title: "Outdoors", meta_description: "&quot;/out/ - Outdoors&quot; is 4chan\'s imageboard for discussing survivalist skills and outdoor activities such as hiking.", per_page: 15), Senkou.Board(board: "p", title: "Photography", meta_description: "&quot;/p/ - Photography&quot; is 4chan\'s imageboard for sharing and critiquing photos.", per_page: 15), Senkou.Board(board: "po", title: "Papercraft & Origami", meta_description: "&quot;/po/ - Papercraft &amp; Origami&quot; is 4chan\'s imageboard for posting papercraft and origami templates and instructions.", per_page: 15), Senkou.Board(board: "pol", title: "Politically Incorrect", meta_description: "&quot;/pol/ - Politically Incorrect&quot; is 4chan\'s board for discussing and debating politics and current events.", per_page: 20), Senkou.Board(board: "pw", title: "Professional Wrestling", meta_description: "&quot;/pw/ - Professional Wrestling&quot; is 4chan\'s imageboard for the discussion of professional wrestling.", per_page: 15), Senkou.Board(board: "qa", title: "Question & Answer", meta_description: "&quot;/qa/ - Question &amp; Answer&quot; is 4chan\'s imageboard for question and answer threads.", per_page: 15), Senkou.Board(board: "qst", title: "Quests", meta_description: "&quot;/qst/ - Quests&quot; is 4chan\'s imageboard for grinding XP.", per_page: 15), Senkou.Board(board: "r", title: "Adult Requests", meta_description: "&quot;/r/ - Request&quot; is 4chan\'s imageboard dedicated to fulfilling all types of user requests.", per_page: 15), Senkou.Board(board: "r9k", title: "ROBOT9001", meta_description: "&quot;/r9k/ - ROBOT9001&quot; is a board for hanging out and posting greentext stories.", per_page: 15), Senkou.Board(board: "s", title: "Sexy Beautiful Women", meta_description: "&quot;/s/ - Sexy Beautiful Women&quot; is 4chan\'s imageboard dedicated to sharing images of softcore pornography.", per_page: 15), Senkou.Board(board: "s4s", title: "Shit 4chan Says", meta_description: "&quot;[s4s] - Shit 4chan Says&quot; is 4chan\'s imageboard for posting dank memes :^)", per_page: 15), Senkou.Board(board: "sci", title: "Science & Math", meta_description: "&quot;/sci/ - Science &amp; Math&quot; is 4chan\'s board for the discussion of science and math.", per_page: 15), Senkou.Board(board: "soc", title: "Cams & Meetups", meta_description: "&quot;/soc/ - Cams &amp; Meetups&quot; is 4chan\'s board for camwhores and meetups.", per_page: 15), Senkou.Board(board: "sp", title: "Sports", meta_description: "&quot;/sp/ - Sports&quot; is 4chan\'s imageboard for sports discussion.", per_page: 15), Senkou.Board(board: "t", title: "Torrents", meta_description: "&quot;/t/ - Torrents&quot; is 4chan\'s imageboard for posting links and descriptions to torrents.", per_page: 15), Senkou.Board(board: "tg", title: "Traditional Games", meta_description: "&quot;/tg/ - Traditional Games&quot; is 4chan\'s imageboard for discussing traditional gaming, such as board games and tabletop RPGs.", per_page: 15), Senkou.Board(board: "toy", title: "Toys", meta_description: "&quot;/toy/ - Toys&quot; is 4chan\'s imageboard for talking about all kinds of toys!", per_page: 15), Senkou.Board(board: "trash", title: "Off-Topic", meta_description: "&quot;/trash/ - Off-topic&quot; is 4chan\'s imageboard jail for off-topic threads.", per_page: 15), Senkou.Board(board: "trv", title: "Travel", meta_description: "&quot;/trv/ - Travel&quot; is 4chan\'s imageboard dedicated to travel and the countries of the world.", per_page: 15), Senkou.Board(board: "tv", title: "Television & Film", meta_description: "&quot;/tv/ - Television &amp; Film&quot; is 4chan\'s imageboard dedicated to the discussion of television and film.", per_page: 15), Senkou.Board(board: "u", title: "Yuri", meta_description: "&quot;/u/ - Yuri&quot; is 4chan\'s imageboard for yuri hentai images.", per_page: 15), Senkou.Board(board: "v", title: "Video Games", meta_description: "&quot;/v/ - Video Games&quot; is 4chan\'s imageboard dedicated to the discussion of PC and console video games.", per_page: 20), Senkou.Board(board: "vg", title: "Video Game Generals", meta_description: "&quot;/vg/ - Video Game Generals&quot; is 4chan\'s imageboard dedicated to the discussion of PC and console video games.", per_page: 20), Senkou.Board(board: "vip", title: "Very Important Posts", meta_description: "&quot;/vip/ - Very Important Posts&quot; is 4chan\'s imageboard for Pass users.", per_page: 15), Senkou.Board(board: "vm", title: "Video Games/Multiplayer", meta_description: "&quot;/vmg/ - Video Games/Multiplayer&quot; is 4chan\'s imageboard dedicated to the discussion of multiplayer video games.", per_page: 15), Senkou.Board(board: "vmg", title: "Video Games/Mobile", meta_description: "&quot;/vmg/ - Video Games/Mobile&quot; is 4chan\'s imageboard dedicated to the discussion of video games on mobile devices.", per_page: 15), Senkou.Board(board: "vp", title: "Pokémon", meta_description: "&quot;/vp/ - Pok&eacute;mon&quot; is 4chan\'s imageboard dedicated to discussing the Pok&eacute;mon series of video games and shows.", per_page: 15), Senkou.Board(board: "vr", title: "Retro Games", meta_description: "&quot;/vr/ - Retro Games&quot; is 4chan\'s imageboard for discussing retro console video games and classic arcade games.", per_page: 15), Senkou.Board(board: "vrpg", title: "Video Games/RPG", meta_description: "&quot;/vrpg/ - Video Games/RPG&quot; is 4chan\'s imageboard dedicated to the discussion of role-playing video games.", per_page: 15), Senkou.Board(board: "vst", title: "Video Games/Strategy", meta_description: "&quot;/vst/ - Video Games/Strategy&quot; is 4chan\'s imageboard dedicated to the discussion of strategy video games.", per_page: 15), Senkou.Board(board: "vt", title: "Virtual YouTubers", meta_description: "&quot;/vt/ - Virtual YouTubers&quot; is 4chan\'s board for discussing virtual YouTubers (&quot;VTubers&quot;).", per_page: 15), Senkou.Board(board: "w", title: "Anime/Wallpapers", meta_description: "&quot;/w/ - Anime/Wallpapers&quot; is 4chan\'s imageboard for posting Japanese anime wallpapers.", per_page: 15), Senkou.Board(board: "wg", title: "Wallpapers/General", meta_description: "&quot;/wg/ - Wallpapers/General&quot; is 4chan\'s imageboard for posting general wallpapers.", per_page: 15), Senkou.Board(board: "wsg", title: "Worksafe GIF", meta_description: "&quot;/wsg/ - Worksafe GIF&quot; is 4chan\'s imageboard dedicated to sharing worksafe animated GIFs and WEBMs.", per_page: 15), Senkou.Board(board: "wsr", title: "Worksafe Requests", meta_description: "&quot;/wsr/ - Worksafe Requests&quot; is 4chan\'s imageboard dedicated to fulfilling non-NSFW requests.", per_page: 15), Senkou.Board(board: "x", title: "Paranormal", meta_description: "&quot;/x/ - Paranormal&quot; is 4chan\'s imageboard for the discussion of paranormal, spooky pictures and conspiracy theories.", per_page: 15), Senkou.Board(board: "xs", title: "Extreme Sports", meta_description: "&quot;/xs/ - Extreme Sports&quot; is 4chan\'s imageboard imageboard dedicated to the discussion of extreme sports.", per_page: 15), Senkou.Board(board: "y", title: "Yaoi", meta_description: "&quot;/y/ - Yaoi&quot; is 4chan\'s imageboard for posting adult yaoi hentai images.", per_page: 15)]
        //initialLoadBoards()
    }
}
