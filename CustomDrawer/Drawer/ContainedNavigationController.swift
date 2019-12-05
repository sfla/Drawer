import UIKit

class ContainedNavigationController:UINavigationController, Contained, UINavigationControllerDelegate{
    var currentNotch: Notch = .maximized
    var supportedNotches: [Notch] = [.minimized, .medium, .maximized]
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        delegate = self
        view.clipsToBounds = false
    }
    
    @objc func handleSwipe(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let gestureRecognizerView = gestureRecognizer.view else {
            self.interactionController = nil
            return
        }
        
        let percent = gestureRecognizer.translation(in: gestureRecognizerView).x / gestureRecognizerView.bounds.size.width

        if gestureRecognizer.state == .began {
            if gestureRecognizer.location(in: self.view).x > 50 {
                gestureRecognizer.isEnabled = false
                gestureRecognizer.isEnabled = true
                return
            }
            
            self.interactionController = UIPercentDrivenInteractiveTransition()
            popViewController(animated: true)
        } else if gestureRecognizer.state == .changed {
            self.interactionController?.update(percent)
        } else if gestureRecognizer.state == .ended {
            if percent > 0.5 && gestureRecognizer.state != .cancelled {
                self.interactionController?.finish()
            } else {
                self.interactionController?.cancel()
            }
            self.interactionController = nil
        }
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
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return TransitionAnimator(presenting: true)
        case .pop:
            return TransitionAnimator(presenting: false)
        default:
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
}

final class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(UINavigationController.hideShowBarDuration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }

        let duration = transitionDuration(using: transitionContext)

        let container = transitionContext.containerView
        if presenting {
            container.addSubview(toView)
        } else {
            container.insertSubview(toView, belowSubview: fromView)
        }

        let toViewFrame = toView.frame
        toView.frame = CGRect(x: presenting ? toView.frame.width : -toView.frame.width, y: toView.frame.origin.y, width: toView.frame.width, height: toView.frame.height)
        
        UIView.animate(withDuration: duration, animations: {
            toView.frame = toViewFrame
            fromView.frame = CGRect(x: self.presenting ? -fromView.frame.width : fromView.frame.width, y: fromView.frame.origin.y, width: fromView.frame.width, height: fromView.frame.height)
        }) { (finished) in
            container.addSubview(toView)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
