import UIKit
import UniformTypeIdentifiers

protocol ChooseInputViewDelegate: AnyObject {
    func chooseInputViewDidChoosen(sender: ChooseInputViewController, type: ConversionType, result: SecurityScopedResource, playerUuid: UUID?)
    func chooseInputViewDidCancel()
}

class ChooseInputViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var javaPlayerUuidPanel: UIStackView!
    @IBOutlet weak var javaPlayerUuidMessageLabel: UILabel!
    @IBOutlet weak var javaPlayerUuidLabel: UILabel!
    @IBOutlet weak var javaPlayerUuid: UILabel!
    @IBOutlet weak var javaPlayerUuidWarningButton: UIButton!
    @IBOutlet weak var javaPlayerUuidSwitchLabel: UILabel!
    @IBOutlet weak var javaPlayerUuidSwitch: UISwitch!

    weak var delegate: ChooseInputViewDelegate?

    private var documentPicked = false
    private let type: ConversionType
    private let message: String
    private let contentTypes: [UTType]
    private var javaPlayerUuidWarningMessages: [String]?

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
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.label.font!,
            .underlineColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
                
        switch self.type {
        case .bedrockToJava, .xbox360ToJava:
            self.javaPlayerUuidMessageLabel.attributedText = .init(string: "1. " + gettext("Configure player UUID") + ":", attributes: attributes)
            self.javaPlayerUuidLabel.text = "UUID:"
            self.javaPlayerUuid.font = UIFont.monospacedSystemFont(ofSize: self.javaPlayerUuid.font.pointSize, weight: .regular)
            self.javaPlayerUuidSwitchLabel.text = gettext("Use the UUID for conversion")
            if let javaPlayerUuid = Self.javaPlayerUuidFromUserDefaults {
                self.javaPlayerUuid.text = javaPlayerUuid.uuidString
                self.javaPlayerUuid.isEnabled = true
                self.javaPlayerUuidSwitch.isOn = true
                self.javaPlayerUuidSwitch.isEnabled = true
                self.javaPlayerUuidWarningButton.isHidden = true
                self.javaPlayerUuidWarningMessages = nil
            } else if let javaPlayerUuidString = Self.javaPlayerUuidStringFromUserDefaults {
                self.javaPlayerUuid.text = javaPlayerUuidString
                self.javaPlayerUuid.isEnabled = false
                self.javaPlayerUuidSwitch.isOn = false
                self.javaPlayerUuidSwitch.isEnabled = false
                self.javaPlayerUuidWarningButton.isHidden = false
                
                let messages = [
                    gettext("Invalid UUID format"),
                    gettext("It is also possible to start conversion without setting the UUID"),
                ]
                self.javaPlayerUuidWarningMessages = messages
            } else {
                self.javaPlayerUuid.text = "00000000-0000-0000-0000-000000000000"
                self.javaPlayerUuid.isEnabled = false
                self.javaPlayerUuidSwitch.isOn = false
                self.javaPlayerUuidSwitch.isEnabled = false
                self.javaPlayerUuidWarningButton.isHidden = false
                
                let messages = [
                    gettext("Player UUID is not set. Open the Settings app to configure"),
                    gettext("It is also possible to start conversion without setting the UUID"),
                ]
                self.javaPlayerUuidWarningMessages = messages
            }
            self.javaPlayerUuidPanel.isHidden = false

            self.label.attributedText = .init(string: "2. " + self.message + ":", attributes: attributes)
        case .javaToBedrock, .xbox360ToBedrock:
            self.javaPlayerUuidPanel.isHidden = true
            self.javaPlayerUuidSwitch.isOn = false

            self.label.attributedText = .init(string: self.message + ":", attributes: attributes)
        }

        self.button.setTitle(gettext("Select"), for: .normal)
        self.button.addTarget(self, action: #selector(buttonDidTouchUpInside(_:)), for: .touchUpInside)
        
        self.javaPlayerUuidWarningButton.addTarget(self, action: #selector(javaPlayerUuidWarningButtonDidTouchUpInside(_:)), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let messages = self.javaPlayerUuidWarningMessages {
            let vc = ErrorViewController(messages: messages)
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.delegate = self
            vc.popoverPresentationController?.sourceView = self.javaPlayerUuidWarningButton
            vc.popoverPresentationController?.permittedArrowDirections = [.up]
            self.present(vc, animated: true)
        }
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
 
    @objc private func javaPlayerUuidWarningButtonDidTouchUpInside(_ sender: UIButton) {
        guard let messages = self.javaPlayerUuidWarningMessages else {
            return
        }
        let vc = ErrorViewController(messages: messages)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.sourceView = self.javaPlayerUuidWarningButton
        vc.popoverPresentationController?.permittedArrowDirections = [.up]
        self.present(vc, animated: true)
    }
    
    static var javaPlayerUuidStringFromUserDefaults: String? {
        guard let uuidString = UserDefaults.standard.string(forKey: "javaPlayerUuid"), !uuidString.isEmpty else {
            return nil
        }
        return uuidString
    }
    
    static var javaPlayerUuidFromUserDefaults: UUID? {
        guard let uuidString = javaPlayerUuidStringFromUserDefaults else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }
}


extension ChooseInputViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if let result = SecurityScopedResource(url: url) {
            self.documentPicked = true
            let playerUuid: UUID?
            if self.javaPlayerUuidSwitch.isOn, let uuid = Self.javaPlayerUuidFromUserDefaults {
                playerUuid = uuid
            } else {
                playerUuid = nil
            }
            self.delegate?.chooseInputViewDidChoosen(sender: self, type: self.type, result: result, playerUuid: playerUuid)
        } else {
            let vc = UIAlertController(title: gettext("Error"), message: gettext("Can't access file"), preferredStyle: .alert)
            vc.addAction(.init(title: "OK", style: .default))
            self.present(vc, animated: true)
        }
    }
}


extension ChooseInputViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
