//
//  LockController.swift
//  testsql
//
//  Created by Pete Bennett on 09/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class LockController: UIViewController, Dismissable, Themed {
    
    public static let REG_RETURN = "unwindToRegistration"
    weak var dismissalDelegate: DismissalDelegate?
    @IBOutlet weak var debugButton: UIButton!
    
    var mDBT: DBTables?
    var mLockCount = 0
    var mLockCode = ["_","_","_","_","_"]
    var mLockVis = true
    var mLockStored: String?
    var mSource = ""
    var mDebug = ""
    public static let LOCKREG = "unwindToRegistration"
    public static let LOCKQUESTION = "unwindToQuestion"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mDBT = DBTables()
        mLockStored = MyPrefs.getPrefString(preference: MyPrefs.LOCKCODE)
        if mLockStored != "" {
            mLockVis = false
        }
        lockOK.isEnabled = false
        debugButton.isHidden = true
        //layerGradient()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func passData(lockCode: String, source: String){
        mLockStored = lockCode
        mSource = source
    }
    private func getRewindSegueName() -> String {
        switch mSource {
        case LockController.LOCKREG: return mSource
        case LockController.LOCKQUESTION: return mSource
        default: return LockController.LOCKREG
        }
    }
    // MARK: outlets
    @IBOutlet weak var lockChar1: UILabel!
    @IBOutlet weak var lockChar2: UILabel!
    @IBOutlet weak var lockChar3: UILabel!
    @IBOutlet weak var lockChar4: UILabel!
    @IBOutlet weak var lockChar5: UILabel!
    @IBOutlet weak var lockOK: UIButton!
    // MARK: actions
    @IBAction func lockPress1(_ sender: UIButton) {
            lockPressed("1")
    }
    @IBAction func lockPress2(_ sender: UIButton) {
            lockPressed("2")
    }
    @IBAction func lockPress3(_ sender: UIButton) {
            lockPressed("3")
    }
    @IBAction func lockPress4(_ sender: UIButton) {
        lockPressed("4")
    }
    @IBAction func lockPress5(_ sender: UIButton) {
        lockPressed("5")
    }
    @IBAction func lockPress6(_ sender: UIButton) {
        lockPressed("6")
    }
    @IBAction func lockPress7(_ sender: UIButton) {
        lockPressed("7")
    }
    @IBAction func lockPress8(_ sender: UIButton) {
        lockPressed("8")
    }
    @IBAction func lockPress9(_ sender: UIButton) {
        lockPressed("9")
    }
    @IBAction func lockPress0(_ sender: UIButton) {
        lockPressed("0")
    }
    @IBAction func lockPressX(_ sender: UIButton) {
            lockPressed("x")
    }
    @IBAction func lockPressOK(_ sender: UIButton) {
        let lock = mLockCode[0] + mLockCode[1] + mLockCode[2] + mLockCode[3] + mLockCode[4]

        if mLockStored == "" {
            mLockStored = lock
            MyPrefs.setPref(preference: MyPrefs.LOCKCODE, value: lock)
            dismissalDelegate?.finishedShowing(viewController: self)
            //performSegue(withIdentifier: getRewindSegueName(), sender: self)
        }
        else
        {
            if lock == mLockStored
            {
                if let delegate = dismissalDelegate {
                    delegate.finishedShowing(viewController: self)
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    private func lockShowChar(index: Int) -> String{
        if index >= mLockCount {
            return "_"
        }
        if mLockVis {
            return mLockCode [ index]
        }
        return "*"
    }
    private func lockPressed(_ key: String) {
        // Once the 5 digits are done, you can type the debug code to enable the debug button
        if key == "x" {
            if mLockCount > 0 {
                mLockCount -= 1
                mLockCode[mLockCount] = "_"
                lockOK.isEnabled = false
            }
        }
        else {
            if mLockCount < 5 {
                mLockCode [mLockCount] = key
                mLockCount += 1
                if mLockCount == 5 {
                    lockOK.isEnabled = true
                }
            } else {
                mDebug = mDebug + key
                if mDebug == "19091992" {
                    debugButton.isHidden = false
                    debugButton.isEnabled = true
                }
            }
            
        }
        lockChar1.text = lockShowChar(index: 0)
        lockChar2.text = lockShowChar(index: 1)
        lockChar3.text = lockShowChar(index: 2)
        lockChar4.text = lockShowChar(index: 3)
        lockChar5.text = lockShowChar(index: 4)
    }

}

