import UIKit

class ProgressViewController: UIViewController {
    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var cancelButton: UIButton!
    
    private let input: URL
    private let converter: Converter
    private let cancelRequested = AtomicBool(initial: false)
    
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
        
        self.progress.progress = 0

        self.cancelButton.addTarget(self, action: #selector(cancelButtonDidTouchUpInside(sender:)), for: .touchUpInside)
        
        self.converter.convert(self.input, delegate: self)
    }
    
    @objc func cancelButtonDidTouchUpInside(sender: AnyObject) {
        self.cancelButton.isEnabled = false
        self.cancelRequested.getAndSet(value: true)
    }
}

extension ProgressViewController: ConverterDelegate {
    func converterDidUpdateProgress(_ converter: Any!, done: Double, total: Double) -> Bool {
        DispatchQueue.main.async { [weak self] in
            self?.progress.progress = Float(done / total)
        }
        return cancelRequested.test()
    }
    
    func converterDidFinishConversion(_ output: URL?) {
        //TODO:
        print(output)
        self.dismiss(animated: true, completion: nil)
    }
}
