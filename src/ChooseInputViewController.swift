import UIKit
import UniformTypeIdentifiers

protocol ChooseInputViewDelegate: AnyObject {
    func chooseInputViewDidChoosen(sender: ChooseInputViewController, type: ConversionType, result: SecurityScopedResource, playerUuid: UUID?)
    func chooseInputViewDidCancel()
}

private var sObserverContextUserDefaultsJavaPlayerUuid: Int = 0

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
    private weak var javaPlayerUuidWarningPopover: UIViewController?
    
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
        
        switch self.type {
        case .bedrockToJava, .xbox360ToJava:
            self.javaPlayerUuidMessageLabel.attributedText = Self.titleAttributes(header: "1. ",
                                                                                  body: gettext("Configure player UUID") + ":",
                                                                                  font: self.label.font!)
            self.javaPlayerUuidLabel.text = "UUID:"
            self.javaPlayerUuidSwitchLabel.text = gettext("Use the UUID for conversion")
            updateJavaPlayerUuidString(Self.javaPlayerUuidStringFromUserDefaults)
            self.javaPlayerUuidPanel.isHidden = false
            
            self.label.attributedText = Self.titleAttributes(header: "2. ",
                                                             body: self.message + ":",
                                                             font: self.label.font!)
        case .javaToBedrock, .xbox360ToBedrock:
            self.javaPlayerUuidPanel.isHidden = true
            self.javaPlayerUuidSwitch.isOn = false
            
            self.label.attributedText = Self.titleAttributes(header: nil,
                                                             body: self.message + ":",
                                                             font: self.label.font!)
        }
        
        self.button.setTitle(gettext("Select"), for: .normal)
        self.button.addTarget(self, action: #selector(buttonDidTouchUpInside(_:)), for: .touchUpInside)
        
        self.javaPlayerUuidWarningButton.addTarget(self, action: #selector(javaPlayerUuidWarningButtonDidTouchUpInside(_:)), for: .touchUpInside)
        
        subscribeUserDefaults()
    }
    
    private func subscribeUserDefaults() {
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: UserDefaultsKey.javaPlayerUuid,
                                          options: [.new, .old],
                                          context: &sObserverContextUserDefaultsJavaPlayerUuid)
    }
    
    private func unsubscribeUserDefaults() {
        UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaultsKey.javaPlayerUuid, context: &sObserverContextUserDefaultsJavaPlayerUuid)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch context {
        case &sObserverContextUserDefaultsJavaPlayerUuid:
            guard let newValue = change?[NSKeyValueChangeKey.newKey] as? String else {
                return
            }
            guard let oldValue = change?[NSKeyValueChangeKey.oldKey] as? String else {
                return
            }
            guard newValue != oldValue else {
                return
            }
            switch self.type {
            case .xbox360ToJava, .bedrockToJava:
                updateJavaPlayerUuidString(newValue)
            case .xbox360ToBedrock, .javaToBedrock:
                break
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func updateJavaPlayerUuidString(_ javaPlayerUuidString: String?) {
        let uuid: UUID?
        if let string = javaPlayerUuidString {
            uuid = UUID(uuidString: string)
        } else {
            uuid = nil
        }
        if let uuid = uuid {
            self.javaPlayerUuid.text = uuid.uuidString
            self.javaPlayerUuid.isEnabled = true
            self.javaPlayerUuidSwitch.isOn = true
            self.javaPlayerUuidSwitch.isEnabled = true
            self.javaPlayerUuidWarningButton.isHidden = true
            
            self.javaPlayerUuidWarningMessages = nil
            self.javaPlayerUuidWarningPopover?.dismiss(animated: true)
        } else if let string = javaPlayerUuidString {
            self.javaPlayerUuid.text = string
            self.javaPlayerUuid.isEnabled = false
            self.javaPlayerUuidSwitch.isOn = false
            self.javaPlayerUuidSwitch.isEnabled = false
            self.javaPlayerUuidWarningButton.isHidden = false
            
            let messages = [
                gettext("Invalid UUID format"),
                gettext("It is also possible to start conversion without setting the UUID"),
            ]
            self.javaPlayerUuidWarningMessages = messages
            presentJavaPlayerUuidWarningPopover()
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
            presentJavaPlayerUuidWarningPopover()
        }
    }
    
    private static func titleAttributes(header: String?, body: String, font: UIFont) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .underlineColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        let string: String
        if let header = header {
            string = header + body
            
            let style = NSMutableParagraphStyle()
            style.setParagraphStyle(NSParagraphStyle.default)
            let indentSize = (header as NSString).size(withAttributes: attributes)
            style.headIndent = indentSize.width
            attributes[.paragraphStyle] = style
        } else {
            string = body
        }
        return .init(string: string, attributes: attributes)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentJavaPlayerUuidWarningPopover()
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
        presentJavaPlayerUuidWarningPopover()
    }
    
    private func presentJavaPlayerUuidWarningPopover() {
        guard self.javaPlayerUuidWarningPopover == nil else {
            return
        }
        guard let messages = self.javaPlayerUuidWarningMessages else {
            return
        }
        let vc = ErrorViewController(messages: messages)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.sourceView = self.javaPlayerUuidWarningButton
        vc.popoverPresentationController?.backgroundColor = .white
        vc.popoverPresentationController?.permittedArrowDirections = [.up]
        self.present(vc, animated: true)
        self.javaPlayerUuidWarningPopover = vc
    }
    
    static var javaPlayerUuidStringFromUserDefaults: String? {
        guard let uuidString = UserDefaults.standard.string(forKey: UserDefaultsKey.javaPlayerUuid), !uuidString.isEmpty else {
            return nil
        }
        return uuidString
    }
}


extension ChooseInputViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if let result = SecurityScopedResource(url: url) {
            self.documentPicked = true
            let playerUuid: UUID?
            if self.javaPlayerUuidSwitch.isOn, let uuidString = Self.javaPlayerUuidStringFromUserDefaults, let uuid = UUID(uuidString: uuidString) {
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
