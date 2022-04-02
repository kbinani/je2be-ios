import UIKit

class ProgressViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var stepDescriptionLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    private let input: URL
    private let converter: Converter
    private let cancelRequested = AtomicBool(initial: false)
    private var progressSteps: [UIProgressView] = []
    
    init(input: URL, converter: Converter) {
        self.input = input
        self.converter = converter
        super.init(nibName: "ProgressViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            if let output = output {
                self.stepDescriptionLabel.text = gettext("Completed")
                let vc = UIActivityViewController(activityItems: [output as Any], applicationActivities: nil)
                vc.modalPresentationStyle = .popover
                vc.popoverPresentationController?.sourceView = self.stepDescriptionLabel
                vc.completionWithItemsHandler = { [weak self] (activityType, completed, returnedItems, activityError) in
                    try? FileManager.default.removeItem(at: output)
                    self?.dismiss(animated: true, completion: nil)
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
