import SwiftUI

struct PostSubject: View {

    let subject: String?

    init(_ subject: String?) {
        self.subject = subject
    }

    var body: some View {
        if let sub = subject {
            let decodedSub = decodeHTMLEntities(in: sub)
            Text(decodedSub)
                .font(Font.system(size: 18))
                .foregroundColor(Color.blue)
                .multilineTextAlignment(.leading)
        }
    }
}

#if DEBUG
struct PostSubject_Previews: PreviewProvider {
    static var previews: some View {
        PostSubject("Test")
    }
}
#endif
