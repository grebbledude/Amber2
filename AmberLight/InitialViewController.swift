//
//  InitialViewController.swift
//  AmberLight
//
//  Created by Pete Bennett on 04/05/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit
import UserNotifications
/*
 So that we don't have the splash screen for too long we move to this screen to animate and do processing of initial setup.
 */

class InitialViewController: UIViewController {
    var mAuthorised: Bool!
    var mWaitingCount: Int?
    var mImageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            mAuthorised = false
            mWaitingCount = 2
            let authOptions: UNAuthorizationOptions = [.alert, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {granted, error in
                    if granted {
                        self.mAuthorised = true
                    }
                    self.gotResponse()
            })
        } else {
            mWaitingCount = 1
            mAuthorised = true
        }
        
            // For iOS 10 display notification (sent via APNS)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        Theme.clearNavBar(viewController: self)
        mImageView = UIImageView(image: UIImage(named: "hole5"))
        mImageView?.contentMode = .scaleAspectFit
        let frameSize = self.view.frame.size
        let x = frameSize.width
        let y = frameSize.height
        var frame = mImageView!.frame
        let ratio = frame.width / frame.height
        if ratio > x/y {
            frame.size.height = y * 2.5
            frame.size.width = frame.size.height * ratio
        } else {
            frame.size.width = x * 2.5
            frame.size.height = frame.size.width / ratio
        }
        mImageView!.frame = frame
        
        self.view.addSubview(mImageView!)
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        // animate
        _  = Theme(self)
        let viewX = mImageView!.frame.size.width
        let viewY = mImageView!.frame.size.height
        let frameX = view.frame.size.width
        let frameY = view.frame.size.height
        let targets: [[CGFloat]] = [ [0.5,0.3], [-0.3, -0.2], [0.05,0.02], [0.0,0.0]]  // This shows the path of the hole
        for i in 0...(targets.count - 1) {
            UIView.animate(withDuration: 1.0, delay: Double(i) * 1.0, options: [], animations: {
                let frame = CGRect(x: self.calcPos(viewSize: viewX, frameSize: frameX, position: targets[i][0]),
                                   y: self.calcPos(viewSize: viewY, frameSize: frameY, position: targets[i][1]),
                                   width: self.mImageView!.frame.width, height: self.mImageView!.frame.height)
                self.mImageView!.frame = frame
            }, completion: nil)
        }
        
    

        UIView.animate(withDuration: 2.0, delay: Double(targets.count), options: [], animations: {
            self.mImageView!.alpha = 0
        }, completion: { (finished: Bool) in
            self.gotResponse()
        })
    }
    func calcPos(viewSize: CGFloat, frameSize: CGFloat, position: CGFloat) -> CGFloat{
        let midPoint = (viewSize - frameSize) / 2.0
        return -midPoint - (midPoint * position)
    }
    func gotResponse() {
        /*
         Waiting for both the animation to finish and potentially for the response from the request of authorisation (IOS 10)
         Only when both are done can we transition to the next screen
        */
        mWaitingCount! -= 1
        if mWaitingCount == 0 {
            if mAuthorised {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.setupInitialScreen()
            } else {
                AppDelegate.setupNavigation(target: "NoAuth", storyboard: .Registration)

            }

        }
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
