//
//  NoNotificationController.swift
//  AmberLight
//
//  Created by Pete Bennett on 21/04/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit
import UserNotifications
/*
 This is used in case the user has not allowed notifications.  Without them the app won't work
 */

class NoNotificationController: UIViewController, Refreshable {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func releaseData() {
        
    }
    func refreshData() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings(
                completionHandler: {settings in
                    if settings.authorizationStatus == .authorized {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.setupInitialScreen()
                    }
                    })
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
