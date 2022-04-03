import UIKit
import UniformTypeIdentifiers

class ModeSelectViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var javaToBedrockButton: UIButton!
    @IBOutlet weak var bedrockToJavaButton: UIButton!
    @IBOutlet weak var xbox360ToBedrockButton: UIButton!
    @IBOutlet weak var xbox360ToJavaButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.text = gettext("Select conversion mode")
        
        self.javaToBedrockButton.setTitle(gettext("Java to Bedrock"), for: .normal)
        self.javaToBedrockButton.addTarget(self,
                                           action: #selector(javaToBedrockButtonDidTouchUpInside(_:)),
                                           for: .touchUpInside)
        
        self.bedrockToJavaButton.setTitle(gettext("Bedrock to Java"), for: .normal)
        self.bedrockToJavaButton.addTarget(self,
                                           action: #selector(bedrockToJavaButtonDidTouchUpInside(_:)),
                                           for: .touchUpInside)
        
        self.xbox360ToBedrockButton.setTitle(gettext("Xbox360 to Bedrock"), for: .normal)
        self.xbox360ToBedrockButton.addTarget(self,
                                              action: #selector(xbox360ToBedrockButtonDidTouchUpInside(_:)),
                                              for: .touchUpInside)
        
        self.xbox360ToJavaButton.setTitle(gettext("Xbox360 to Java"), for: .normal)
        self.xbox360ToJavaButton.addTarget(self,
                                           action: #selector(xbox360ToJavaButtonDidTouchUpInside(_:)),
                                           for: .touchUpInside)
        
        self.xbox360ToBedrockButton.isHidden = true
        self.xbox360ToJavaButton.isHidden = true
    }
    
    @objc func javaToBedrockButtonDidTouchUpInside(_ sender: AnyObject) {
        disableButtons()
        let vc = ChooseInputViewController(type: .javaToBedrock,
                                           message: gettext("Choose a zip file of Java Edition world data"),
                                           contentTypes: [UTType.zip])
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func bedrockToJavaButtonDidTouchUpInside(_ sender: AnyObject) {
        disableButtons()
        let contentTypes: [UTType]
        if let mcworld = UTType(filenameExtension: "mcworld") {
            contentTypes = [mcworld]
        } else {
            contentTypes = [UTType.data]
        }
        let vc = ChooseInputViewController(type: .bedrockToJava,
                                           message: gettext("Choose an mcworld file"),
                                           contentTypes: contentTypes)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func xbox360ToBedrockButtonDidTouchUpInside(_ sender: AnyObject) {
        
    }
    
    @objc func xbox360ToJavaButtonDidTouchUpInside(_ sender: AnyObject) {
        
    }
    
    private func disableButtons() {
        self.javaToBedrockButton.isEnabled = false
        self.bedrockToJavaButton.isEnabled = false
        self.xbox360ToJavaButton.isEnabled = false
        self.xbox360ToBedrockButton.isEnabled = false
    }
    
    private func enableButtons() {
        self.javaToBedrockButton.isEnabled = true
        self.bedrockToJavaButton.isEnabled = true
        self.xbox360ToJavaButton.isEnabled = true
        self.xbox360ToBedrockButton.isEnabled = true
    }
}

extension ModeSelectViewController: ChooseInputViewDelegate {
    func chooseInputViewDidChoosen(sender: ChooseInputViewController, type: ConversionType, url: URL) {
        sender.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            let converter: Converter
            switch type {
            case .javaToBedrock:
                converter = ConvertJavaToBedrock()
            default:
                return
            }
            self.presentProgressWith(input: url, converter: converter)
        }
    }
    
    func chooseInputViewDidCancel() {
        enableButtons()
    }
    
    private func presentProgressWith(input: URL, converter: Converter) {
        let vc = ProgressViewController(input: input, converter: converter)
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension ModeSelectViewController: ProgressViewDelegate {
    func progressViewWillDisappear() {
        enableButtons()
    }
}
