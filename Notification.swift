import Foundation

extension Notification.Name {
    static let postAdded = Notification.Name(rawValue: "postAdded")
    static let postHidden = Notification.Name(rawValue: "postHidden")
    static let postUnhidden = Notification.Name(rawValue: "postUnhidden")
    static let postSeen = Notification.Name(rawValue: "postSeen")
    static let postUnseen = Notification.Name(rawValue: "postUnseen")
    static let threadSaved = Notification.Name(rawValue: "threadSaved")
    static let threadUnsaved = Notification.Name(rawValue: "threadUnsaved")
}
