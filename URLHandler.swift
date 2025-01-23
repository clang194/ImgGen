import Foundation

struct URLHandler {
    enum URLAction {
        case catalog(String, String)
        case thread(String, String)
        case reply(String)
        case regular(URL)
    }

    func handleURL(_ url: URL) -> URLAction? {
        guard let host = url.host else {
            return nil
        }

        let pathComponents = url.pathComponents

        switch host {
        case "catalog":
            guard pathComponents.count > 2 else { return nil }
            return .catalog(pathComponents[1], pathComponents[2])

        case "thread":
            guard pathComponents.count > 2 else { return nil }
            return .thread(pathComponents[1], pathComponents[2])

        case "reply":
            guard pathComponents.count > 1 else { return nil }
            return .reply(pathComponents[1])

        default:
            return .regular(url)
        }
    }
}
