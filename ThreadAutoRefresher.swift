import Foundation
import Combine

protocol ThreadAutoRefreshDelegate: AnyObject {
    func refresh(_ withToast: Bool) async
}

class ThreadAutoRefresher {
    
    private(set) var timer: Timer.TimerPublisher?
    private var timerCancellable: Cancellable?
    weak var delegate: ThreadAutoRefreshDelegate?
    var newPostsCount = 0
    
    init(delegate: ThreadAutoRefreshDelegate?) {
        self.delegate = delegate
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 15, on: .main, in: .common)
        self.timerCancellable = self.timer?.autoconnect().sink { _ in
            Task {
                await self.delegate?.refresh(_:)
            }
        }
    }
    
    func stopTimer() {
        self.timerCancellable?.cancel()
        self.timerCancellable = nil
    }
}
