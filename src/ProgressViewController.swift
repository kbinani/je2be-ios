import UIKit

class ProgressViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var stepDescriptionLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    private let input: URL
    private let converter: Converter
    private let cancelRequested = AtomicBool(initial: false)
    private var progressSteps: [UIProgressView] = []
    private var output: URL?
    
    init(input: URL, converter: Converter) {
        self.input = input
        self.converter = converter
        super.init(nibName: "ProgressViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let output = self.output {
            try? FileManager.default.removeItem(at: output)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numSteps = self.converter.numProgressSteps()
        for _ in 0 ..< numSteps {
            self.progressSteps.append(UIProgressView(progressViewStyle: .default))
        }
        for progress in self.progressSteps {
            progress.progress = 0
            self.stackView.addArrangedSubview(progress)
        }
        
        self.cancelButton.setTitle(gettext("Cancel"), for: .normal)
        self.cancelButton.addTarget(self, action: #selector(cancelButtonDidTouchUpInside(sender:)), for: .touchUpInside)
        
        self.exportButton.setTitle(gettext("Export"), for: .normal)
        self.exportButton.addTarget(self, action: #selector(exportButtonDidTouchUpInside(sender:)), for: .touchUpInside)
        self.exportButton.isHidden = true
        
        self.closeButton.setTitle(gettext("Back"), for: .normal)
        self.closeButton.addTarget(self, action: #selector(closeButtonDidTouchUpInside(sender:)), for: .touchUpInside)
        self.closeButton.isEnabled = false
        
        DispatchQueue.global().async { [weak self] in
            guard let input = self?.input, let converter = self?.converter else {
                return
            }
            converter.startConvertingFile(input, delegate: self)
        }
    }
    
    @objc func cancelButtonDidTouchUpInside(sender: AnyObject) {
        self.cancelButton.isEnabled = false
        self.cancelRequested.getAndSet(value: true)
    }
    
    @objc func exportButtonDidTouchUpInside(sender: AnyObject) {
        guard let output = self.output else {
            return
        }
        let vc = UIActivityViewController(activityItems: [output as Any], applicationActivities: nil)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = self.exportButton
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func closeButtonDidTouchUpInside(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProgressViewController: ConverterDelegate {
    func converterDidUpdateProgress(_ converter: Any, step: Int32, done: Double, total: Double) -> Bool {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, 0 <= step, step < self.progressSteps.count, let converter = converter as? Converter else {
                return
            }
            let s = Int(step)
            for i in 0 ..< s {
                self.progressSteps[i].progress = 1
            }
            self.progressSteps[s].progress = Float(done / total)
            self.stepDescriptionLabel.text = (converter.description(forStep: step) ?? "Conversion") + ":"
        }
        return !cancelRequested.test()
    }
    
    func converterDidFinishConversion(_ output: URL?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.closeButton.isEnabled = true
            
            if let output = output {
                self.output = output
                self.cancelButton.isHidden = true
                self.exportButton.isHidden = false
                
                self.stepDescriptionLabel.text = gettext("Completed")

                let vc = UIActivityViewController(activityItems: [output as Any], applicationActivities: nil)
                vc.modalPresentationStyle = .popover
                vc.popoverPresentationController?.sourceView = self.exportButton
                self.present(vc, animated: true, completion: nil)
            } else {
                self.cancelButton.isHidden = true
                self.exportButton.isHidden = true
                
                self.stepDescriptionLabel.text = gettext("Failed")
            }
        }
    }
}
