//
//  NotificagtionSettingsController.swift
//  testsql
//
//  Created by Pete Bennett on 03/02/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit

class NotificagtionSettingsController: UIViewController, Dismissable {
    
    @IBAction func pressDone(_ sender: Any) {
        var valid = false
        for status in mStatus! {
            if status == 0 {
                valid = true
            }
        }
        if valid {
            for i in 0...6 {
                MyPrefs.setPref(preference: mPrefName![i], value: mStatus![i])
            }
            NotificationHandler.setTimer()
            if let delegate = dismissalDelegate {
                delegate.finishedShowing(viewController: self)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        else {
            let alertController = UIAlertController(title: "No sound!", message: "At least one notifcation must include sound", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func press6(_ sender: Any) {
        processButton(bNo: 0)
    }
    @IBAction func press7(_ sender: Any) {
        processButton(bNo: 1)
    }
    @IBAction func press8(_ sender: Any) {
        processButton(bNo: 2)
    }
    @IBAction func press9(_ sender: Any) {
        processButton(bNo: 3)
    }
    @IBAction func press10(_ sender: Any) {
        processButton(bNo: 4)
    }
    @IBAction func press11(_ sender: Any) {
        processButton(bNo: 5)
    }
    @IBAction func press12(_ sender: Any) {
        processButton(bNo: 6)
    }
    
    @IBOutlet weak var timezoneLbl: UILabel!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var button10: UIButton!
    @IBOutlet weak var button11: UIButton!
    @IBOutlet weak var button12: UIButton!
    @IBOutlet weak var button13: UIButton!
    private var mPrefName: [String]?
    
    private var mStatus: [Int]?
    private var mButtons: [UIButton]?
    weak var dismissalDelegate : DismissalDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        mStatus = [0,0,0,0,0,0,0]
        mPrefName = [MyPrefs.NOTIF_6, MyPrefs.NOTIF_7, MyPrefs.NOTIF_8, MyPrefs.NOTIF_9,
                    MyPrefs.NOTIF_10, MyPrefs.NOTIF_11, MyPrefs.NOTIF_12]
        mButtons = [button6!, button7!, button8!, button9!, button10!, button11!, button12!]

        // Do any additional setup after loading the view.
        for i in 0...6 {
            mStatus![i] = MyPrefs.getPrefInt(preference: mPrefName![i])
            setTitle(bNo: i)
            
        }
        timezoneLbl.text = MyPrefs.getPrefString(preference: MyPrefs.TIMEZONE)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func processButton(bNo: Int) {
        if mStatus![bNo] == 2  {
            mStatus![bNo] = 0
        }
        else {
            mStatus![bNo] += 1
        }
        setTitle(bNo: bNo)
    }
    private func setTitle(bNo: Int) {
        switch mStatus![bNo] {
        case 0:
            mButtons![bNo].setTitle("\(bNo+6)pm: With sound", for: .normal)
        case 1:
            mButtons![bNo].setTitle("\(bNo+6)pm: just notify", for: .normal)
        default:
            mButtons![bNo].setTitle("\(bNo+6)pm: no notification", for: .normal)
            
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
