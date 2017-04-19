//
//  GroupMaintenanceController.swift
//  testsql
//
//  Created by Pete Bennett on 20/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import SQLite

class GroupMaintenanceController: UIViewController, UITableViewDelegate, UITableViewDataSource, Dismissable, Lockable {
    
    weak var dismissalDelegate : DismissalDelegate?
    @IBAction func pressCancel(_ sender: Any) {
        dismissalDelegate?.finishedShowing(viewController: self)
    }
    @IBOutlet weak var activateButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func pressActivate(_ sender: UIBarButtonItem) {
        mGroup!.status = GroupTable.STATUS_WAIT
        var dateComponent = DateComponents()
        dateComponent.day = 3
        let newDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        mGroup!.startdate = CheckInController.getDate(date: newDate!)
        mGroup!.update(db: mDBT)
        PersonTable.updateStatus(group: mGroup!.id, toStatus: PersonTable.STATUS_ACTIVE, db: mDBT)
        let message = FcmMessage.builder(action: .ACT_GROUP_GO)
            .addData(key: .GROUP_ID,data: mGroup!.id)
            .addData(key: .NUM_ENTRIES,data: mGroup!.members)
            .addData(key: .STARTDATE, data: mGroup!.startdate)
            .addData(key: .TEAM_LEADER, data: MyPrefs.getPrefString(preference: MyPrefs.TL))
            .addData(key: .TEXT, data: mGroup!.desc)
        let people = PersonTable.get(db: mDBT, filter: PersonTable.GROUP == mGroup!.id)
        var member = 0
        for person in people {
            let _ = message.addData(key: .PERSON_ID, data: person.id, suffix: String(member))
            member += 1
        }
        message.send()
    }
    @IBAction func pressSave(_ sender: Any) {
        if nameTxt.text != "" {
            mGroup!.desc = nameTxt.text
            for person in mPeople! {
                if person.group == "" && person.status == PersonTable.STATUS_GROUP_NOT_CONFIRMED {
                    person.status = PersonTable.STATUS_WAIT_GROUP
                    person.update (db: mDBT)
                }
                else {
                    if person.group == mGroup!.id && person.status == PersonTable.STATUS_WAIT_GROUP {
                        person.status = PersonTable.STATUS_GROUP_NOT_CONFIRMED
                        person.update(db: mDBT)
                    }
                }
            }
            let newSelect = tableView.indexPathsForSelectedRows
            mGroup!.members = newSelect?.count ?? 0
            if mInsert {
                let _ = mGroup!.insert(db: mDBT)
            }
            else {
                mGroup!.update(db: mDBT)
                
            }
            dismissalDelegate?.finishedShowing(viewController: self)
        }
    }
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var memberLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    private let mDBT = DBTables()
    private var mGroup: GroupTable?
    private var mGroupId = ""
    private var mPeople: [PersonTable]?
    private var mInsert = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //***************
        //fudgeData()
        //***************
        idLbl.text = mGroup!.id
        nameTxt.text  = mGroup!.desc
        statusLbl.text = mGroup?.status
        startDateLbl.text = String(mGroup!.startdate)
        memberLbl.text = String(mGroup!.members)
        // Do any additional setup after
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        let id = mGroup!.id!
        if mGroup?.status == GroupTable.STATUS_BUILD {
            mPeople = PersonTable.get(db:mDBT,filter: PersonTable.STATUS == PersonTable.STATUS_WAIT_GROUP
                || (PersonTable.GROUP == id) )

        }
        else {
            mPeople = PersonTable.get(db:mDBT,filter: PersonTable.GROUP == id)
            tableView!.allowsSelection = false
        }
        if mGroup!.status == GroupTable.STATUS_BUILD {
            saveButton.isEnabled = true
            
            if mGroup!.members >= 3 {
                activateButton!.isEnabled = true
            }
        }
        else {
            saveButton.isEnabled = false
            activateButton.isEnabled = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        let id = mGroup!.id!
        let selectedPeople = PersonTable.get(db: mDBT, filter: PersonTable.GROUP == id)
        for person in selectedPeople {
            for i in 0...(mPeople!.count - 1 ) {
                if person.id == mPeople![i].id {
                    tableView.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .none)
                    tableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType = .checkmark
                }
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func passData (id: String, delegate: DismissalDelegate){
        dismissalDelegate = delegate
        mGroupId = id
        if id == "" {
            mInsert = true
            mGroup = GroupTable()
            let tlcode = MyPrefs.getPrefString(preference: MyPrefs.TL)
            let grnum = MyPrefs.getPrefInt(preference: MyPrefs.GROUP_NUM)
            MyPrefs.setPref(preference: MyPrefs.GROUP_NUM, value: grnum + 1)
            mGroup!.id = "\(tlcode)\(grnum)"
            mGroup!.desc = ""
            mGroup!.members = 0
            mGroup!.status = GroupTable.STATUS_BUILD
            mGroup!.startdate = 0
        }
        else {
            mInsert = false
            mGroup = GroupTable.getKey(db: mDBT, id: id)
        }
    }
    // MARK: Table View
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print (" Got num rows \(mPeople!.count)")
        
        return mPeople!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print ("getting cell")
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! SimplePersonCell
        let person = mPeople![indexPath.row]
        cell.NameLabel.text = person.name
        cell.pseudonymLabel.text = person.pseudonym
        if mGroup!.status == GroupTable.STATUS_BUILD {
            if person.group == mGroup!.id {
                cell.setSelected(true, animated: false)
            }
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
        activateButton.isEnabled = false
        mPeople?[didSelectRowAt.row].group = mGroup!.id
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didDeselectRowAt)
        //cell?.accessoryType = .none
        activateButton.isEnabled = false
        mPeople?[didDeselectRowAt.row].group = ""
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
/*    private func fudgeData(){
        let people = PersonTable.getAll(db: mDBT)
        for person in people {
            person.status = PersonTable.STATUS_WAIT_GROUP
            person.update(db: mDBT)
        }
        mGroup!.status = GroupTable.STATUS_BUILD
    } */

}
