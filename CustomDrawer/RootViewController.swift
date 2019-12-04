import UIKit

class RootViewController: UIViewController {

    let drawer = Drawer(containedViewController: ContainedNavigationController(rootViewController: FirstViewController()))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
        view.addSubview(drawer)
        
    }
}
