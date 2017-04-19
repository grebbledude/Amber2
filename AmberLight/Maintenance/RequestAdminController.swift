//
//  RequestAdminController.swift
//  AmberLight
//
//  Created by Pete Bennett on 12/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit

class RequestAdminController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var congLbl: UITextField!
    @IBOutlet weak var webLbl: UITextField!
    @IBOutlet weak var phoneLbl: UITextField!
    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var timezoneLbl: UILabel!
    @IBOutlet weak var errorLbl: UILabel!
    @IBAction func cmdRequest(_ sender: Any) {
        if congLbl.text == "" {
            errorLbl.text = "Congregation name must be entered"
        } else {
            if webLbl.text == "" {
                errorLbl.text = "Church website must be entered"
            } else {
                if phoneLbl.text == "" {
                    errorLbl.text = "Phone number must be entered"
                } else {
                    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                    
                    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                    if  emailTest.evaluate(with: emailLbl.text) {
                        errorLbl.text = ""
                        FcmMessage.builder(action: .ACT_REQUEST_ADMIN)
                            .addData(key: .TIMEZONE, data: timezoneLbl.text!)
                            .addData(key: .CONGREGATION, data: congLbl.text!)
                            .addData(key: .PHONENUM, data: phoneLbl.text!)
                            .addData(key: .WEBSITE, data: webLbl.text!)
                            .addData(key: .EMAIL, data: emailLbl.text!)
                            .send()
                         UIAlertController.displayOK(viewController: self, title: "Complete",
                                            message: "Your request will be validated and you will receive a response by email ", preferredStyle: .alert,
                                            handler: {sender in
                                                self.navigationController?.popToRootViewController(animated: true)})
                        
                    } else {
                        errorLbl.text = "Email address is invalid format"
                        
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        timezoneLbl.text = TimeZone.current.abbreviation()
        congLbl.delegate = self
        webLbl.delegate = self
        phoneLbl.delegate = self
        emailLbl.delegate = self
   

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
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
