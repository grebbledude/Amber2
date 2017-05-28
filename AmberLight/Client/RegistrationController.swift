//
//  RegistrationController.swift
//  testsql
//
//  Created by Pete Bennett on 17/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCrash


class RegistrationController: UIViewController, DismissalDelegate, Themed {
    private static let QUESTION_SEGUE = "regToQuestion"
    private static let LOCK_SEGUE = "regToLock"
    private static let HOLDER_SEGUE = "holderSegue"
    private static let ADMIN_SEGUE = "adminSegue"
    private static let WAITING_SEGUE = "waitingSegue"
    private static let ANON_SEGUE = "anonCheck"
    /*
     So to explain how this works. There are a number of common actions that might be needed
     These are listed in RegAction. 
     For each type or registration there is a list of actions (STATUS_CHANGE)
     SEGUES show which segue to follow
     TITLEs and TEXT show the alert dialog title and text
 
    */

    private static let SEGUES = [LOCK_SEGUE,LOCK_SEGUE,WAITING_SEGUE,QUESTION_SEGUE,WAITING_SEGUE,ANON_SEGUE,ADMIN_SEGUE,nil]
    private static let TITLES = ["Create lock code",  "Re-enter lock Code", "Registration complete", "Answer questions","Registration complete", "Registration complete", "Admin Mode"]
    private static let TEXT = ["This lock code will be required in future to unlock this app"
                            , "Re-enter the lock code to complete registration"
                            , "You will be assigned a team leader and a start date  Watch for notifications"
                            , "Answer the questions to set a baseline"
                            , "The system will confirm your code soon and enable extended functionality"
                            , "Check in consistently between 18:00 and 02:00, and you will be assigned a support group"
                            , "You are now an administrator"]

    weak var actionToEnable : UIAlertAction?
    weak var nameText : UITextField?
    weak var contactText : UITextField?
    private var mFIRDBRef: DatabaseReference?
    private var mWaiting = false
    private var mType = RegCodeType.REG_CODE_NOT_FOUND
    private var mStatus = 0
    private var mName = ""
    private var mContact = ""
    enum RegAction: Int {
        case getLock = 0
        case checkLock = 1
        case assignTL = 2
        case questions = 3
        case extendTLFunc = 4
        case anonCheck = 5
        case amAdmin = 6
    }
    static let STATUS_CHANGE: [RegCodeType: [RegAction]] = [.REG_CODE_ADMIN: [.getLock,.amAdmin],
                                                      .REG_CODE_CLIENT: [.getLock, .questions, .checkLock, .assignTL],
                                                      .REG_CODE_TL: [.getLock, .extendTLFunc],
                                                      .REG_CODE_CHURCH: [.getLock, .questions, .checkLock, .assignTL],
                                                      .REG_CODE_ANON: [.getLock, .anonCheck]]
    
    public static let STATUS_LOCK1 = 1
    public static let STATUS_QUESTION = 2
    public static let STATUS_LOCK2 = 3
    
    public static let FIRType = "type"

