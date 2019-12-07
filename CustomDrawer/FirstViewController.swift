import UIKit

class FirstViewController: UIViewController, Contained {

    var currentNotch: Notch = .maximized
    var supportedNotches: [Notch] = [.minimized, .medium, .maximized]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "First"
        view.backgroundColor = .systemPink
        
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.addTarget(self, action: #selector(nexty), for: .touchUpInside)
        btn.frame.origin = CGPoint(x: 50, y: 50)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        btn.tintColor = .black
        btn.sizeToFit()
        view.addSubview(btn)
    }
    @objc func nexty(){
        self.navigationController?.pushViewController(SecondViewController(), animated: true)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        view.frame.size.height = parent?.view.frame.height ?? 0
    }
    
}
