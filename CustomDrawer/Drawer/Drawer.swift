import UIKit

enum Notch:Int{
    case hidden, minimized, medium, maximized, fullScreen
    
    func height(availableHeight:CGFloat)->CGFloat{
        switch self {
        case .hidden: return 0
        case .minimized: return 150
        case .medium: return availableHeight/2
        case .maximized: return availableHeight - 150
        case .fullScreen: return availableHeight
        }
    }
}

class Drawer: UIView {
    
    let containedViewController:UIViewController&Contained
    var heightConstraint:NSLayoutConstraint!
    let gesture = UIPanGestureRecognizer()
    
    init(containedViewController:UIViewController&Contained){
        self.containedViewController = containedViewController
        super.init(frame: .zero)
        setup()
    }
    required init?(coder: NSCoder) {fatalError()}
    
    private func setup(){
        backgroundColor = .clear
        gesture.addTarget(self, action: #selector(handleGesture(sender:)))
        addGestureRecognizer(gesture)
        
        containedViewController.loadViewIfNeeded()
        let cView = containedViewController.view!
        addSubview(cView)
        cView.translatesAutoresizingMaskIntoConstraints = false
        cView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        cView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        cView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        cView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        constraintToSuperview()
    }
    
    private func constraintToSuperview(){
        guard let s = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint?.isActive = false
        leadingAnchor.constraint(equalTo: s.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: s.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: s.bottomAnchor).isActive = true
        heightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.priority = UILayoutPriority(749)
        heightConstraint.isActive = true
        setNeedsLayout()
        layoutIfNeeded()
        go(to: containedViewController.currentNotch)
    }
    
    //MARK: Gesture
    
    private var startHeight:CGFloat = 0
    @objc func handleGesture(sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: nil)
        switch sender.state {
        case .began:
            startHeight = bounds.size.height
            if isDraggable(at: sender.location(in: superview)){
                dragOverlay(to: startHeight-translation.y)
            }else{
                sender.isEnabled = false
                sender.isEnabled = true
            }
        case .changed:
            let newHeight = startHeight-translation.y
            dragOverlay(to: newHeight)
            break
        case .failed, .ended:
            snapToNearestNotch(with: sender.velocity(in: nil))
            break
        default: break
        }
    }
    
    private func isDraggable(at startLocation:CGPoint)->Bool{
        return true
    }
    private func dragOverlay(to height:CGFloat){
        heightConstraint.constant = height
    }
    
    func go(to notch:Notch){
        guard let superview = superview else { return }
        let availableHeight = superview.bounds.size.height
        let targetHeight = notch.height(availableHeight: availableHeight)
        heightConstraint.constant = targetHeight
    }
    
    private func snapToNearestNotch(with velocity:CGPoint){
        guard let superview = superview else { return }
        let availableHeight = superview.bounds.size.height
        let currentHeight = bounds.size.height
        guard !containedViewController.supportedNotches.isEmpty else { return }
        
        let availableNotches = containedViewController.supportedNotches.flatMap({[$0:$0.height(availableHeight: availableHeight)]}).sorted { (n1, n2) -> Bool in
            return n1.value < n2.value
        }
        
        let targetNotch:Notch
        
        if velocity.y >= 0{
             targetNotch = availableNotches.reversed().first(where: {$0.value < currentHeight})?.key ?? availableNotches[0].key
        }else{
            targetNotch = availableNotches.first(where: {$0.value >= currentHeight})?.key ?? availableNotches.reversed()[0].key
        }
        
        print("Target notch was: ", targetNotch.rawValue, "h: ", targetNotch.height(availableHeight: availableHeight))
        
        
        let targetHeight = targetNotch.height(availableHeight:
        availableHeight)
        
        let heightGap = bounds.size.height - targetHeight
        
        let yVelocity = heightGap/velocity.y
        
        self.heightConstraint.constant = targetHeight
        
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: UISpringTimingParameters(dampingRatio: 1, initialVelocity: CGVector(dx: 0, dy: yVelocity)))
        
        animator.addAnimations {
            superview.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
    
}
