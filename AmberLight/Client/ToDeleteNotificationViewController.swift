//
//  NotificationViewController.swift
//  testsql
//
//  Created by Pete Bennett on 11/12/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationViewController: UIViewController{
    @available(iOS 10.0, *)
    @IBAction  func triggerNotification(){
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Elon said:", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Hello Tom！Get up, let's play with Jerry!", arguments: nil)
        content.sound = UNNotificationSound.default()
 //       content.badge = UIApplication.shared().applicationIconBadgeNumber + 1;
        content.categoryIdentifier = "com.elonchan.localNotification"
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60.0, repeats: true)
        let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
        
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
    @available(iOS 10.0, *)
    @IBAction func stopNotification(_ sender: AnyObject) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        // or you can remove specifical notification:
        // center.removePendingNotificationRequests(withIdentifiers: ["FiveSecond"])
    }
    

    @available(iOS 10.0, *)
    func scheduleNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Hello!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Hello_message_body", arguments: nil)
        content.sound = UNNotificationSound.default() // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger) // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
        
/*        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Tutorial Reminder"
        content.body = "Just a reminder to read your tutorial over at appcoda.com!"
        content.sound = UNNotificationSound.default()
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
        print ("scheduled")
        exit(0)
*/
    }
    override func viewDidLoad() {
        super.viewDidLoad()
 /*       if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()

            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        } */
        // Do any additional setup after loading the view.

        let ts = Date().timeIntervalSinceReferenceDate
        let newDate = Date(timeIntervalSinceReferenceDate: ts+80)
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            
                
            }
            scheduleNotification(at: newDate)
        } else {
            // Fallback on earlier versions
            let notification = UILocalNotification()
            notification.alertBody = "Todo Item  Is Overdue" // text that will be displayed in the notification
            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            notification.fireDate = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate+5) // todo item due date (when notification will be fired) notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["title": "xx", "UUID": "xxx"] // assign a unique identifier to the notification so that we can retrieve it later
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
