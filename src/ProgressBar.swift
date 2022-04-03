
class ProgressBar: UIView {
    private weak var label: UILabel!
    private weak var progressView: UIProgressView!
    private let progressViewStyle: UIProgressViewStyle
    
    init(progressViewStyle: UIProgressViewStyle) {
        self.progressViewStyle = progressViewStyle
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        let label = UILabel(frame: self.bounds)
        self.label = label
        label.baselineAdjustment = .alignCenters
        self.addSubview(label)
        
        let progressView = UIProgressView(frame: self.bounds)
        self.progressView = progressView
        progressView.progressViewStyle = self.progressViewStyle
        self.addSubview(progressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        let gap: CGFloat = 5
        self.label.frame = CGRect(x: bounds.minX, y: bounds.minX,
                                  width: bounds.width, height: bounds.height * 0.5 - gap * 0.5)
        self.progressView.frame = CGRect(x: bounds.minX, y: bounds.midY + gap * 0.5,
                                         width: bounds.width, height: bounds.height * 0.5 - gap * 0.5)
    }
    
    var progress: Float = 0 {
        didSet {
            self.progressView.progress = self.progress
        }
    }
    
    var title: String? {
        didSet {
            self.label.text = self.title
        }
    }
    
    var titleColor: UIColor = .black {
        didSet {
            self.label.textColor = self.titleColor
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 44)
    }
}
