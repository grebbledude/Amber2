//
//  PageNumbrViewController.swift
//  testsql
//
//  Created by Pete Bennett on 11/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import Foundation

private var tagAssociationKey: UInt8 = 0
/*
extension UIViewController {
    public var tag1: String! {
        get {
            return objc_getAssociatedObject(self, &tagAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tagAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
} */
class TagViewController: UIViewController {
    public var tag: String?
}
class PagingViewController: UIViewController {
    public var pageNum: Int?
    
}

protocol ExpandableHeaderDelegate {
    func sectionHeaderView (expanded: Bool, section: Int)
}

protocol DismissalDelegate : class
{
    func finishedShowing(viewController: UIViewController);
}

protocol Dismissable : class
{
    weak var dismissalDelegate : DismissalDelegate? { get set }
}



extension DismissalDelegate where Self: UIViewController
{
    func finishedShowing(viewController: UIViewController) {
        if    (((viewController as? Dismissable)?.dismissalDelegate = self) != nil)
        {
            print ("dismiss now")
            self.dismiss(animated: true, completion: nil)
            return
        }
        viewController.dismiss(animated: true, completion: nil)
    }
}
enum AnimDirection: Int  {
    case left = -1
    case right = 1
}
enum MyStory: String {
    case Maintenance = "Maintenance"
    case Registration = "Registration"
    case Checkin = "Checkin"
}

extension UIWindow {
    /// Returns the currently visible view controller if any reachable within the window.
    public var visibleViewController: UIViewController? {
        return UIWindow.visibleViewController(from: rootViewController)
    }
    
    /// Recursively follows navigation controllers, tab bar controllers and modal presented view controllers starting
    /// from the given view controller to find the currently visible view controller.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to start the recursive search from.
    /// - Returns: The view controller that is most probably visible on screen right now.
    public static func visibleViewController(from viewController: UIViewController?) -> UIViewController? {
        switch viewController {
        case let navigationController as UINavigationController:
            return UIWindow.visibleViewController(from: navigationController.visibleViewController)
            
        case let tabBarController as UITabBarController:
            if let vc = tabBarController.selectedViewController {
                return UIWindow.visibleViewController(from: vc)
            } else {
                return UIWindow.visibleViewController(from: tabBarController.viewControllers![0])
            }
            
        case let presentedViewController where viewController?.presentedViewController != nil:
            return UIWindow.visibleViewController(from: presentedViewController)
            
        default:
            return viewController
        }
    }
}
protocol Refreshable {
    func refreshData()  // When returning from background mode the status may have changed.
    func releaseData()  // so might as well release table view data when entering background mode
}
protocol Lockable {
    func viewDidLoad()
}
extension String { // allows us to treat strings as arrays of charcaters and use length, [] and substring
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
    
}
extension UIAlertController {
    static func displayOK(viewController: UIViewController, title: String, message: String, preferredStyle: UIAlertControllerStyle, handler: @escaping (_: UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        viewController.present(alert, animated: true, completion: nil)
    }
    static func displayOK(viewController: UIViewController, title: String, message: String, preferredStyle: UIAlertControllerStyle) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func displayOKCancel(viewController: UIViewController, title: String, message: String, preferredStyle: UIAlertControllerStyle, handler: @escaping (_: UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }


}
