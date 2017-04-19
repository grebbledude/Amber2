//
//  FloatPrayerButton.swift
//  AmberLight
//
//  Created by Pete Bennett on 23/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit

class FloatPrayerButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    weak var mDelegate: UIViewController?
    public init(delegate: UIViewController, parent: UIView, count: Int) {
        super.init(frame: .zero)
        mDelegate = delegate
        let frame = parent.frame
        let parentDim = min(frame.width,frame.height)
        let myDim = min(150,parentDim / 4)
        self.frame = CGRect(x: frame.width-myDim, y: frame.height - myDim, width: myDim, height: myDim)
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.layer.backgroundColor =  UIColor.green.cgColor
        self.clipsToBounds = true
        setBadge(count: count)
        self.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        parent.addSubview(self)
    }
    public func setBadge (count: Int) {
        let image = UIImage(named: "prayer.png")!
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let textPoint = CGPoint(x: 62.0, y: 8.0)
        
        let rect = CGRect(origin: textPoint, size: CGSize(width: 15.0, height: 15.0))
        String(count).draw(in: rect, withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, scale)
        let newRect = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        newImage!.draw(in: newRect)
        self.setImage(UIGraphicsGetImageFromCurrentImageContext(), for: .normal)
        UIGraphicsEndImageContext()
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonPressed() {
        mDelegate!.performSegue(withIdentifier: "respondSegue", sender: mDelegate!)
    }
    
}
