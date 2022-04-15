import UIKit

protocol ProgressViewDelegate: AnyObject {

    func progressViewWillDisappear()
}


class ProgressViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var stepDescriptionLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var errorInfoButton: UIButton!

    weak var delegate: ProgressViewDelegate?
    
    private let input: SecurityScopedResource
    private let tempDirectory: URL
    private let converter: Converter
    private let cancelRequested = AtomicBool(initial: false)
    private var progressSteps: [ProgressBar] = []
    private var output: URL?
    private var errorMessages: [String]? = nil
    
    init(input: SecurityScopedResource, tempDirectory: URL, converter: Converter) {
        self.input = input
        self.tempDirectory = tempDirectory
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
        for step in 0 ..< numSteps {
            let bar = ProgressBar(progressViewStyle: .default)
            bar.progress = 0
            bar.title = converter.description(forStep: step)
            bar.titleColor = .gray
            self.progressSteps.append(bar)
            self.stackView.addArrangedSubview(bar)
        }
        
        self.cancelButton.setTitle(gettext("Cancel"), for: .normal)
        self.cancelButton.addTarget(self, action: #selector(cancelButtonDidTouchUpInside(sender:)), for: .touchUpInside)
        
        self.exportButton.setTitle(gettext("Export"), for: .normal)
        self.exportButton.addTarget(self, action: #selector(exportButtonDidTouchUpInside(sender:)), for: .touchUpInside)
        self.exportButton.isHidden = true
        
        self.closeButton.setTitle(gettext("Back"), for: .normal)
        self.closeButton.addTarget(self, action: #selector(closeButtonDidTouchUpInside(sender:)), for: .touchUpInside)
        self.closeButton.isEnabled = false
        
        self.errorInfoButton.addTarget(self, action: #selector(errorInfoButtonDidTouchUpInside(_:)), for: .touchUpInside)
        
        DispatchQueue.global().async { [weak self] in
            guard let input = self?.input, let tempDirectory = self?.tempDirectory, let converter = self?.converter else {
                return
            }
            converter.startConvertingFile(input.url, usingTempDirectory: tempDirectory, delegate: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.progressViewWillDisappear()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func cancelButtonDidTouchUpInside(sender: AnyObject) {
        self.cancelButton.isEnabled = false
        let vc = UIAlertController(title: nil, message: gettext("Do you really want to cancel?"), preferredStyle: .alert)
        vc.addAction(.init(title: gettext("Yes"), style: .destructive, handler: { [weak self] (action) in
            guard let self = self else {
                return
            }
            self.cancelRequested.getAndSet(value: true)
        }))
        vc.addAction(.init(title: gettext("No"), style: .cancel, handler: { [weak self] (action) in
            guard let self = self else {
                return
            }
            self.cancelButton.isEnabled = true
        }))
        self.present(vc, animated: true)
    }
    
    @objc private func exportButtonDidTouchUpInside(sender: AnyObject) {
        guard let output = self.output else {
            return
        }
        let vc = UIActivityViewController(activityItems: [output as Any], applicationActivities: nil)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = self.exportButton
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc private func closeButtonDidTouchUpInside(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func errorInfoButtonDidTouchUpInside(_ sneder: UIButton) {
        guard let messages = self.errorMessages else {
            return
        }
        presentErrorView(messages: messages)
    }
    
    private func presentErrorView(messages: [String]) {
        let vc = ErrorViewController(messages: messages)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = self.errorInfoButton
        self.present(vc, animated: true)
    }
}


extension ProgressViewController: ConverterDelegate {
    func converterDidUpdateProgress(_ progress: Double, total: Double, step: Int32, description: String?, displayUnit unit: String?) -> Bool {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, 0 <= step, step < self.progressSteps.count else {
                return
            }
            let s = Int(step)
            for i in 0 ..< s {
                self.progressSteps[i].progress = 1
            }
            self.progressSteps[s].progress = Float(progress / total)
            let percentage = String(format: "%.1f", progress / total * 100.0)
            if let description = description {
                if let displayUnit = unit {
                    self.progressSteps[s].title = "\(description): \(Int(progress)) \(displayUnit), \(percentage)% done"
                } else {
                    self.progressSteps[s].title = "\(description): \(percentage)% done"
                }
            }
            self.stepDescriptionLabel.text = "Current Task: " + (description ?? "Convert")
        }
        return !cancelRequested.test()
    }
    
    func converterDidFinishConversion(_ output: URL?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.closeButton.isEnabled = true
            
            if let error = error as? NSError, error.domain == kJe2beErrorDomain {
                self.cancelButton.isHidden = true
                self.exportButton.isHidden = true
                
                let code = Je2beErrorCode(Int32(error.code))
                if code == kJe2beErrorCodeCancelled {
                    self.stepDescriptionLabel.text = gettext("Cancelled")
                } else if let messages = error.je2beLocalizedMessages {
                    self.errorInfoButton.isHidden = false
                    self.stepDescriptionLabel.text = gettext("Error")
                    self.errorMessages = messages
                    self.presentErrorView(messages: messages)
                } else {
                    self.stepDescriptionLabel.text = gettext("Error")
                }
            } else if let output = output {
                self.output = output
                self.cancelButton.isHidden = true
                self.exportButton.isHidden = false
                self.errorInfoButton.isHidden = true

                self.stepDescriptionLabel.text = gettext("Completed")

                let vc = UIActivityViewController(activityItems: [output as Any], applicationActivities: nil)
                vc.modalPresentationStyle = .popover
                vc.popoverPresentationController?.sourceView = self.exportButton
                self.present(vc, animated: true, completion: nil)
            } else {
                self.cancelButton.isHidden = true
                self.exportButton.isHidden = true
                self.errorInfoButton.isHidden = true

                self.stepDescriptionLabel.text = gettext("Failed")
            }
        }
    }
}
