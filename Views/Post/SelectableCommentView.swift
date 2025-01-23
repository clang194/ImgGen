import SwiftUI

struct SelectableCommentView: View {
    
    @EnvironmentObject var appStateManager: AppStateManager
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        let commentHandler = HTMLParser(comment: appStateManager.textSheetComment)
        if let parsedComment = try? commentHandler.parseHTML() {
            VStack {
                ScrollingSelectableText(String(parsedComment.characters[...]), contentSize: $contentSize)
                Divider().frame(maxWidth: .infinity)
                Button(action: {
                    appStateManager.showingTextSheet = false
                }) {
                    Text("CLOSE")
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                .padding(.top, -10)
                .frame(height: 40)
            }
            .background(.ultraThinMaterial) //modifier
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(maxHeight: min(contentSize.height + 65, 665))
        }
    }
}

class ContentSizedTextView: UITextView {
    var heightConstraint: NSLayoutConstraint?

    override var contentSize: CGSize {
        didSet {
            heightConstraint?.constant = contentSize.height
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if heightConstraint == nil {
            heightConstraint = heightAnchor.constraint(equalToConstant: contentSize.height)
            heightConstraint?.isActive = true
        }
    }
}

struct ScrollingSelectableText: UIViewRepresentable {
    @Binding var contentSize: CGSize
    @Environment(\.sizeCategory) var sizeCategory
    var text: String

    init(_ text: String, contentSize: Binding<CGSize>) {
        self.text = text
        self._contentSize = contentSize
    }
    
    class Coordinator {
        var textView: ContentSizedTextView?

        func selectAllText() {
            DispatchQueue.main.async {
                self.textView?.selectAll(nil)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.backgroundColor = .clear // Make UIScrollView background clear

        let textView = ContentSizedTextView()
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.font = UIFont.preferredFont(forTextStyle: .body).withSize(UIFont.preferredFont(forTextStyle: .body).pointSize)
        textView.text = text
        textView.backgroundColor = .clear // Make UITextView background clear

        textView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        context.coordinator.textView = textView

        return scrollView
    }


    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        DispatchQueue.main.async {
            if let textView = scrollView.subviews.compactMap({ $0 as? ContentSizedTextView }).first {
                textView.text = self.text
                self.contentSize = textView.contentSize
                context.coordinator.selectAllText()
            }
        }
    }
}




//#Preview {
//    SelectableCommentView(comment: "Hello")
//}
