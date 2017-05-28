//
//  AnonPanicController.swift
//  AmberLight
//
//  Created by Pete Bennett on 16/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit

class AnonPanicController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private static let MESSAGES = [
        "I am feeling very tempted",
        "I am going into a situation where I am vulnerable",
        "I can't stop thinking about it",
        "I'm with people who are a bad influence"]
    private var mSelected = -1
    private static var mLastPanic: Date?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    @IBAction func pressSend(_ sender: Any) {
        if let lastDate = AnonPanicController.mLastPanic {
            let diff = Date().timeIntervalSinceReferenceDate - lastDate.timeIntervalSinceReferenceDate
            if diff < 3600 {
                UIAlertController.displayOK(viewController: self, title: "Too Quick", message: "To protect group members you cannot send multiple messages in an hour", preferredStyle: .alert, handler: {(action : UIAlertAction!) -> Void in
                    let _ = self.navigationController!.popViewController(animated: true)})
  //              let alert = UIAlertController(title: "Too Quick", message: "To protect group members you cannot send multiple messages in an hour", preferredStyle: .alert)
 //               alert.addAction(UIAlertAction(title: "OK", style: .cancel,
  //                      handler: {(action : UIAlertAction!) -> Void in
  //                          let _ = self.navigationController!.popViewController(animated: true)}))
  //              self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            FcmMessage.builder(action: .ACT_PANIC_ANON)
                .addData(key: .PERSON_ID, data: MyPrefs.getPrefString(preference: MyPrefs.PERSON_ID))
                .addData(key: .PSEUDONYM, data: MyPrefs.getPrefString(preference: MyPrefs.PSEUDONYM))
                .addData(key: .MSG_NO, data: indexPath.row)
                .send()
            
//            let _ = self.navigationController!.popViewController(animated: true)
            AnonPanicController.mLastPanic = Date()
            UIAlertController.displayOK(viewController: self, title: "Panic sent", message: "Your team will receive your message and will be given the opportunity to respond", preferredStyle: .alert, handler: {(action : UIAlertAction!) -> Void in
                let _ = self.navigationController!.popViewController(animated: true)})
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        sendButton.isEnabled = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK table functions
    func numberOfSections(in tableView: UITableView) -> Int{
        // If not team lead, the first entry is blank - it is a placeholder for profile
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return AnonPanicController.MESSAGES.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        // Three types of cell.  Profile, header and detail.  Profile is if not team lead and it is section 0.
        //  header is row 0 in a section.
        // otherwise it is detail
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "panicCell", for: indexPath) as! PanicCell
        cell.msgLabel!.text = AnonPanicController.MESSAGES[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        sendButton.isEnabled = true
        let cell = tableView.cellForRow(at: didSelectRowAt)
        Theme.setCellLayer(view: cell!.contentView, selected: true)
        cell?.accessoryType = .checkmark

    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        let cell = tableView.cellForRow(at: didDeselectRowAt)
        cell?.accessoryType = .none
        Theme.setCellLayer(view: cell!.contentView, selected: false)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
    }


}
class PanicCell: UITableViewCell {
    @IBOutlet weak var msgLabel: UILabel!
    
    
}
