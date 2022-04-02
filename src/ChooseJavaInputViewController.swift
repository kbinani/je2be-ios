import UIKit
import UniformTypeIdentifiers

protocol ChooseJavaInputViewDelegate: AnyObject {
    func chooseJavaInputViewDidChoosen(url: URL)
}

class ChooseJavaInputViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!

    weak var delegate: ChooseJavaInputViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.text = gettext("Choose a zip file of Java Edition world data")
        
        self.button.setTitle(gettext("Select"), for: .normal)
        self.button.addTarget(self, action: #selector(buttonDidTouchUpInside(_:)), for: .touchUpInside)
    }
    
    @objc func buttonDidTouchUpInside(_ sender: AnyObject) {
        let vc = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.zip])
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension ChooseJavaInputViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.delegate?.chooseJavaInputViewDidChoosen(url: url)
        self.dismiss(animated: true, completion: nil)
    }
}
