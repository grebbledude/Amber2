//
//  AdminCodeController.swift
//  AmberLight
//
//  Created by Pete Bennett on 25/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//





// THIS IS DEAD CODE !!!!!!!!!!!!!!!!!!

import UIKit

class AdminCodeControllerToDelete: UIViewController {
    private var mWaiting = false

    @IBAction func pressDone(_ sender: Any) {
        if validateInput() {
            let deadlineTime = DispatchTime.now() + .seconds(6)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                self.gotCode("", .REG_CODE_TIMEOUT)
            })
            self.mWaiting = true
            UIApplication.shared.beginIgnoringInteractionEvents()
    //        RegistrationController.checkSpecificCode(code: String(codeText!.text!).uppercased(), callback: self.gotCode)
        }
 
    }
    @IBOutlet weak var codeText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func validateInput() ->Bool {
        codeText!.text = String(codeText!.text!).uppercased()
        let code = codeText!.text!
        
        if code.length < 5 || code.length > 9 {
            return false
        }
        var count = 0
        _ = code.characters.map {
            if ($0 >= "A") && ($0 <= "Z") {
                count += 1
            }
        }
        if count != code.length {
            return false
        }
        return true
    }
    public func gotCode(_ code: String, _ rc: RegCodeType) {
        if mWaiting {
            mWaiting = false
            switch rc {
            case .REG_CODE_CHURCH:
                FcmMessage.builder(action: .ACT_NEW_CODE)
                    .addData(key: .REG_CODE, data: code)
                    .addData(key: .CONGREGATION, data: MyPrefs.getPrefString(preference: MyPrefs.CONGREGATION))
                    .addData(key: .REG_TYPE, data: RegCodeType.REG_CODE_ADMIN.rawValue)
                    .addData(key: .TEAM_LEADER, data: "none")
                    .send()
                MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_ACTIVE)
                MyPrefs.setPref(preference: MyPrefs.I_AM_ADMIN, value: true)
                MyPrefs.setPref(preference: MyPrefs.REG_CODE, value: code)
                self.navigationController!.popViewController(animated: true)
            case .REG_CODE_ERROR:
                let alertController = UIAlertController(title: "Duplicate", message: "This code is already in use",preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            default:
                let alertController = UIAlertController(title: "Error", message: "An error ocurred.  Are you sure you are connected to the internet?", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            }

            UIApplication.shared.endIgnoringInteractionEvents()
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
