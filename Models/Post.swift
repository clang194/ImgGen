import Foundation

struct Post: Codable, Identifiable, Equatable {
    let no: Int
    let resto: Int
    let sticky: Int?
    let closed: Int?
    let tim: Int?
    let time: Int
    let name: String?
    let trip: String?
    let capcode: String?
    let sub: String?
    let com: String?
    let filename: String?
    let ext: String?
    let fsize: Int?
    let md5: String?
    let w: Int?
    let h: Int?
    let tn_w: Int?
    let tn_h: Int?
    let filedeleted: Int?
    let spoiler: Int?
    let replies: Int?
    let images: Int?
    let country: String?
    let country_name: String?
    let unique_ips: Int?
    let archived: Int?
    let archived_on: Int?
    let last_replies: [Post]?
    
    var id: Int {
        return no
    }
    
    var containsSpoiler: Bool {
        return self.spoiler == 1
    }

    var containsMedia: Bool {
        return self.tim != nil
    }
    
    static func dummy(_ id: Int) -> Post {
        return Post(no: id, resto: 0, sticky: nil, closed: nil, tim: 0, time: 0, name: nil, trip: nil, capcode: nil, sub: "Lorem ipsum dolor", com: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat", filename: "nil", ext: ".jpg", fsize: 0, md5: nil, w: 0, h: 0, tn_w: nil, tn_h: nil, filedeleted: nil, spoiler: nil, replies: nil, images: 0, country: nil, country_name: nil, unique_ips: nil, archived: nil, archived_on: nil, last_replies: nil)
    }
    
    static var dummies: [Post] {
        return [dummy(0), dummy(1), dummy(2), dummy(3), dummy(4)]
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id  // Compare based on `id` only
    }
}

class MediaFetcher {
    static func getMediaUrl(forPost post: Post, boardId: String, thumbnail: Bool = false) -> URL? {
        guard let urlFileName = post.tim, let extens = post.ext else {
            return nil
        }

        let fileExtension = thumbnail ? ".jpg" : extens
        let thumb = thumbnail ? "s" : ""
        let urlString = "https://i.4cdn.org/\(boardId)/\(urlFileName)\(thumb)\(fileExtension)"

        return URL(string: urlString)
    }

    static func getMedia(forPost post: Post, boardId: String) -> Media? {
        guard let _ = getMediaUrl(forPost: post, boardId: boardId), let _ = getMediaUrl(forPost: post, boardId: boardId, thumbnail: true) else {
            return nil
        }

        return Media(
            url: getMediaUrl(forPost: post, boardId: boardId),
            thumbnailUrl: getMediaUrl(forPost: post, boardId: boardId, thumbnail: true)
        )
    }
}

class ContentFilter {
    static func contains(_ searchText: String, in post: Post) -> Bool {
        let searchText = searchText.lowercased()
        return
            searchText == "" ||
        String(post.no).contains(searchText) ||
        (post.name?.lowercased().contains(searchText) == true) ||
        (post.sub?.lowercased().contains(searchText) == true) ||
        (post.com?.lowercased().contains(searchText) == true) ||
        (post.filename?.lowercased().contains(searchText) == true)
    }
}
