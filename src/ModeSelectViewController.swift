import UIKit

func gettext(_ s: String) -> String {
    return s
}

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
        self.bedrockToJavaButton.setTitle(gettext("Bedrock to Java"), for: .normal)
        self.xbox360ToBedrockButton.setTitle(gettext("Xbox360 to Bedrock"), for: .normal)
        self.xbox360ToJavaButton.setTitle(gettext("Xbox360 to Java"), for: .normal)
    }
}
