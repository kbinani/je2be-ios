import UIKit
import UniformTypeIdentifiers

class MainViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var javaToBedrockButton: UIButton!
    @IBOutlet weak var bedrockToJavaButton: UIButton!
    @IBOutlet weak var xbox360ToBedrockButton: UIButton!
    @IBOutlet weak var xbox360ToJavaButton: UIButton!
    @IBOutlet weak var drawer: UIView!
    @IBOutlet weak var drawerTouchDetector: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var drawerCloseButon: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var aboutButton: UIButton!
    
    private var isDrawerShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.text = gettext("Select conversion mode")
        
        self.menuButton.setTitle("", for: .normal)
        self.menuButton.addTarget(self, action: #selector(menuButtonDidTouchUpInside(_:)), for: .touchUpInside)
        
        self.drawerCloseButon.addTarget(self, action: #selector(drawerCloseButtonDidTouchUpInside(_:)), for: .touchUpInside)
        self.drawerCloseButon.setTitle(gettext("Back"), for: .normal)
        
        self.aboutButton.setTitle(gettext("About"), for: .normal)
        self.aboutButton.addTarget(self, action: #selector(aboutButtonDidTouchUpInside(_:)), for: .touchUpInside)
        
        self.versionLabel.text = "je2be-ios " + ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "(local)")
        
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
    
    @IBAction func drawerTouchDetectorDidTap(_ sender: Any) {
        closeDrawer()
    }
    
    @IBAction func drawerTouchDetectorDidPan(_ sender: UIPanGestureRecognizer) {
        closeDrawer()
    }
    
    @objc private func menuButtonDidTouchUpInside(_ sender: UIButton) {
        openDrawer()
    }

    @IBAction func screenEdgeDidPan(_ sender: Any) {
        openDrawer()
    }
    
    @IBAction func drawerCloseButtonDidTouchUpInside(_ sender: UIButton) {
        closeDrawer()
    }
    
    private func openDrawer() {
        guard !isDrawerShown else {
            return
        }
        isDrawerShown = true

        self.drawer.transform = .init(translationX: -self.drawer.bounds.width, y: 0)
        self.drawerTouchDetector.alpha = 0
        self.drawerTouchDetector.isHidden = false
        self.screenEdgePanGestureRecognizer.isEnabled = false
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            self.drawer.transform = .identity
            self.drawerTouchDetector.alpha = 1
        }
        self.drawer.isHidden = false
    }
    
    private func closeDrawer() {
        guard isDrawerShown else {
            return
        }
        isDrawerShown = false

        self.drawer.transform = .identity
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            self.drawer.transform = .init(translationX: -self.drawer.bounds.width, y: 0)
            self.drawerTouchDetector.alpha = 0
        } completion: { done in
            if done {
                self.drawer.isHidden = true
                self.drawer.transform = .identity
                self.drawerTouchDetector.isHidden = true
                self.screenEdgePanGestureRecognizer.isEnabled = true
            }
        }
    }
    
    @objc private func aboutButtonDidTouchUpInside(_ sender: UIButton) {
        let vc = AboutViewController()
        self.present(vc, animated: true)
    }
}

extension MainViewController: ChooseInputViewDelegate {
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

extension MainViewController: ProgressViewDelegate {
    func progressViewWillDisappear() {
        enableButtons()
    }
}
