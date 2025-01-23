import QuickLook
import SwiftUI
import UIKit

struct QuickLookPreview: UIViewControllerRepresentable {
    let selectedURL: URL
    let urls: [URL]
    
    func makeUIViewController(context _: Context) -> UIViewController {
        return AppQLPreviewController(selectedURL: selectedURL, urls: urls)
    }
    
    func updateUIViewController(_: UIViewController, context _: Context) {}
}

class AppQLPreviewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    let selectedURL: URL
    let urls: [URL]
    
    var qlController: QLPreviewController?
    var cache: [URL: URL] = [:]
    var downloading: Set<URL> = []
    
    init(selectedURL: URL, urls: [URL]) {
        self.selectedURL = selectedURL
        self.urls = urls
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if qlController == nil {
            qlController = QLPreviewController()
            qlController?.dataSource = self
            qlController?.delegate = self
            qlController?.currentPreviewItemIndex = urls.firstIndex(of: selectedURL) ?? 0
            present(qlController!, animated: true)
        }
    }
    
    func download(url: URL, completion: @escaping (URL?) -> Void) {
        guard !downloading.contains(url) else { return }
        downloading.insert(url)
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localURL = documentsURL.appendingPathComponent(url.lastPathComponent)
        
        let task = URLSession.shared.downloadTask(with: url) { tempLocalUrl, response, error in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                do {
                    try FileManager.default.moveItem(at: tempLocalUrl, to: localURL)
                    self.cache[url] = localURL
                    completion(self.cache[url])
                } catch (let writeError) {
                    print("Error creating a file \(localURL) : \(writeError)")
                }
            } else {
                print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "N/A")")
            }
            self.downloading.remove(url)
        }
        task.resume()
    }
    
    func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        return urls.count
    }
    
    func previewController(_: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = urls[index]
        
        if let localUrl = cache[url] {
            return localUrl as QLPreviewItem
        } else {
            download(url: url) { localUrl in
                // inform QLPreviewController that the item at this index has been updated
                DispatchQueue.main.async {
                    self.qlController?.reloadData()
                }
            }
            // return a temporary item here, this will be replaced once the download is complete
            return url as QLPreviewItem
        }
    }
    
    func previewController(_: QLPreviewController, editingModeFor _: QLPreviewItem) -> QLPreviewItemEditingMode {
        .createCopy
    }
    
    func previewControllerWillDismiss(_: QLPreviewController) {
        dismiss(animated: true)
    }
    
    func previewControllerDidDismiss(_: QLPreviewController) {
        dismiss(animated: true)
    }
}

struct TransparentBackground: UIViewControllerRepresentable {
    public func makeUIViewController(context _: Context) -> UIViewController {
        return TransparentController()
    }
    
    public func updateUIViewController(_: UIViewController, context _: Context) {}
    
    class TransparentController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
        }
        
        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            parent?.view?.backgroundColor = .clear
            parent?.modalPresentationStyle = .overCurrentContext
        }
    }
}
