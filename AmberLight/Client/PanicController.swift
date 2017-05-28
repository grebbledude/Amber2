//
//  PanicController.swift
//  testsql
//
//  Created by Pete Bennett on 04/12/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
/*
 This isn't used at the moment.  Replaced by anonymous panic
 */
class PanicController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: outlets and actions
    
    @IBOutlet weak var panicText: UITextView!
    @IBAction func sendPressed(_ sender: UIButton) {
        let length = panicText.text.characters.count
        if length == 0 || length > 256 {
            //TODO put out a message
            let alertController = UIAlertController(title: "Invalid message", message: "Message must be 1-250 characters", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        FcmMessage.builder(action: .ACT_PANIC)
            .addData(key: .TEXT, data: panicText.text)
            .addData(key: .PERSON_ID, data: MyPrefs.getPrefString(preference: MyPrefs.PERSON_ID))
            .addData(key: .PSEUDONYM, data: MyPrefs.getPrefString(preference: MyPrefs.PSEUDONYM))
            .send()
        let _ = navigationController?.popViewController(animated: true)
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
