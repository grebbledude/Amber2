//
//  ListRequestController.swift
//  AmberLight
//
//  Created by Pete Bennett on 18/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit
import SQLite

class ListRequestController: UIViewController, UITableViewDelegate, UITableViewDataSource,
Lockable, Refreshable {

    
    private var mSelected = -1
    private static var mLastPanic: Date?
    private var mDBT = DBTables()
    private var mRequests: [RequestTable]!
    private var mCurrentRequest: RequestTable!
    static let SEND_SEGUE = "sendMessageSegue"
    private var mRequiresRefresh = false
    
 
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getData()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func getData() {
        
        let timestamp = Date().timeIntervalSinceReferenceDate - (8 * 3600)
        mRequests = RequestTable.get(db: mDBT, filter: RequestTable.TIMESTAMP > timestamp, orderby: [RequestTable.TIMESTAMP])
    }
    override func viewWillAppear(_ animated: Bool) {
        if mRequiresRefresh {
            mRequiresRefresh = false
            getData()
            tableView.reloadData()
        }
    }

    // MARK table functions
    func numberOfSections(in tableView: UITableView) -> Int{
        // If not team lead, the first entry is blank - it is a placeholder for profile
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return mRequests.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        // Three types of cell.  Profile, header and detail.  Profile is if not team lead and it is section 0.
        //  header is row 0 in a section.
        // otherwise it is detail
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pickCell", for: indexPath) as! RequestCell
        cell.personLabel.text = mRequests[indexPath.row].pseudonym
        cell.messageLabel.text = mRequests[indexPath.row].text
        let date = Date(timeIntervalSinceReferenceDate: mRequests[indexPath.row].timeStamp)
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        cell.dateLabel.text = formatter.string(from: date)

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
        mCurrentRequest = mRequests[didSelectRowAt.row]
        performSegue(withIdentifier: ListRequestController.SEND_SEGUE, sender: self)
        
        
    }
    
    
     // MARK: - Navigation
     /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == ListRequestController.SEND_SEGUE {
            let vc = segue.destination as! RespondController
            vc.passData(requestId: mCurrentRequest.id)
            mRequiresRefresh = true  // Data may have changed when we come back.
        }
     }
    
    func refreshData() {
        getData()
        tableView.reloadData()
    }
    func releaseData() {
        mRequests = []
    }
}
class RequestCell: UITableViewCell {
    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}
