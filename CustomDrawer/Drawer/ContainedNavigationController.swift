import UIKit

class ContainedNavigationController:UINavigationController, Contained, UINavigationControllerDelegate{
    var currentNotch: Notch = .maximized
    var supportedNotches: [Notch] = [.minimized, .medium, .maximized]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        view.clipsToBounds = false
    }
    
    private var controllers = [UIViewController]()
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        controllers = viewControllers
    }
    
    private func updateHeights(to height: CGFloat, willShow controller: UIViewController) {
        controller.view.frame.size.height = height
        _ = controllers.map { $0.view.frame.size.height = height }
        
        // TODO: Find a better way to update UIParallaxDimmingView
        guard controllers.contains(controller) else { return }
        _ = controller.view.superview?.superview?.subviews.map {
            guard "_UIParallaxDimmingView" == String(describing: type(of: $0)) else { return }
            $0.frame.size.height = height
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let superHeight = view.superview?.superview?.bounds.size.height, let drawer = (view.superview as? Drawer), let targetHeight = (viewController as? Contained)?.currentNotch.height(availableHeight: superHeight){
            
            transitionCoordinator?.animate(alongsideTransition: { (context) in
                drawer.heightConstraint.constant = targetHeight
                drawer.superview?.layoutIfNeeded()
                
                self.updateHeights(to: targetHeight, willShow: viewController)
            }, completion: { (context) in
                self.updateHeights(to: targetHeight, willShow: viewController)
            })
        }
    }
    
}
