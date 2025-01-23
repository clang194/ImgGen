import Foundation

extension PostEntity {
    func load(from post: Post) {
        self.no = Int64(post.no)
        self.resto = Int64(post.resto)
        self.sticky = Int64(post.sticky ?? 0)
        self.closed = Int64(post.closed ?? 0)
        self.tim = Int64(post.tim ?? 0)
        self.time = Int64(post.time)
        self.name = post.name
        self.trip = post.trip
        self.capcode = post.capcode
        self.sub = post.sub
        self.com = post.com
        self.filename = post.filename
        self.ext = post.ext
        self.fsize = Int64(post.fsize ?? 0)
        self.md5 = post.md5
        self.w = Int64(post.w ?? 0)
        self.h = Int64(post.h ?? 0)
        self.tn_w = Int64(post.tn_w ?? 0)
        self.tn_h = Int64(post.tn_h ?? 0)
        self.filedeleted = Int64(post.filedeleted ?? 0)
        self.spoiler = Int64(post.spoiler ?? 0)
        self.replies = Int64(post.replies ?? 0)
        self.images = Int64(post.images ?? 0)
        self.country = post.country
        self.country_name = post.country_name
        self.unique_ips = Int64(post.unique_ips ?? 0)
        self.archived = Int64(post.archived ?? 0)
        self.archived_on = Int64(post.archived_on ?? 0)
            if let replies = post.last_replies {
                self.last_replies = NSSet(array: replies.map {
                    let replyEntity = PostEntity(context: self.managedObjectContext!)
                    replyEntity.load(from: $0)
                    return replyEntity
                })
            }
        }

    func toPost() -> Post {
        return Post( no: Int(self.no),
             resto: Int(self.resto),
             sticky: Int(self.sticky),
             closed: Int(self.closed),
             tim: Int(self.tim),
             time: Int(self.time),
             name: self.name,
             trip: self.trip,
             capcode: self.capcode,
             sub: self.sub,
             com: self.com,
             filename: self.filename,
             ext: self.ext,
             fsize: Int(self.fsize),
             md5: self.md5,
             w: Int(self.w),
             h: Int(self.h),
             tn_w: Int(self.tn_w),
             tn_h: Int(self.tn_h),
             filedeleted: Int(self.filedeleted),
             spoiler: Int(self.spoiler),
             replies: Int(self.replies),
             images: Int(self.images),
             country: self.country,
             country_name: self.country_name,
             unique_ips: Int(self.unique_ips),
             archived: Int(self.archived),
             archived_on: Int(self.archived_on),
             last_replies: (self.last_replies as? Set<PostEntity>)?.map { $0.toPost() })
    }
}
