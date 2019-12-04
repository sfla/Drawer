import UIKit

class SecondViewController:UIViewController, Contained{
    var currentNotch: Notch = .medium
    var supportedNotches: [Notch] = [.minimized, .medium, .maximized]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second"
        view.backgroundColor = .green
    }
}
