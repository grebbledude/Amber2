//
//  NotificationHandler.swift
//  testsql
//
//  Created by Pete Bennett on 13/12/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationHandler {
    static public let DAY = 24 * 3600.0
    public static func setTimer() {
        let status = MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS)
        if (status == MyPrefs.STATUS_ACTIVE  || status == MyPrefs.STATUS_GR_ASSIGN
                || status == MyPrefs.STATUS_ANON  || status == MyPrefs.STATUS_ANON_DONE) {
            let startDate: Int = {
                if MyPrefs.getPrefInt(preference: MyPrefs.ANON_START) > 0 {
                    return MyPrefs.getPrefInt(preference: MyPrefs.ANON_START)
                } else {
                    return MyPrefs.getPrefInt(preference: MyPrefs.STARTDATE)
                }
            }()
            print ("checking notifications for \(startDate)")
            var timeS = CheckInController.getCalDate(date: startDate).timeIntervalSinceReferenceDate
            let maxTime = timeS + (41 * NotificationHandler.DAY)
            let currentTimeS = Date().timeIntervalSinceReferenceDate
            let dayDiff = Int(floor((currentTimeS - timeS) / NotificationHandler.DAY))
            switch dayDiff {
            case -10 ... -2:
                let days = max(-2,dayDiff + 1)  // This will either be -1 or -2 now
                timeS = timeS + Double(days) * DAY  // days is negative
                scheduleNotification(key: "Soon", title: "Amber Light", body: "First checkin in \(days) days time", at: Date(timeIntervalSinceReferenceDate: timeS), withSound: false)
            case -1 ... 39 :
                var baseTime = timeS + (Double(dayDiff) * NotificationHandler.DAY)
                //  Base time is the 18:00 time for the current checkin day.  That might be yesterday in
                // normal speak, or may be before the actual start date.
                if baseTime < timeS {  // this is day -1, so add 24 hours (we don't want reminders every hour for checkin yet)
                    baseTime += NotificationHandler.DAY
                }
                let lastCheckinDate = MyPrefs.getPrefInt(preference: MyPrefs.LAST_CHECKIN)
                let lastCheck = lastCheckinDate == 0 ? 0 : CheckInController.getCalDate(date: lastCheckinDate).timeIntervalSinceReferenceDate
                if lastCheck == baseTime {  // have checked in today - add 24 hours
                    baseTime += NotificationHandler.DAY
                }
                var notifyTimes: [Int] = []
                for key in [MyPrefs.NOTIF_6,MyPrefs.NOTIF_7,MyPrefs.NOTIF_8,MyPrefs.NOTIF_9,MyPrefs.NOTIF_10,MyPrefs.NOTIF_11, MyPrefs.NOTIF_12] {
                    notifyTimes.append(MyPrefs.getPrefInt(preference: key))
                }
                var sound = false
                for i in 0 ... 6 {
                    if notifyTimes[i] == 2 {  // 2 = no notification
                        cancelNotification(key: "Checkin" + String(i))
                    } else {
                        var time = baseTime + Double(i * 3600)
                        if time < currentTimeS {
                            time += NotificationHandler.DAY
                        }
                        sound = notifyTimes[i] == 0
                        let body =  "Time to check in"
                        let title = "Amber Light"
                        if time < maxTime {
                            let dx = Date(timeIntervalSinceReferenceDate: time)
                            print("Am about to schedule at " + dx.description)
                            scheduleNotification(key: "Checkin" + String(i), title: title, body: body, at: Date(timeIntervalSinceReferenceDate: time), withSound:  sound)
                        }
                    }
                }
                var missedTime = baseTime + (16 * 3600.0)
                if missedTime < currentTimeS {
                    missedTime += NotificationHandler.DAY
                }
                let body = " Checkin missed"
                let title = "Amber Light"
                if missedTime < maxTime {
                    scheduleNotification(key: "Missed", title: title, body: body, at: Date(timeIntervalSinceReferenceDate: missedTime), withSound: false)
                }
            default:
                return // outside range
            }
        
        }
    }
    private static func scheduleNotification (key: String, title: String, body: String, at date: Date, withSound sound: Bool) {
        if #available(iOS 10.0, *) {
            scheduleIOS10Notification(key: key, title: title,  body: body, at: date, withSound: sound)
        } else {
            // Fallback on earlier versions
            scheduledIOS9Notification(key: key, title: title, body: body, at: date, withSound: sound)
        }
    }
    
    private static func cancelNotification (key: String) {
        if #available(iOS 10.0, *) {
            cancelIOS10Notification(key: key)
        } else {
            // Fallback on earlier versions
            cancelIOS9Notification(key: key)
        }
    }

    @available(iOS 10.0, *)
    private static func cancelIOS10Notification(key: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [key])
    }

    
    @available(iOS 10.0, *)
    private static func scheduleIOS10Notification(key: String, title: String, body: String, at date: Date, withSound: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [key])
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if withSound {
            content.sound = UNNotificationSound.default()
        }
        let ct = Date()
        let ctC = ct.timeIntervalSinceReferenceDate
        let tt = date.timeIntervalSinceReferenceDate
        let current = Date().timeIntervalSinceReferenceDate   // Current date in seconds since ref date
        let triggerTime = date.timeIntervalSinceReferenceDate - current  //  Time between now and target time
        print (ct, ctC, date, tt, triggerTime)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)
        let request = UNNotificationRequest(identifier: key, content: content, trigger: trigger) // Schedule the notification.

        center.add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    private static func cancelIOS9Notification(key: String) {
        let application = UIApplication.shared
        if let notifications = application.scheduledLocalNotifications {
            for not in notifications {
                if let notif = not.userInfo!["key"] {
                    if String(describing: notif) == key {
                        application.cancelLocalNotification(not)
                    }
                }
            }
        }
    }

    private static func scheduledIOS9Notification(key: String,  title: String, body: String, at date: Date, withSound: Bool) {
        let application = UIApplication.shared
        if let notifications = application.scheduledLocalNotifications {
            for not in notifications {
                if let _ = not.userInfo!["key"] {
                    if String(describing: not.userInfo!["key"]!) == key {
                        application.cancelLocalNotification(not)
                    }
                }
            }
        }
        let notification = UILocalNotification()
        notification.alertTitle = title
        notification.alertBody = body
 //       notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        if withSound {
            notification.soundName = UILocalNotificationDefaultSoundName
        }
        notification.fireDate = date
        notification.userInfo = ["key": key] // assign a unique identifier to the notification so that we can retrieve it later
        application.scheduleLocalNotification(notification)
    }
    public static func cancelAllNotifications () {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
            // Fallback on earlier versions
        }
        
    }

}
