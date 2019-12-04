import UIKit

class ContainedNavigationController:UINavigationController, Contained, UINavigationControllerDelegate{
    var currentNotch: Notch = .maximized
    var supportedNotches: [Notch] = [.minimized, .medium, .maximized]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        view.clipsToBounds = false
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let superHeight = view.superview?.superview?.bounds.size.height, let drawer = (view.superview as? Drawer), let targetHeight = (viewController as? Contained)?.currentNotch.height(availableHeight: superHeight){
            
            transitionCoordinator?.animate(alongsideTransition: { (context) in
                drawer.heightConstraint.constant = targetHeight
                drawer.superview?.layoutIfNeeded()
            }, completion: { (context) in
                print("Transition complete")
            })
        }
    }
    
}
