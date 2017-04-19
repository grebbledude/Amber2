//
//  PeopleMaintenance.swift
//  testsql
//
//  Created by Pete Bennett on 19/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class PeopleMaintenanceController: UIViewController, Dismissable, Lockable {
    static let QUEST_SEGUE = "questSegue"
    weak var dismissalDelegate : DismissalDelegate?

    @IBAction func pressCancel(_ sender: Any) {
        dismissalDelegate?.finishedShowing(viewController: self)
    }
    @IBAction func pressSave(_ sender: Any) {
        if nameTxt.text != "" {
            mPerson!.name = nameTxt.text
            if mPersonId == "" {
                let deadlineTime = DispatchTime.now() + .seconds(6)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                    self.gotCode("", .REG_CODE_TIMEOUT)
                })
                self.mWaiting = true
                RegistrationController.generateCode(type: .REG_CODE_CLIENT, callback: self.gotCode)
            }
            else {
                if mPerson!.status == PersonTable.STATUS_WAIT_CONTACT {
                    mPerson!.status = PersonTable.STATUS_WAIT_GROUP
                    FcmMessage.builder(action: .ACT_TL_CONFIRMED)
                        .addData(key: .PERSON_ID, data: mPerson!.id)
                        .send()
                }
                mPerson!.update(db: mDBT)
                
                dismissalDelegate?.finishedShowing(viewController: self)
            }
        }
    }
    @IBOutlet weak var qButton: UIBarButtonItem!
    @IBAction func pressQButton(_ sender: Any) {
        performSegue(withIdentifier: PeopleMaintenanceController.QUEST_SEGUE, sender: self)
    }
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var groupLbl: UILabel!
    @IBOutlet weak var psLBL: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var lastStatusLbl: UILabel!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var regLbl: UILabel!
    private let mDBT = DBTables()
    private var mPerson: PersonTable?
    private var mPersonId = ""
    private var mWaiting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idLbl.text = mPerson!.id
        psLBL.text  = mPerson!.pseudonym
        statusLbl.text = mPerson?.status
        regLbl.text = mPerson!.regCode
        nameTxt.text = mPerson!.name
        lastStatusLbl.text = mPerson!.lastStatus
        groupLbl.text = mPerson!.group
        /*  
        Have populated the views, now decide whether the "questions" butto should be enabled"
         */
        if mPerson!.status == PersonTable.STATUS_WAIT_GROUP
            || mPerson!.status == PersonTable.STATUS_ACTIVE
            || mPerson!.status == PersonTable.STATUS_GROUP_NOT_CONFIRMED {
            qButton.isEnabled = true
        }
        else {
            qButton.isEnabled = false
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func passData (id: String, delegate: DismissalDelegate){
        dismissalDelegate = delegate
        mPersonId = id
        if id == "" {
            mPerson = PersonTable()
            mPerson!.name = ""
            mPerson!.pseudonym = ""
            mPerson!.status = PersonTable.STATUS_WAIT_REGCODE
            mPerson!.regCode = "pending" //TODO - replace this
            mPerson!.group = ""
            mPerson!.lastStatus = ""
        }
        else {
            mPerson = PersonTable.getKey(db: mDBT, id: id)
        }
    }
    public func gotCode(_ code: String, _ rc: RegCodeType) {
        if mWaiting {
            if rc.rawValue > 0 {
                print (" Got result \(rc)")
                mWaiting = false
                mPerson!.id = "temp\(CACurrentMediaTime())"
                mPerson!.regCode = code
                let x = mPerson!.insert(db: mDBT)
                print ("after insert \(x)")
                UIApplication.shared.endIgnoringInteractionEvents()
                FcmMessage.builder(action: .ACT_NEW_CODE)
                    .addData(key: .REG_CODE, data: code)
                    .addData(key: .CONGREGATION, data: MyPrefs.getPrefString(preference: MyPrefs.CONGREGATION))
                    .addData(key: .REG_TYPE, data: RegCodeType.REG_CODE_CLIENT.rawValue)
                    .addData(key: .TEAM_LEADER, data: MyPrefs.getPrefString(preference: MyPrefs.PERSON_ID))
                    .send()
                let alertController = UIAlertController(title: "Code set", message: "Tell this person to register with code "+code, preferredStyle: .alert)
                
                
                
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: {
                    (action : UIAlertAction!) -> Void in
                    self.dismiss(animated: true, completion: nil)
                    //self.performSegue(withIdentifier: ListPersonController.PEOPLE_RETURN, sender: self)
                })
                
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion: nil)
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
        else {
            print ("another result \(rc)")
        }
    }

    /*
    // MARK: - Navigation
*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier! == PeopleMaintenanceController.QUEST_SEGUE {
            let vc = segue.destination as! QuestionListController
            vc.passData(status: "", dayNo: 0, createMode: false, displayMode: true, displayDate: 0, personId: mPerson!.id!, delegate: self)
        }
    }
 

}
