
import Foundation
import UIKit

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else { return }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    @objc static func instantiateFromNib() -> Self {
        let name = self.getClassName()
        return self.init(nibName: name, bundle: nil)
    }
    
    static func instantiateFromStoryBoard() -> Self {
        let vcName = self.getClassName()
        return UIStoryboard.init(name:vcName, bundle: Bundle.main).instantiateViewController(withIdentifier: vcName) as! Self
    }
}

extension NSObject {
    func getClassName() -> String {
        return String(describing: type(of: self))
    }
    class func getClassName() -> String {
        return String(describing: self)
    }
}

enum SelectionType: Int {
    case single
    case multiple
}

extension UIView {
    func addCornerRadius(radius: CGFloat = 6) {
        self.layer.cornerRadius     = radius
        self.layer.masksToBounds    = true
    }
}
