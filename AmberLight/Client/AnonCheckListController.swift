//
//  AnonCheckListController.swift
//  AmberLight
//
//  Created by Pete Bennett on 09/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit
import SQLite

class AnonCheckListController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    CheckList, // Will revert to this screen after checkin
    Refreshable,  // refresh data when enter from baclground
    Lockable //  Will go to lock screen
{

 

    @IBOutlet weak var daysLbl: UILabel!
    @IBOutlet weak var checkinButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    private var mCheckIns:  [CheckInTable] = []
    private let mDBT = DBTables()
    private let ANON_CHECKIN_REQUIRED = 5
    private var mDaysLeft = 0
    private var mLastCheckDate = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
//        getTableData()
    }
    override func viewWillAppear(_ animated: Bool) {

        enableCheckButton()
        let lastCheckDt = MyPrefs.getPrefInt(preference: MyPrefs.LAST_CHECKIN)

        /* Now check if data has changed (or ever been set).  If so, refresh table data 
        */
        if lastCheckDt > mLastCheckDate {
            getTableData()
            mLastCheckDate = lastCheckDt
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // If last check date is 0 then data will be reloaded
        mLastCheckDate = 0
        mCheckIns = []
    }
    func refreshData() {
        if MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS) == MyPrefs.STATUS_ACTIVE {
            print("got active status")
            AppDelegate.setupNavigation(target: "CheckIn", storyboard: .Checkin)
 //           performSegue(withIdentifier: "nowActive", sender: self)
        } else {
            getTableData()
            tableView.reloadData()
            enableCheckButton()
        }
    }
    func releaseData() {
        mCheckIns = []  //entering backgroun mode, so release data
    }
    func enableCheckButton () {
        let lastCheckDt = MyPrefs.getPrefInt(preference: MyPrefs.LAST_CHECKIN)
        /*
         First see whether the checkin button should be activated.  This is between 18:00 and 02:00 if we haven't already checked in
         */
        if lastCheckDt > 0 {
            let currentDate = CheckInController.getDate(date: Date())
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH"
            dateFormatter.timeZone = TimeZone.ReferenceType.default
            let hour = Int(dateFormatter.string(from: Date()))!
            if (hour >= 18  || hour < 2) && currentDate != lastCheckDt {
                checkinButton.isEnabled = true
            } else {
                checkinButton.isEnabled = false
            }
        } else {
            checkinButton.isEnabled = true
        }
    }
    // MARK: table functions
    private func getTableData() {
        let DAYS_TO_CHECKIN = 1
        mCheckIns = []
        let checkins = CheckInTable.get(db: mDBT, filter: CheckInTable.ID == CheckInTable.ID, orderby: [CheckInTable.C_DATE + " desc"])
        //  The above won't include all the missed checkins
        //  Therefore we will copy the array.
        // First copy existing
        if let checkinFirst = checkins.first {
            mDaysLeft = DAYS_TO_CHECKIN
            var prevDate = CheckInController.getCalDate(date: checkinFirst.date)
            for checkin in checkins {
                let currDate = CheckInController.getCalDate(date: checkin.date)
                while currDate > prevDate {
                    let check = CheckInTable()
                    check.date = CheckInController.getDate(date: prevDate)
                    check.status = CheckInController.CHECKIN_MISSED
                    mCheckIns.append(check)
                    prevDate = Calendar.current.date(byAdding: .day, value: 1, to: prevDate)!
                    mDaysLeft = DAYS_TO_CHECKIN
                }
                mCheckIns.append(checkin)
                prevDate = Calendar.current.date(byAdding: .day, value: 1, to: prevDate)!
                mDaysLeft -= 1
                if mDaysLeft == 0 {
                    let status = MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS)
                    if status == MyPrefs.STATUS_ANON {
                        MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_ANON_DONE)
                        FcmMessage.builder(action: .ACT_ANON_DONE)
                            .addData(key: .TIMEZONE, data: TimeZone.current.abbreviation()!)
                            .addData(key: .IOS, data: true)
                            .send()
                    }
                }
            }
        }
        /*
         This has done up to the end of the checkins, but we may have missed some.  First we work out when we have to go up
         to.  That depends on if it is after end of checkin period
         */
        let hour = Calendar.current.component(.hour, from: Date())
        var lastDate: Date
        if hour >= 18  || hour < 2 {
            lastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        } else {
            lastDate = Date()
        }
        if let lastCheck = checkins.last {
            var prevDate = Calendar.current.date(byAdding: .day, value: 1, to: CheckInController.getCalDate(date: lastCheck.date))!
            while lastDate >= prevDate {
                mDaysLeft = 5
                let check = CheckInTable()
                check.date = CheckInController.getDate(date: prevDate)
                check.status = CheckInController.CHECKIN_MISSED
                mCheckIns.append(check)
                prevDate = Calendar.current.date(byAdding: .day, value: 1, to: prevDate)!
            }
        }
        if MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS) == MyPrefs.STATUS_ANON {
            daysLbl.text = "You need \(mDaysLeft) more consecutive checkins"
        } else {
            daysLbl.text = "You will be assigned a group over the next few days"
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        // If not team lead, the first entry is blank - it is a placeholder for profile
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        // Let's explain the next statements.
        // First - if not team lead, then section 0 is always 1
        return mCheckIns.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        // Three types of cell.  Profile, header and detail.  Profile is if not team lead and it is section 0.
        //  header is row 0 in a section.
        // otherwise it is detail

        let cell = tableView.dequeueReusableCell(withIdentifier: "checkin", for: indexPath) as! AnonCheckCell
        cell.lblDate.text = CheckInController.formatDate(date: mCheckIns[indexPath.row].date)
        switch mCheckIns[indexPath.row].status {
        case CheckInController.CHECKIN_GREEN:
            cell.lblDate.backgroundColor = UIColor.green
        case CheckInController.CHECKIN_RED:
            cell.lblDate.backgroundColor = UIColor.red
        case CheckInController.CHECKIN_AMBER:
            cell.lblDate.backgroundColor = UIColor.yellow
        case CheckInController.CHECKIN_MISSED:
            cell.lblDate.backgroundColor = UIColor.gray
        default:
            cell.lblDate.backgroundColor = UIColor.gray
            
        }
        return cell
        
    }
    
/*    Don't need all this
     func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
        if didSelectRowAt.row == 0 {

            
        }
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didDeselectRowAt)
        //cell?.accessoryType = .none
        
    }
*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print ("getting segue")
    }
    

}
class AnonCheckCell: UITableViewCell {
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var lblStatus: UILabel!


    
}
