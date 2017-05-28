//
//  Theme.swift
//  AmberLight
//
//  Created by Pete Bennett on 22/04/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import Foundation
import UIKit
extension UIButton {
    var titleLabelFont: UIFont! {
        get { return self.titleLabel?.font }
        set { self.titleLabel?.font = newValue }
    }
}

class Theme {
    let font: UIFont
    init( _ vc: UIViewController) {
        
        if vc.traitCollection.horizontalSizeClass == .regular {
            font = UIFont(name: "Kailasa", size: 25)!
        } else {
            font = UIFont(name: "Kailasa", size: 17)!
        }
        
        navBar()
        tableView()
        label()
        button()
        barItem()
        tabBar()
        textView()
        pageControl()
    }
    func navBar() {
        
        
       // UINavigationBar.appearance().barStyle = UIBarStyle.black
  //      UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
  //      UINavigationBar.appearance().backgroundColor = .clear
  //      UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent =  true
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [ NSFontAttributeName: font]

        
    }
    func tableView() {
        
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorColor = .white
 //       let colorView = UIView()
        UITableViewCell.appearance().selectionStyle = .none
//        colorView.backgroundColor = UIColor.white  // This didn't work well for multiselect
//        colorView.alpha = 0.2
//        UITableViewCell.appearance().selectedBackgroundView = colorView
    }
    func label() {
        UILabel.appearance().font = font
    }
    func button() {
 //       UILabel.appearance(whenContainedInInstancesOf: UIButton.self).font = font
        UIButton.appearance().titleLabelFont = font
    }
    func tabBar() {
        UITabBar.appearance().tintColor = .yellow
        UITabBar.appearance().barTintColor = .black
        
    }
    func barItem() {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font], for: .normal)
  //      UIBarButtonItem.appearance().setTitleTextAttributes([ NSFontAttributeName: font], for: .normal)
    }
    func textView() {
        UITextField.appearance().font = font
    }
    func pageControl() {
        UIPageControl.appearance().pageIndicatorTintColor = .black
        UIPageControl.appearance().currentPageIndicatorTintColor = .white
    }
    // This is called by all "Themed" view controllers and navigation controller via the swizzling.
    static func layerGradient(viewController: UIViewController) {
        let view = viewController.view!
        let red = UIColor(red: 190.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.7)
        let amber = UIColor(red: 255.0/255.0, green: 191.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        let green = UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        view.layer.sublayers = view.layer.sublayers?.filter(){!($0 is CAGradientLayer)}
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = view.frame.size
        layer.frame.origin = CGPoint.zero
        layer.colors = [red.cgColor,amber.cgColor, amber.cgColor,amber.cgColor,green.cgColor, green.cgColor]
        view.layer.insertSublayer(layer, at: 0)
    }
    // gets called automatically for views in a navigation controller, but otherwise is called manually to clear the contents and navigation bar
    static func clearNavBar(viewController: UIViewController) {
        
        if let navBar = viewController.navigationController?.navigationBar {
            navBar.setBackgroundImage(UIImage(), for: .default)
            navBar.shadowImage = UIImage()
            navBar.isTranslucent = true
        }
    }
    static func dialog(alertController: UIAlertController) {
        
        //  nothing to do at the moment
    }
    // specific to the buttons on the checkin page,
    static func checkinButton (button: UIButton) {
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
    }
    static func setCellLayer(view: UIView, selected: Bool) {
        
        view.layer.sublayers = view.layer.sublayers?.filter(){!($0 is CAShapeLayer)}
        if selected {
            let layer = CAShapeLayer()
            layer.path = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: view.frame.size), cornerRadius: 5).cgPath
            layer.fillColor = UIColor.clear.cgColor
            layer.opacity = 0.2
            layer.fillColor = UIColor(colorLiteralRed: 255.0, green: 255.0, blue: 255.0, alpha: 0.1).cgColor
            layer.strokeColor = UIColor.black.cgColor
            layer.lineWidth = 2.0
            view.layer.addSublayer(layer)
        }
        
    }
}
