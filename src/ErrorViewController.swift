import UIKit

class ErrorViewController: UIViewController {
    
    private weak var errorView: ErrorView!
    private let insets = UIEdgeInsets(top: 40, left: 20, bottom: 15, right: 20)
    private let messages: [String]

    init(messages: [String]) {
        self.messages = messages
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.messages = []
        super.init(coder: coder)
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()

        let width: CGFloat = 375
        let errorView = ErrorView(messages: self.messages, width: width - self.insets.left - self.insets.right)
        self.errorView = errorView
        self.view.addSubview(errorView)
        
        let size = errorView.intrinsicContentSize

        self.preferredContentSize = CGSize(width: width, height: size.height + self.insets.top + self.insets.bottom)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.errorView.frame = CGRect(x: self.insets.left,
                                      y: self.insets.top,
                                      width: self.view.bounds.width - self.insets.left - self.insets.right,
                                      height: self.view.bounds.height - self.insets.top - self.insets.bottom)
    }
}


class ErrorView: UIView {
    
    private let messages: [String]
    private let width: CGFloat
    private var attributedString: NSAttributedString!
    private var framesetter: CTFramesetter!
    private var textFrame: CTFrame?
    
    init(messages: [String], width: CGFloat) {
        self.messages = messages
        self.width = width
        super.init(frame: CGRect(x: 0, y: 0, width: self.width, height: 0))
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.messages = []
        self.width = 1
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.isOpaque = false
        
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
            .foregroundColor: UIColor.white,
        ]
        let lines = messages.map { message in
            return bullet + " " + message
        }
        let attributedString = NSAttributedString(string: lines.joined(separator: "\n"), attributes: attributes)
        self.attributedString = attributedString
        self.framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        self.textFrame = createFrame()
    }
    
    private func createFrame() -> CTFrame {
        let pathBox = self.bounds
        let path = CGMutablePath()
        path.addRect(pathBox)
        return CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, self.attributedString.length), path, nil)
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), let frame = self.textFrame else {
            return
        }
        ctx.saveGState()
        defer {
            ctx.restoreGState()
        }
        ctx.clear(self.bounds)
        ctx.translateBy(x: 0, y: self.bounds.height)
        ctx.scaleBy(x: 1, y: -1)
        CTFrameDraw(frame, ctx)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textFrame = createFrame()
        self.invalidateIntrinsicContentSize()
        self.setNeedsDisplay()
    }
    
    override var intrinsicContentSize: CGSize {
        let constraints = CGSize(width: self.width, height: CGFloat.greatestFiniteMagnitude)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(self.framesetter, CFRangeMake(0, self.attributedString.length), nil, constraints, nil)
        return CGSize(width: self.width, height: size.height)
    }
}
