import UIKit

class ChooseJavaInputViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.text = gettext("Choose a zip file of Java Edition world data")
        
        self.button.setTitle(gettext("Select"), for: .normal)
        self.button.addTarget(self, action: #selector(buttonDidTouchUpInside(_:)), for: .touchUpInside)
    }
    
    @objc func buttonDidTouchUpInside(_ sender: AnyObject) {
        
    }
}
