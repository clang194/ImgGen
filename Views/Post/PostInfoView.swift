import SwiftUI

struct PostInfoRow: View {
    let systemName: String
    let title: String
    let description: String
    let value: String
    let accent: Color
    
    init(systemName: String, title: String, description: String, value: String, accent: Color = .primary) {
        self.systemName = systemName
        self.title = title
        self.description = description
        self.value = value
        self.accent = accent
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: systemName)
                .aspectRatio(contentMode: .fill)
                .frame(width: 25)
                .foregroundStyle(accent)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.body)
                        Text(description)
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                    .lineLimit(2)
                    Spacer()
                    Text(value)
                        .textSelection(.enabled)
                }
            }
            
        }
    }
    
}

struct PostInfoView: View {
    
    let viewModel:  PostRowViewModel
    
    var body: some View {
        let post = viewModel.post
        List {
            Section(header: Text("Post")) {
                let name = post.name ?? "Anonymous" // check if optional
                PostInfoRow(
                    systemName: "textformat",
                    title: "Name",
                    description: "Name user posted with. Defaults to Anonymous",
                    value: name
                )
                
                PostInfoRow(
                    systemName: "number",
                    title: "No",
                    description: "The numeric post ID",
                    value: String(post.no)
                )
                
                let time = DateHandler.formatPostElement(from: Double(post.time))
                PostInfoRow(
                    systemName: "clock",
                    title: "Time",
                    description: "UNIX timestamp the post was created",
                    value: time
                )
                
                if post.resto != 0 {
                    PostInfoRow(
                        systemName: "number",
                        title: "Resto",
                        description: "For replies: this is the ID of the thread being replied to. For OP: this value is zero",
                        value: String(post.resto)
                    )
                }
                
                PostInfoRow(
                    systemName: "pin",
                    title: "Pinned",
                    description: "If the thread is being pinned to the top of the page",
                    value: (post.sticky != nil) ? "True" : "False"
                )
                
                PostInfoRow(
                    systemName: "xmark",
                    title: "Closed",
                    description: "If the thread is closed to replies",
                    value: (post.closed != nil) ? "True" : "False"
                )
                
                let trip = post.trip ?? "False"
                PostInfoRow(
                    systemName: "dice",
                    title: "Trip",
                    description: "If post has tripcode",
                    value: trip
                )
            }
            
            if let countryName = post.country_name {
                PostInfoRow(
                    systemName: "mappin.and.ellipse",
                            title: "Country",
                            description: "Poster's country name",
                            value: countryName
                )
            }
            
            if let tim = post.tim?.description,
                let filename = post.filename,
                let ext = post.ext,
                let fsize = post.fsize?.description,
                let md5 = post.md5,
                let w = post.w?.description,
                let h = post.h?.description,
                let tn_w = post.tn_w?.description,
                let tn_h = post.tn_h?.description,
                let filedeleted = (post.filedeleted != nil) ? "True" : "False",
                let spoiler = (post.spoiler != nil) ? "True" : "False" {
                Section(header: Text("Attachment")) {
                    PostInfoRow(systemName: "clock", title: "Tim", description: "Unix timestamp + microtime that an image was uploaded", value: tim)
                    PostInfoRow(systemName: "paperclip", title: "Filename", description: "Filename as it appeared on the poster's device", value: filename + ext)
                    PostInfoRow(systemName: "internaldrive", title: "File size", description: "Size of uploaded file in bytes", value: fsize)
                    PostInfoRow(systemName: "lock.doc.fill", title: "MD5 hash", description: "24 character, packed base64 MD5 hash of file", value: md5)
                    PostInfoRow(systemName: "ruler", title: "Dimensions", description: "Image dimensions", value: "\(w)x\(h)")
                    PostInfoRow(systemName: "ruler", title: "Thumbnail dimensions", description: "Thumbnail dimensions", value: "\(tn_w)x\(tn_h)")
                    PostInfoRow(systemName: "trash", title: "File deleted", description: "If the file was deleted from the post", value: filedeleted)
                    PostInfoRow(systemName: "eye.slash", title: "Spoiler", description: "If the image was spoilered or not", value: spoiler)
                }
            }
            
//            PostInfoRow(systemName: "clock", title: "Now", description: "MM/DD/YY(Day)HH:MM (:SS on some boards), EST/EDT timezone", value: post.now) // implement
        }
    }
}

//#Preview {
//    PostInfoView()
//}
