//
//  ListGroupController.swift
//  testsql
//
//  Created by Pete Bennett on 19/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class ListGroupController: UIViewController, UITableViewDelegate, UITableViewDataSource, DismissalDelegate, Lockable {


  
    @IBAction func pressAdd(_ sender: UIBarButtonItem) {
        mId = ""

        performSegue(withIdentifier: ListGroupController.GROUP_MAINT, sender: self)
 
    }
    @IBAction func pressEdit(_ sender: UIBarButtonItem) {
        if let row = mSelectedRow {
            mId = mGroupTables![row].id
            performSegue(withIdentifier: ListGroupController.GROUP_MAINT, sender: self)
        }
    }


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchButton: UIBarButtonItem!

    private var mGroupTables: [GroupTable]?
    private let mDBT = DBTables()
    private var mSelectedRow: Int?
    private var mId = ""
    
    public static let GROUP_RETURN = "groupReturn"
    public static let GROUP_MAINT = "groupMaint"
    
    override func viewDidLoad() {
        super.viewDidLoad()


        getGroups()
 
        tableView.delegate = self
        tableView.dataSource = self
 //       clearNavBar()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func getGroups() {
        mGroupTables = GroupTable.getAll(db: mDBT)

    }
    
    // MARK: Table View
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return mGroupTables!.count
        //return 90
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        // Table view cells are reused and should be dequeued using a cell identifier.

        let cellIdentifier = "groupCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroupTableViewCell
        let group = mGroupTables![indexPath.row]
        cell.id.text = group.id
        cell.name.text = group.desc
        cell.members.text = String(group.members)
        cell.status.text = group.formatStatus
        return cell

        

    }

    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
       let row = didSelectRowAt.row
        
        mId = mGroupTables![row].id
        performSegue(withIdentifier: ListGroupController.GROUP_MAINT, sender: self)
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didDeselectRowAt)
        //cell?.accessoryType = .none
        
    }
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //    cell.backgroundColor = .clear
   // }
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case ListGroupController.GROUP_MAINT:
            let dest = segue.destination as! GroupMaintenanceController
            dest.passData(id: mId, delegate: self)

        default: break
        }
    }
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        getGroups()
        tableView.reloadData()
        super.dismiss(animated: flag, completion: completion)
    }
    @IBAction func unwindToMainListSegue (sender: UIStoryboardSegue) {
        getGroups()

        tableView.reloadData()
    }

}
