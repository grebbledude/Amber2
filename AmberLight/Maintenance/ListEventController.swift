//
//  ListEventController.swift
//  testsql
//
//  Created by Pete Bennett on 10/12/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import SQLite

class ListEventController: UIViewController, UITableViewDelegate, UITableViewDataSource, Lockable {
    
    private var mEvents: [EventTable]?
    private let mDBT = DBTables()
    public static let PANICSEGUE = "panicSegue"
    public static let FILTER_MAINTENANCES_SEGUE = "filterMaintenanceSegue"
//    private var mNeedsUnlock = true

    @IBAction func pressBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let eventFilter = Date().timeIntervalSinceReferenceDate - (24 * 3600 * 14)
        mEvents =  EventTable.get(db: mDBT, filter: EventTable.TIMESTAMP > eventFilter, orderby: [EventTable.TIMESTAMP.desc]  )
        tableView!.delegate = self
        tableView!.dataSource = self
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {

    }
    func numberOfSections(in tableView: UITableView) -> Int{
        // print("got sections")
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return mEvents!.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //print ("getting cell")
        // Table view cells are reused and should be dequeued using a cell identifier.
 
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventItem", for: indexPath) as! EventItem
        switch mEvents![indexPath.row].type! {
        case EventTable.TYPE_PANIC: cell.typeLabel.text = "Prayer request"
        case EventTable.TYPE_NEW_PERSON: cell.typeLabel.text = "New Person"
        default: cell.typeLabel.text = "Unknown"
        }
        cell.detailLabel.text = mEvents?[indexPath.row].text
        cell.timeLabel.text = CheckInController.formatDate(timeStamp: mEvents![indexPath.row].timeStamp)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
        switch mEvents![didSelectRowAt.row].type! {
        case EventTable.TYPE_PANIC: performSegue(withIdentifier: ListEventController.PANICSEGUE, sender: self)
        case EventTable.TYPE_NEW_PERSON: performSegue(withIdentifier: ListEventController.FILTER_MAINTENANCES_SEGUE, sender: self)
        default: break
            
        }

        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didDeselectRowAt)
        //cell?.accessoryType = .none
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
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

class EventItem: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

//    override func awakeFromNib() {
//        super.awakeFromNib()
        // Initialization code
//    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
//    }
    
}
