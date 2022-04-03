import UIKit
import UniformTypeIdentifiers

protocol ChooseInputViewDelegate: AnyObject {
    func chooseInputViewDidChoosen(sender: ChooseInputViewController, type: ConversionType, url: URL)
    func chooseInputViewDidCancel()
}

class ChooseInputViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!

    weak var delegate: ChooseInputViewDelegate?

    private var documentPicked = false
    private let type: ConversionType
    private let message: String
    private let contentTypes: [UTType]

    init(type: ConversionType, message: String, contentTypes: [UTType]) {
        self.type = type
        self.message = message
        self.contentTypes = contentTypes
        super.init(nibName: "ChooseInputViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.text = self.message
        
        self.button.setTitle(gettext("Select"), for: .normal)
        self.button.addTarget(self, action: #selector(buttonDidTouchUpInside(_:)), for: .touchUpInside)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !self.documentPicked {
            self.delegate?.chooseInputViewDidCancel()
        }
    }
    
    @objc func buttonDidTouchUpInside(_ sender: AnyObject) {
        let vc = UIDocumentPickerViewController(forOpeningContentTypes: self.contentTypes)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension ChooseInputViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.documentPicked = true
        self.delegate?.chooseInputViewDidChoosen(sender: self, type: self.type, url: url)
    }
}
