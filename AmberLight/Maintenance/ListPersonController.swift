//
//  ListPersonController.swift
//  AmberLight
//
//  Created by Pete Bennett on 10/04/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//


import UIKit

class ListPersonController: UIViewController, UITableViewDelegate, UITableViewDataSource, DismissalDelegate, Refreshable, Lockable  {
    
    
    
    @IBAction func pressAdd(_ sender: UIBarButtonItem) {
        mId = ""
        performSegue(withIdentifier: ListPersonController.PEOPLE_MAINT, sender: self)

    }
    @IBAction func pressEdit(_ sender: UIBarButtonItem) {
        if let row = mSelectedRow {
            mId = mPersonTables![row].id
            performSegue(withIdentifier: ListPersonController.PEOPLE_MAINT, sender: self)
        }
    }

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchButton: UIBarButtonItem!
    private var mPersonTables: [PersonTable]?
    private let mDBT = DBTables()
    private var mSelectedRow: Int?
    private var mId = ""
    private var mRefreshed: Bool!
    
    public static let PEOPLE_RETURN = "peopleReturn"

    public static let PEOPLE_MAINT = "personMaint"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        getPeople()
        mRefreshed = true
 //       clearNavBar()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
    }
    override func viewWillAppear(_ animated: Bool) {
        if !mRefreshed {
            refreshData()
        }
        mRefreshed = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func getPeople() {
        mPersonTables = PersonTable.getAll(db: mDBT)
    }
    func refreshData() {
        getPeople()
        tableView!.reloadData()
        mRefreshed = true
    }
    func releaseData() {
        mPersonTables = nil
    }
    
    // MARK: Table View
    func numberOfSections(in tableView: UITableView) -> Int{

        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return  mPersonTables!.count
        //return 90
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        // Table view cells are reused and should be dequeued using a cell identifier.

        let cellIdentifier = "personCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PersonTableViewCell
        let person = mPersonTables![indexPath.row]
        cell.id.text = person.id
        cell.name.text = person.name
        cell.pseudonym.text = person.pseudonym
        cell.status.text = person.formatStatus
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
        let row = didSelectRowAt.row
        
        mId = mPersonTables![row].id
        performSegue(withIdentifier: ListPersonController.PEOPLE_MAINT, sender: self)
        
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case ListPersonController.PEOPLE_MAINT:
            let dest = segue.destination as! PeopleMaintenanceController
            dest.passData(id: mId, delegate: self)
        default: break
        }
    }
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        getPeople()
        tableView.reloadData()
        super.dismiss(animated: flag, completion: completion)
    }
    @IBAction func unwindToMainListSegue (sender: UIStoryboardSegue) {



    }
    
}
