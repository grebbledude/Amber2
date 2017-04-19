//
//  AppDelegate.swift
//  testfcm
//
//  Created by Pete Bennett on 24/12/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import UserNotifications

import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var mForeground = true

    
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        
        let status = MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS)
        //  If this is the first time then do the intialisations
        if status == "" {
            AppDelegate.initialiseDB()
        }
        

        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]

        
        // Decide which is the initial screen
        
        setupInitialScreen()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.sendDataMessageFailure),
                                               name: .FIRMessagingSendError,
                                               object: nil)
        
        // and abservers for status changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkInitialLock),
                                               name:.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground),
                                               name:.UIApplicationDidEnterBackground, object: nil)
        
        if let token = FIRInstanceID.instanceID().token() {
            print (token)
        }

        //  Make sure that we have the necessary reminders set

        AppDelegate.setupNotifications()

        
        

        return true
    }
    
    //                          MARK: State changes
    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("State change: Application will enter foreground")

        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground),
                                               name:.UIApplicationDidEnterBackground, object: nil)
        if !mForeground {
            mForeground = true
            let vc = UIWindow.visibleViewController(from: self.window!.rootViewController)
            if let refresh = vc as? Refreshable {
                refresh.refreshData()
            }
        }
        checkInitialLock()
    }


    func applicationWillResignActive(_ application: UIApplication) {
        print("State change: Application will resign active")
        let ts = Date().timeIntervalSinceReferenceDate
        MyPrefs.setPref(preference: MyPrefs.LAST_UNLOCK, value: String(ts))
    }
    func didEnterBackground() {
        /*
        * Release observers.  Also if the application requires a refresh of the dat awhen we come back then 
        * we can release the data now
        */
        
        print("State change: did Enter Background")
        mForeground = false
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        let vc = UIWindow.visibleViewController(from: self.window!.rootViewController)
        if let refresh = vc as? Refreshable {
            refresh.releaseData()
        }
    }
    func applicationWillTerminate(_ application: UIApplication) {
        
        print("State change: Application will terminate")
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }

    func checkInitialLock() {

        let last = MyPrefs.getPrefString(preference: MyPrefs.LAST_UNLOCK)
        if last == "" {
            return
        }
        if (Date().timeIntervalSinceReferenceDate - Double(last)! > 600 ) {
            let vc = UIWindow.visibleViewController(from: self.window!.rootViewController)!
            if let _ = vc as? Lockable {
                let storyboard = UIStoryboard(name: MyStory.Registration.rawValue, bundle: nil)
                let ls = storyboard.instantiateViewController(withIdentifier: "lockScreen")
                vc.present(ls, animated: true, completion: nil)
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        print("State change: Application did become active")
        connectToFcm()
    }
    // [START disconnect_from_fcm]
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        print("State change: Application did enter background")
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    // [END disconnect_from_fcm]
    //                  MARK:  On application start
    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    

    // Switch the initial screen depending on status
    private func setupInitialScreen() {
        let status = MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS)
        let isTl = MyPrefs.getPrefBool(preference: MyPrefs.I_AM_TEAMLEAD)
        let isAdmin = MyPrefs.getPrefBool(preference: MyPrefs.I_AM_ADMIN)
        if isAdmin {
            if status == MyPrefs.STATUS_ACTIVE {
                if isTl {
                    AppDelegate.setupNavigation(target: "Admin", storyboard: .Maintenance)
                } else {
                    AppDelegate.setupNavigation(target: "Teamlead", storyboard: .Maintenance)
                }
            } else {
                AppDelegate.setupNavigation(target: "Waiting", storyboard: .Registration)
            }
        }
        else {
            if isTl {
                AppDelegate.setupNavigation(target: "Events", storyboard: .Maintenance)
            }
            else {
                switch status {
                case MyPrefs.STATUS_ACTIVE, MyPrefs.STATUS_GR_ASSIGN:
                    AppDelegate.setupNavigation(target: "CheckIn", storyboard: .Checkin)
                case MyPrefs.STATUS_ANON, MyPrefs.STATUS_ANON_DONE:
                    AppDelegate.setupNavigation(target: "AnonCheck", storyboard:  .Checkin)
                case MyPrefs.STATUS_INIT:
                    AppDelegate.setupNavigation(target: "intro", storyboard: .Registration)
                default:
                    AppDelegate.setupNavigation(target: "Waiting", storyboard: .Registration)
                }
            }
        }
    }
    static func setupNavigation(target: String, storyboard: MyStory) {
        let navigationController = UIApplication.shared.delegate?.window?!.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: target)
        // navigationController.pushViewController(viewController, animated: false)
        navigationController.setViewControllers([viewController], animated: false)
    }
    static func setupNotifications() {
        if (MyPrefs.getPrefBool(preference: MyPrefs.I_AM_TEAMLEAD)
            || MyPrefs.getPrefBool(preference: MyPrefs.I_AM_ADMIN)) {
            return    // no reminders for admins and team leads
        }
        NotificationHandler.setTimer()
    }
    //              MARK: Handle notifications
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
  //  handle data mand notification essages
    func processDataNotification (dataMessage: [AnyHashable: Any]){
        //  The first test should always be true
        print ("process notification")
        if UIApplication.shared.applicationState == .inactive {
            print ("was inactive") // Was inactive and user clicked on the message.  Don't display the message
            // but what happens if it was data and notification???
  //          xx
            return // already handled
        }
        if let aps = dataMessage["aps"] as? [AnyHashable: Any] {
            //  This next test would not be true for a striaght notification receive
            // we either will find content or it is an alert.  Technically it is possible to have both,
            // but a notification will trigger again if we click on it.
            
            if let contentAvailable = aps["content-available"] as? String {
                print ("found content \(contentAvailable)")
                if ( contentAvailable == "1" ) {
                    var fcmMessage: [String : String] = [:]
                    //  Data arrives as Object:Object.  Nede to convert to Strings.
                    for (key,data) in dataMessage {
                        if let keyS = key as? String {
                            if let dataS = data as? String {
                                fcmMessage[keyS] = dataS
                            }
                        }
                    }
                    FCMInbound().dataFound(payload: fcmMessage)

                   
                }
            }
            // Got a notification message whilst the application was active.  Need to do a pop up.
            if let msg = aps["alert"] as? [String: String] {
                let alertController = UIAlertController(title: msg["title"], message: msg["body"], preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                print("Doing a pop up alert")
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
        
    }



    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // This seems to trigger either when the application is foreground or when the user clicks on the notification
        // if the app was in the background
        print ("local notification")
        if application.applicationState == .inactive {
            print ("was inactive")
        }
    }
    @objc func sendDataMessageFailure(_ notification: NSNotification){
        print ("got an error \(notification)")

    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("Hooray! I'm registered!")
    }
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("First option Message ID: \(messageID)")
        }
        processDataNotification(dataMessage: userInfo)
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Second option Message ID: \(messageID)")
        }
        processDataNotification(dataMessage: userInfo)
        // Print full message.
        print(userInfo)
        
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]

    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return;
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error!)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        //Followwing line should only be required if swizzling disabled.
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
        print("Set APNS token")
    }
    

 

    static func initialiseDB() {
        MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_INIT)
        let dbt = DBTables()
        CheckInTable.create(db: dbt)
        PersonTable.create(db: dbt)
        QuestionTable.create(db: dbt)
        ResponseTable.create(db: dbt)
        AnswerTable.create(db: dbt)
        GroupTable.create(db: dbt)
        EventTable.create(db: dbt)
        TeamLeadTable.create(db: dbt)
        RequestTable.create(db: dbt)
        MessageTable.create(db: dbt)
        
        let _ = XMLReader(fileName: "questions", db: dbt)
        
        // Do any additional setup after loading the view.
    }
    
    

}
// MARK: IOS10
// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Third option Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        processDataNotification(dataMessage: userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Fourth option Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        processDataNotification(dataMessage: userInfo)
        completionHandler()
    }

    static func setupNotifications10() {
        let startDate = MyPrefs.getPrefInt(preference: MyPrefs.STARTDATE)
        if startDate == 0 {
            return
            
        }
        
        let center = UNUserNotificationCenter.current()
        var dayno = CheckInController.getDayNo(date: Date())
        if dayno > 40 {
            center.removePendingNotificationRequests(withIdentifiers: ["6","9","10","11"])
            return
        }
        let lastCheck = MyPrefs.getPrefInt(preference: MyPrefs.LAST_CHECKIN)
        let currentDate = CheckInController.getDate(date: Date())
        if lastCheck == currentDate {
            dayno += 1
        }
        let baseDate = CheckInController.getCalDate(date: startDate)
        let notificationDate = Calendar.current.date(byAdding: .day, value: dayno, to: baseDate)
        let content = UNMutableNotificationContent()
        content.title = "Amber Light Checkin"
        content.body = "Time to checkin for amber light"
        content.sound = UNNotificationSound.default()
        let triggerTime = notificationDate?.timeIntervalSinceNow

        for (offset,key) in [0.0 : "6" , 2.0 : "8" , 4.0 : "10" , 5.0 : "11"] {
            var alarmInterval = triggerTime! + (offset * 3600.0)
            if alarmInterval < 0.0 {
                alarmInterval += 3600.0*24.0
            }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: alarmInterval, repeats: false)
            let request = UNNotificationRequest(identifier: key, content: content, trigger: trigger)
            center.add(request) { (error) in
                print(error!)
            }
        }
    }
}

// [END ios_10_message_handling]
// [START ios_10_data_message_handling]
extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print ("IOS 10 option)")
        print(remoteMessage.appData)
        print ("This never seems to happen - so we will deliberately dump.  Application recevied remote message")
        let x = min(1, 0)
        _ = 1/x
    }
}
// [END ios_10_data_message_handling]

