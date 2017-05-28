//
//  LaunchControllertoDelete.swift
//  testsql
//
//  Created by Pete Bennett on 06/01/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit
import FirebaseDatabase

// To be DELETED
// To be DELETED
// To be DELETED
// To be DELETED
// To be DELETED
// To be DELETED
// To be DELETED
// To be DELETED
// To be DELETED
// To be DELETED
// To be DELETED
// To be DELETED

class LaunchControllertoDelete: UIViewController {
    
    private static let SEGUE_REGISTRATION = "Registration"
    private static let SEGUE_STATUS = "Status"
    private static let SEGUE_ADMIN = "Admin"
    private static let SEGUE_EVENTS = "Events"


    private var mWaiting = false
    private var mCongregation: String?
    private var mTask: DispatchWorkItem? = nil
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var tlNameLabel: UILabel!
    @IBOutlet weak var tlContactLabel: UILabel!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var instLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBAction func newAdmin(_ sender: UIButton) {
        let alert = UIAlertController(title: "Enter contact", message: "Enter name and phone number", preferredStyle: .alert)
        
        /* 
         The following code enables us to validate the data input into an alert dialog before we return from that dialog.
         In this case, check that the code is not too long.
            */
        //2. Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "Congregation"
        })
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        let action = (UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            self.mCongregation = alert!.textFields![0].text!.uppercased() // Force unwrapping because we know it exists.
            if self.mCongregation!.characters.count > 4 && self.mCongregation!.characters.count < 10 {  // Should make sure it starts alphabetic
                //  Now set a timer for 6 seconds and then check the code asynchronously
                let deadlineTime = DispatchTime.now() + .seconds(6)
                self.mWaiting = true
                if let task = self.mTask {
                    task.cancel()
                }
                self.mTask = DispatchWorkItem {
                    self.mTask = nil
                    self.gotCode("", .REG_CODE_TIMEOUT)
                }
                DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: self.mTask!)
                RegistrationController.generateCode(type: .REG_CODE_ADMIN, callback: self.gotCode)
            }

        }))
        alert.addAction(action)
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        

    }
    @IBAction func Button1(_ sender: UIButton) {
        MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_INIT)
        performSegue(withIdentifier: LaunchControllertoDelete.SEGUE_REGISTRATION, sender: self)
    }
    @IBAction func Button2(_ sender: UIButton) {
        MyPrefs.setPref(preference: MyPrefs.I_AM_TEAMLEAD, value: false)
        performSegue(withIdentifier: LaunchControllertoDelete.SEGUE_STATUS, sender: self)
    }
    @IBAction func Button3(_ sender: UIButton) {
        MyPrefs.setPref(preference: MyPrefs.I_AM_ADMIN, value: true)
        performSegue(withIdentifier: LaunchControllertoDelete.SEGUE_ADMIN, sender: self)
    }
    @IBAction func Button4(_ sender: UIButton) {
        MyPrefs.setPref(preference: MyPrefs.I_AM_TEAMLEAD, value: true)
        performSegue(withIdentifier: LaunchControllertoDelete.SEGUE_EVENTS, sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        let thisStat = MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS)
        let sDate = MyPrefs.getPrefString(preference: MyPrefs.STARTDATE)
        tlNameLabel!.text = MyPrefs.getPrefString(preference: MyPrefs.TL_NAME)
        tlContactLabel!.text = MyPrefs.getPrefString(preference: MyPrefs.TL_CONTACT)
        let pseudonym = MyPrefs.getPrefString(preference: MyPrefs.PSEUDONYM)
        welcomeLabel!.text = "Welcome " + pseudonym
        var statusDesc: String?
        var instructions: String?
        var segueName: String?
        if MyPrefs.getPrefBool(preference: MyPrefs.I_AM_ADMIN) {
            statusDesc = "Admin"
            instructions = "You are registered as an administrator"
            segueName = LaunchControllertoDelete.SEGUE_ADMIN

        }
        else {
            if MyPrefs.getPrefBool(preference: MyPrefs.I_AM_TEAMLEAD) {
                statusDesc = "Team Lead"
                instructions = "You are registered as a Team leader"
                segueName = LaunchControllertoDelete.SEGUE_EVENTS
            }
            else {
                switch thisStat {
                case MyPrefs.STATUS_INIT:
                    statusDesc = "Initial setup"
                    instructions = "Enter a registration code that has been assigned to you as a congregation or by a team leader"
                    segueName = LaunchControllertoDelete.SEGUE_REGISTRATION
                case MyPrefs.STATUS_ACTIVE:
                    statusDesc = "Checkins are active"
                    instructions = "Make sure you checkin every day and pray for your team mates"
                    segueName = LaunchControllertoDelete.SEGUE_STATUS
                case MyPrefs.STATUS_OLD:
                    statusDesc = "40 days are over!"
                    instructions = "Great job, now walk in freedom!  Remember to talk to your team leader if you need more support"
                case MyPrefs.STATUS_REG_OK:
                    statusDesc = "Registration code ok"
                    instructions = "This status should be temporary.  Check after a few days to ensure you have been assigned a team leader"
                case MyPrefs.STATUS_REG_SENT:
                    statusDesc = "Waiting for confirmation of code "
                    instructions = "This should change almost immediately.  Check after 30 minutes and report if status doesn't change"
                case MyPrefs.STATUS_GR_ASSIGN:
                    statusDesc = "You are in a group!"
                    instructions = "You are now in a group.  You start checkins on " + String(sDate)
                    segueName = LaunchControllertoDelete.SEGUE_STATUS
                case MyPrefs.STATUS_REG_ERROR:
                    statusDesc = "Registration failed"
                    instructions = "This shouldn't have happened - please check the code and report"
                case MyPrefs.STATUS_REG_TL_OK:
                    statusDesc = "Waiting for team leader"
                    instructions = "Check after a couple of days to see which group you are assigned to"
                case MyPrefs.STATUS_REG_TL_ASS:
                    statusDesc = "Contact your team leader"
                    instructions = "Contact your team leader on the number above and give him your pseudonym " + pseudonym
                case MyPrefs.STATUS_REG_OK_TEMP:
                    statusDesc = "Registration in process"
                    instructions = "This is temporary, and we are waiting for your team leader's phone to confirm.  Please check in 24 hours"
                case MyPrefs.STATUS_REG_TL_ASS_TEMP:
                    statusDesc = "Assigning to a team leader"
                    instructions = "This should be a brief status.  Please check again in 24 hours"
                default:
                    statusDesc = "Who knows??"
                    instructions = "Somehow you are in an undefined state"
                }
            }
        }
        statusLabel!.text = statusDesc
        instLabel!.text = instructions
        if let segue = segueName {
            switchWithDelay(segue: segue)
        }
        
    }

    private func switchWithDelay (segue: String) {

        let deadlineTime = DispatchTime.now() + .seconds(9)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            if MyPrefs.getPrefBool(preference: MyPrefs.I_AM_ADMIN) {
                FcmMessage.builder(action: .ACT_GET_COUNT)
                    .addData(key: .CONGREGATION, data: MyPrefs.getPrefString(preference: MyPrefs.CONGREGATION))
                    .send()
            }
            self.performSegue(withIdentifier: segue, sender: self)
        })
    }
    public func gotCode(_ code: String, _ rc: RegCodeType) {
        if let task = mTask {
            task.cancel()
            mTask = nil
        }
        if mWaiting {
            if rc.rawValue > 0 {
                mWaiting = false
                self.code!.text = code

                UIApplication.shared.endIgnoringInteractionEvents()
                FcmMessage.builder(action: .ACT_NEW_CODE)
                    .addData(key: .REG_CODE, data: code)
                    .addData(key: .CONGREGATION, data: mCongregation!)
                    .addData(key: .REG_TYPE, data: RegCodeType.REG_CODE_ADMIN.rawValue)
                    .addData(key: .TEAM_LEADER, data: "none")
                    .send()
                let FIRDBRef = Database.database().reference(withPath: FcmMessage.FirebaseDBKey)
                
                FIRDBRef.child(self.mCongregation!).setValue([RegistrationController.FIRType: RegCodeType.REG_CODE_CHURCH.rawValue ])
                FcmMessage.builder(action: .ACT_NEW_CODE)
                    .addData(key: .REG_CODE, data: self.mCongregation!)
                    .addData(key: .CONGREGATION, data: self.mCongregation!)
                    .addData(key: .REG_TYPE, data: RegCodeType.REG_CODE_CHURCH.rawValue)
                    .addData(key: .TEAM_LEADER, data: "none")
                    .send()
               
            }
            else {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.mWaiting = false
                let alertController = UIAlertController(title: "Cannot get new code", message: "An error occured getting a new code.  Are you connected to the internet?", preferredStyle: .alert)
                
                
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                    (action : UIAlertAction!) -> Void in
                    
                })
                
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
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