    private var mSwitch = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        mFIRDBRef = Database.database().reference(withPath: FcmMessage.FirebaseDBKey)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistrationController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)

        if mSwitch {
            self.mStatus += 1
            let currAction = RegistrationController.STATUS_CHANGE[mType]![mStatus]
            // This is where we go through the actions and do whatever is required.
            switch currAction {
            case .anonCheck:
                MyPrefs.setPref(preference: MyPrefs.ANON_MODE, value: true)
                MyPrefs.setPref(preference: MyPrefs.ANON_START, value: CheckInController.getDate(date: Date()))
                MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_ANON)
                NotificationHandler.setTimer()
                displayDialog(currAction: currAction, handler: {(action: UIAlertAction) -> Void in
                    self.performSegue(withIdentifier: "anonCheck", sender: self)
                })
            case .assignTL, .extendTLFunc:
                let message = FcmMessage.builder(action: .ACT_REGISTER)
                    .addData(key: FcmMessageKey.REG_CODE, data: self.regCode!.text!)
                    .addData(key: .TIMEZONE, data: TimeZone.current.abbreviation()!)
                    .addData(key: .IOS, data: true)

                MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_REG_SENT)
                if mType == .REG_CODE_TL {
                    let _ = message.addData(key: .TL_NAME, data: mName)
                        .addData(key: .TL_CONTACT, data: mContact)
                }
                
                message.send()
                
                if mType != .REG_CODE_CHURCH  {
                    self.mFIRDBRef?.child(self.regCode.text!).removeValue()  // Never remove a congregation code.
                }
                self.mFIRDBRef = nil
                displayDialog(currAction: currAction, handler: {(action: UIAlertAction) -> Void in
                    self.performSegue(withIdentifier: RegistrationController.SEGUES[currAction.rawValue]!, sender: self)
                })
            case  .amAdmin:
                let message = FcmMessage.builder(action: .ACT_REGISTER)
                    .addData(key: FcmMessageKey.REG_CODE, data: self.regCode!.text!)
                    .addData(key: .IOS, data: true)
         
                MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_REG_SENT)
                let churchCode = MyPrefs.getPrefString(preference: MyPrefs.CONG_CODE)
                RegistrationController.setSpecificCode(code: churchCode)
     
                message.send()
            
                self.mFIRDBRef = nil
                displayDialog(currAction: currAction, handler: {(action: UIAlertAction) -> Void in
                    self.performSegue(withIdentifier: RegistrationController.SEGUES[currAction.rawValue]!, sender: self)
                })

            default:
                displayDialog(currAction: currAction, handler: {(action: UIAlertAction) -> Void in
                    self.performSegue(withIdentifier: RegistrationController.SEGUES[currAction.rawValue]!, sender: self)
                })
            }

        }
        


    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    private func displayDialog (currAction: RegAction, handler: @escaping (_: UIAlertAction) -> Void) {
        // I think we can do this using the helper functions that we extend UIAlertDialog with
        let action = UIAlertAction(title: "OK", style: .default, handler: handler)
        let alert = UIAlertController(title: RegistrationController.TITLES[currAction.rawValue], message: RegistrationController.TEXT[currAction.rawValue], preferredStyle: .alert)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    public func gotCode(type: RegCodeType) {
        // So this gets called when a code is found.  It also gets called if it times out.
        if mWaiting {
            mWaiting = false
            UIApplication.shared.endIgnoringInteractionEvents()
            switch type {
            case .REG_CODE_TIMEOUT: doError()
            case .REG_CODE_ERROR: doError()
            case .REG_CODE_NOT_FOUND:
                let alertController = UIAlertController(title: "Invalid Code", message: "Please check the code you have entered", preferredStyle: .alert)
            
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                    (action : UIAlertAction!) -> Void in
                })
            
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            case .REG_CODE_TL:
                self.mType = type
                let alert = UIAlertController(title: "Enter contact", message: "Enter name and phone number", preferredStyle: .alert)
                
                //2. Add the text field. You can configure it however you need.
                alert.addTextField(configurationHandler: {(textField: UITextField) in
                    textField.placeholder = "Name"
                    self.nameText = textField
                    textField.addTarget(self, action: #selector(self.textChanged(_ :)), for: .editingChanged)
                })

                alert.addTextField(configurationHandler: {(textField: UITextField) in
                    textField.placeholder = "Contact"
                    self.contactText = textField
                    textField.addTarget(self, action: #selector(self.textChanged(_ :)), for: .editingChanged)
                })
                // 3. Grab the value from the text field, and print it when the user clicks OK.
                let action = (UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    self.mName = alert!.textFields![0].text! // Force unwrapping because we know it exists.
                    self.mContact = alert!.textFields![1].text!
                    MyPrefs.setPref(preference: MyPrefs.TL_NAME, value: self.mName)  // We now have user's name and coontact
                    MyPrefs.setPref(preference: MyPrefs.TL_CONTACT, value: self.mContact)     // save them away for the future                  
                    
                    MyPrefs.setPref(preference: MyPrefs.LOCKCODE, value: "")  // and get the lock code.  Reset to blanks first
                    self.mStatus = 0
                    self.performSegue(withIdentifier: RegistrationController.LOCK_SEGUE, sender: self)
                }))
                alert.addAction(action)
                actionToEnable = action
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            default:
                self.mType = type
                MyPrefs.setPref(preference: MyPrefs.LOCKCODE, value: "")
                mStatus = 0
                performSegue(withIdentifier: RegistrationController.LOCK_SEGUE, sender: self)
                
            }

        }
    }
    // This validates the text in an alert dialog
    func textChanged(_ sender:UITextField) {
        if let name = self.nameText?.text {
            if let contact = self.contactText?.text {
                self.actionToEnable?.isEnabled = (name != ""  && contact != "" )
                return
                
            }
        }
        self.actionToEnable?.isEnabled = false
    }
    public func doError() {
        let alertController = UIAlertController(title: "Cannot check Code", message: "An error occured checking code.  Are you connected to the internet?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
// MARK: outlets and actions
    
    @IBOutlet weak var regCode: UITextField!
    @IBAction func pressProceed(_ sender: Any) {
        self.mType = .REG_CODE_ANON   /// REgistering for anonymous usage from a the anonymous registration screen
        MyPrefs.setPref(preference: MyPrefs.LOCKCODE, value: "")
        mStatus = 0
        let currAction = RegistrationController.STATUS_CHANGE[mType]![0]
        let alertController = UIAlertController(title: RegistrationController.TITLES[mStatus], message: RegistrationController.TEXT[mStatus], preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) -> Void in
            self.performSegue(withIdentifier: RegistrationController.SEGUES[currAction.rawValue]!, sender: self)
        }))
        self.present(alertController, animated: true, completion: nil)
   
    }
    @IBAction func pressValidate(_ sender: UIButton) {
        //  This is the scren where you add a code to register.  Validate that code first.
        regCode.text = regCode.text?.uppercased()
        if String(regCode!.text!)[0] == "8" {  //8 is the prefix for all administrator codes
            let registerCode = MyPrefs.getPrefString(preference: MyPrefs.REG_CODE)
            if regCode.text == registerCode {
                self.mType = .REG_CODE_ADMIN
                MyPrefs.setPref(preference: MyPrefs.LOCKCODE, value: "")
                mStatus = 0
                performSegue(withIdentifier: RegistrationController.LOCK_SEGUE, sender: self)
                return
            }
            let alertController = UIAlertController(title: "Invalid code", message: "That code was incorrect", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
            
        }
        if regCode.text!.characters.count > 9 {
            let alertController = UIAlertController(title: "Invalid code", message: "Registration code must be up to 9 characters long?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        else {
            // Admin codes are already stored.  Other codes we need to look up
            UIApplication.shared.beginIgnoringInteractionEvents()
            mWaiting = true
            let deadlineTime = DispatchTime.now() + .seconds(6)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                self.gotCode(type: .REG_CODE_TIMEOUT)
            })
            
            self.mFIRDBRef!.child(self.regCode.text!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let valueDict = snapshot.value as? NSDictionary
                let type = RegCodeType(rawValue: valueDict?[RegistrationController.FIRType] as? Int ?? 0)
                // Type is either  TL  Client or Admin
                self.gotCode(type: type!)
                
                // ...
            }) { (error) in
                self.gotCode(type: .REG_CODE_ERROR)
                return
            }
            
        }
    }

 
    // MARK: - Navigation


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? Dismissable
        {
            vc.dismissalDelegate = self
        }
        if segue.identifier == RegistrationController.QUESTION_SEGUE {
            let target = segue.destination as! QuestionListController
            target.passData(status: "", dayNo: 0, createMode: true, displayMode: false, displayDate: 0, personId: "")
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        mSwitch = true
        super.dismiss(animated: flag, completion: completion)
    }
    // MARK: Code generation
    static public func generateCode(type: RegCodeType, callback: @escaping (_ code: String, _ rc: RegCodeType) -> Void) {
        generateCode(type: type, iteration: 1, callback: callback)
        
    }
    /*
     The first character is numeric - 1-7 for client, 9 for TL and 8 for admin
     Then a number and 2 alphanumeric, then either numeric or alphabetic (for a client)
    */
    static public func generateCode(type: RegCodeType, iteration: Int, callback: @escaping (_ code: String, _ rc: RegCodeType) -> Void) {
        let FIRDBRef = Database.database().reference(withPath: FcmMessage.FirebaseDBKey)

        let random = Int(arc4random_uniform(9*31*31))
        var typeChars = ""
        var firstchar = 0
        switch type {
        case .REG_CODE_CLIENT:
            typeChars = MyPrefs.getPrefString(preference: MyPrefs.TL_KEY)
            firstchar = random % 7
        case .REG_CODE_TL:
            let typeSeed = Int(arc4random_uniform(80)+100)
            typeChars = getChar(typeSeed / 9) + getChar(typeSeed % 9)
            firstchar = 9
        case .REG_CODE_ADMIN:  // This is never used.
            let typeSeed = Int(arc4random_uniform(89)+100)
            typeChars = getChar(typeSeed / 9) + getChar(typeSeed % 9)
            firstchar = 8
        default:
            return
        }
        var regcode: [String] = []

        regcode.append(getChar(firstchar))
        regcode.append(getChar(random % 10))
        regcode.append(getChar(random / (31*31)))
        regcode.append(getChar((random % 31) / 10))
        let newCode = regcode[0] + regcode[1] + regcode[2] + regcode[3] + typeChars
        FIRDBRef.child(newCode).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let _ = snapshot.value as? NSDictionary? {
                if iteration < 5 {
                    generateCode(type: type, iteration: iteration + 1, callback: callback)
                }
                else {
                    callback("", .REG_CODE_ERROR) // Code already exists and tried 5 times
                }
            }
            else {
                FIRDBRef.child(newCode).setValue([RegistrationController.FIRType: type.rawValue])
                callback(newCode,type)
            }
            // let type = valueDict?[RegistrationController.FIRType] as? String ?? ""
                // ..
        }) { (error) in
            callback("",.REG_CODE_ERROR)
        }
    }
    //public static func checkSpecificCode(code: String, callback: @escaping (_ code: String, _ rc: RegCodeType) -> Void) {
        //
        // This is now dead code.  We can delete after we delete admincodecontroller
        //
