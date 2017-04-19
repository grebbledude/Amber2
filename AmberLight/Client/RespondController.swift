//
//  RespondController.swift
//  AmberLight
//
//  Created by Pete Bennett on 16/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//


import UIKit

class RespondController: UIViewController, UITableViewDelegate, UITableViewDataSource,
Lockable {
    private static let MESSAGES = [
        "Hang in there Bro!",
        "Praying for you!",
        "You can do it!",
        ]
//    need to pass data
//    need to set a responded flag
    
    private var mSelected = -1
    private static var mLastPanic: Date?
    private var mDBT = DBTables()
    private var mRequest: RequestTable?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    @IBAction func pressSend(_ sender: Any) {

        
  //      change all this
        if let indexPath = tableView.indexPathForSelectedRow {
            FcmMessage.builder(action: .ACT_RESPOND_REQUEST)
                .addData(key: .PERSON_ID, data: mRequest!.personId)
                .addData(key: .TEXT, data: RespondController.MESSAGES[indexPath.row])
                .addData(key: .PSEUDONYM, data: MyPrefs.getPrefString(preference: MyPrefs.PSEUDONYM))
                .addData(key: .MSG_NO, data: indexPath.row)
                .send()
            let _ = self.navigationController!.popViewController(animated: true)
            RespondController.mLastPanic = Date()
            mRequest?.delete(db: mDBT)
            let alert = UIAlertController(title: "Message sent", message: "You have encouraged \(mRequest!.pseudonym)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
            self.present(alert, animated: true, completion: {
                self.navigationController!.popViewController(animated: true)
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    public func passData(requestId: String) {
        mRequest = RequestTable.getKey(db: mDBT, id: requestId)
    }
    // MARK table functions
    func numberOfSections(in tableView: UITableView) -> Int{
        // If not team lead, the first entry is blank - it is a placeholder for profile
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return RespondController.MESSAGES.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        // Three types of cell.  Profile, header and detail.  Profile is if not team lead and it is section 0.
        //  header is row 0 in a section.
        // otherwise it is detail
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "prayerCell", for: indexPath)
        cell.textLabel!.text = RespondController.MESSAGES[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
        sendButton.isEnabled = true
        
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
