import UIKit

class ErrorViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    let messages: [String]

    init(messages: [String]) {
        self.messages = messages
        super.init(nibName: "ErrorViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let width: CGFloat = 375 - 40
        var height: CGFloat = 80
        let font = UIFont.systemFont(ofSize: 17)
        let style = NSMutableParagraphStyle()
        style.setParagraphStyle(NSParagraphStyle.default)
        let bullet = "\u{2022}"
        let indentSize = ((bullet + " ") as NSString).size(withAttributes: [.font: font])
        style.headIndent = indentSize.width
        style.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: style,
        ]

        for message in messages {
            let label = UILabel(frame: .zero)
            label.numberOfLines = Int.max
            let text = NSMutableAttributedString(string: bullet + " " + message, attributes: attributes)
            label.attributedText = text
            label.minimumScaleFactor = 1
            self.stackView.addArrangedSubview(label)
            let size = label.systemLayoutSizeFitting(.init(width: width, height: CGFloat.greatestFiniteMagnitude))
            height += size.height + indentSize.height
        }
        
        self.preferredContentSize = CGSize(width: width, height: height)
    }
}