/*        let FIRDBRef = Database.database().reference(withPath: FcmMessage.FirebaseDBKey)
        FIRDBRef.child(code).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let _ = snapshot.value as? NSDictionary? {
                callback("", .REG_CODE_ERROR) // Code already exists 
            }
            else {
                FIRDBRef.child(code).setValue([RegistrationController.FIRType: RegCodeType.REG_CODE_CHURCH.rawValue])
                callback(code, .REG_CODE_CHURCH)
            }
            // ..
        }) { (error) in
            callback("",.REG_CODE_ERROR)
        } */
    //}
    public static func setSpecificCode(code: String) {

        //
        // Set a specific code and overwrite
        //
        let FIRDBRef = Database.database().reference(withPath: FcmMessage.FirebaseDBKey)
        FIRDBRef.child(code).setValue([RegistrationController.FIRType: RegCodeType.REG_CODE_CHURCH.rawValue])
    }

    private static func getChar (_ key: Int) -> String{
        let  str = "123456789ABCDEFGHJKMNPQRSTUVWXYZ"
        let index = str.index(str.startIndex, offsetBy: key)
        return String(str[index])
        
        
    }


}
enum RegCodeType: Int {
    case REG_CODE_TIMEOUT = -2
    case REG_CODE_ERROR = -1
    case REG_CODE_NOT_FOUND = 0
    case REG_CODE_TL = 1
    case REG_CODE_ADMIN = 2
    case REG_CODE_CLIENT = 3
    case REG_CODE_CHURCH = 4
    case REG_CODE_ANON = 5
}
