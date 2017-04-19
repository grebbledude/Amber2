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
        print("groups did load")


        getGroups()
 
        tableView.delegate = self
        tableView.dataSource = self
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
        print("got sections")
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print (" Rows in section" + String (mGroupTables!.count ))
        
        return mGroupTables!.count
        //return 90
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print ("getting cell")
        // Table view cells are reused and should be dequeued using a cell identifier.

        let cellIdentifier = "groupCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroupTableViewCell
        let group = mGroupTables![indexPath.row]
        cell.id.text = group.id
        cell.name.text = group.desc
        cell.members.text = String(group.members)
        cell.status.text = group.status
        return cell

        

    }

    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
        mSelectedRow = didSelectRowAt.row
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didDeselectRowAt)
        //cell?.accessoryType = .none
        
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
        print("reloading data")
        super.dismiss(animated: flag, completion: completion)
    }
    @IBAction func unwindToMainListSegue (sender: UIStoryboardSegue) {
        getGroups()

        tableView.reloadData()
    }

}
