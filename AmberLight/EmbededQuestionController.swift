//
//  EmbedViewController.swift
//  AmberLight
//
//  Created by Pete Bennett on 21/05/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit

class EmbededQuestionController: UIViewController, Themed {
    
    @IBAction func returnButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var navBar: UINavigationBar!
    private var mDayNo: Int!
    private var mPersonId: String!
    private var mDisplayDate: Int!
    public var mEmbedded: QuestionListController!
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc =  segue.destination as! QuestionListController
        mEmbedded = vc
        vc.passData(status: "", dayNo: mDayNo, createMode: false, displayMode: true, displayDate: 0, personId: mPersonId, delegate: nil)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    /*
     This is a terrible kludge.  I get passed the data from the person maintenance
     and then I have to forward it on.  All so that I can add Theme and a return button
    */
    func passData(dayNo: Int, displayDate: Int, personId: String) {
        mDayNo = dayNo
        mDisplayDate = displayDate
        mPersonId = personId
    }
}
