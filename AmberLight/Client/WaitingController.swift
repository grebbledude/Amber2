//
//  WaitingController.swift
//  AmberLight
//
//  Created by Pete Bennett on 29/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit

class WaitingController: UIViewController, Refreshable {

    @IBOutlet weak var statusLbl: UILabel!

    private static let ADMIN_SEGUE =  "adminSegue"
    private static let EVENT_SEGUE =  "eventSegue"
    private static let CHECKIN_SEGUE = "checkinSegue"
    private var mSegue = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = checkStatusSwitch()
    }
    override func viewDidAppear(_ animated: Bool) {
        if mSegue != "" {
            performSegue(withIdentifier: mSegue, sender: self)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        Theme.clearNavBar(viewController: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func releaseData() {
        // do nothing
    }
    func refreshData() {
        // Check for status change
        if checkStatusSwitch() {
            performSegue(withIdentifier: mSegue, sender: self)
        }
    }
    private func checkStatusSwitch() -> Bool {
        let status = MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS)
        switch status {
        case MyPrefs.STATUS_REG_ERROR:
            statusLbl.text = "We are really sorry about this, but something has gone wrong with your registration.  Please re-install the app and try again."
            return false
        case MyPrefs.STATUS_REG_OK:
            statusLbl.text = "Your registration request has been received.  Your congregation administrator will assign you to a team leader"
            return false
        case MyPrefs.STATUS_REG_SENT:
            statusLbl.text = "We are processing your registration request.  This should not take very long"
            return false
        case MyPrefs.STATUS_GR_ASSIGN:
            NotificationHandler.setTimer()
            let startOn = MyPrefs.getPrefInt(preference: MyPrefs.STARTDATE)
            let startDate = CheckInController.getCalDate(date: startOn)
            if startDate.compare(Date()) == .orderedAscending {
                MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_ACTIVE)
                statusLbl.text = "You are now in active status!"
                mSegue = WaitingController.CHECKIN_SEGUE
                return true
            }
            let formDate = CheckInController.formatDate(date: startOn)
            statusLbl.text = "You have been assigned a group.  Watch for notifications.  Your check-in periods starts \(formDate)"
            return false
        case MyPrefs.STATUS_REG_TL_OK:
            statusLbl.text = "You have been assigned a team leader.  He will assign you a group soon"
            return false
        case MyPrefs.STATUS_REG_TL_ASS:
            let contact = MyPrefs.getPrefString(preference: MyPrefs.TL_CONTACT)
            let name = MyPrefs.getPrefString(preference: MyPrefs.TL_NAME)
            let pseudonym = MyPrefs.getPrefString(preference: MyPrefs.PSEUDONYM)
            statusLbl.text = "You have been assigned a team leader \(name).  Currently he only knows you as \(pseudonym).  You must contact him to complete the registration - \(contact)"
            return false
        case MyPrefs.STATUS_REG_OK_TEMP, MyPrefs.STATUS_REG_TL_ASS_TEMP:
            statusLbl.text = "Your registration is still in progress.  Waiting for confirmation from your team lead"
            return false
//        case MyPrefs.STATUS_ADNIN_PENDING:
            // this seems to not be used.  Allow to default
//            break
        case MyPrefs.STATUS_ACTIVE:
            statusLbl.text = "You are now in active status!"
            if MyPrefs.getPrefBool(preference: MyPrefs.I_AM_ADMIN) {
                mSegue = WaitingController.ADMIN_SEGUE
            } else if MyPrefs.getPrefBool(preference: MyPrefs.I_AM_TEAMLEAD) {
                mSegue = WaitingController.EVENT_SEGUE
            } else {
                mSegue = WaitingController.CHECKIN_SEGUE
            }
            return true
        default:
            statusLbl.text = "Unexpected status " + status
        }
        return false
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
