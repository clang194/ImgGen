
import SwiftUI
import UIKit
import MobileVLCKit

struct WebM: UIViewControllerRepresentable {
    var media: Media

    func makeUIViewController(context: Context) -> WebMView {
        let webmController = WebMView(media: media)
        return webmController
    }
    
    func updateUIViewController(_ uiViewController: WebMView, context: Context) {

    }
}

class WebMView: UIViewController {
    var player: VLCMediaPlayer!
    var media: Media
    var videoView: UIView!

    init(media: Media) {
        self.media = media
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoView = UIView()
        videoView.frame = self.view.bounds controller
        videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(videoView)
        
        setupPlayer()
    }

    func setupPlayer() {
        let mediaPlayer = VLCMediaPlayer()
        mediaPlayer.drawable = self.videoView

        if let url = media.url {
            print("loading media!!")
            let media = VLCMedia(url: url)
            mediaPlayer.media = media
        }

        self.player = mediaPlayer
        self.player.play()
        print(player.isPlaying)
    }

    @IBAction func playButtonTapped(_ sender: Any) {
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
}


//#Preview {
//    WebM()
//}
