//
//  DebugControllerTableViewController.swift
//  testsql
//
//  Created by Pete Bennett on 13/01/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit
import SQLite

class DebugController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExpandableHeaderDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBAction func resetApp(_ sender: Any) {
        
        AnswerTable.drop(db: mDBT)
        CheckInTable.drop(db: mDBT)
        EventTable.drop(db: mDBT)
        GroupTable.drop(db: mDBT)
        PersonTable.drop(db: mDBT)
        QuestionTable.drop(db: mDBT)
        ResponseTable.drop(db: mDBT)
        TeamLeadTable.drop(db: mDBT)
        RequestTable.drop(db: mDBT)
        MyPrefs.reset()
        AppDelegate.initialiseDB()
        AppDelegate.setupNavigation(target: "intro", storyboard: .Registration)
        dismiss(animated: true, completion: nil)
//        performSegue(withIdentifier: "resetSegue", sender: self)
    }
    public var mExpanded: [Bool]?
    public weak var dismissalDelegate: DismissalDelegate?
    private var mResponses: [ResponseTable]?
    private var mAnswers: [AnswerTable]?
    private var mQuestions: [QuestionTable]?
    private var mGroups: [GroupTable]?
    private var mKeys: [String]?
    private var mData: [String]?
    private var mDBT  = DBTables()
    
 

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        mExpanded = [false, false, false, false, false]
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if mExpanded![section] {
            switch section {
            case 0:
                if mResponses == nil {
                    mResponses = ResponseTable.getAll(db: mDBT)
                }
                return (mResponses?.count)! + 1
            case 1:
                if mGroups == nil {
                    mGroups = GroupTable.getAll(db: mDBT)
                }
                return (mGroups?.count)! + 1
            case 2:
                if mQuestions == nil {
                    mQuestions = QuestionTable.getAll(db: mDBT)
                }
                return (mQuestions?.count)! + 1
            case 3:
                if mAnswers == nil {
                    mAnswers = AnswerTable.getAll(db: mDBT)
                }
                return (mAnswers?.count)! + 1
            case 4:
                if mKeys == nil {
                    let dict = MyPrefs.getPrefs()
                    mKeys = []
                    mData = []
                    for (key,data) in dict {
                        mKeys!.append(key)
                        mData!.append(data)
                        }
                }
                return (mKeys!.count) + 1
            default:
                return 0
            }
        }
        else {
            return 1
        }

    }
    
    func sectionHeaderView(expanded: Bool, section: Int) {
        mExpanded![section] = expanded
        tableView.reloadSections([section], with: .automatic)
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DebugHeader") as! DebugHeaderCell
            cell.delegate = self
            cell.section = indexPath.section
            switch indexPath.section {
            case 0:
                cell.headerNameLabel!.text = "Responses"
            case 1:
                cell.headerNameLabel!.text = "Groups"
            case 2:
                cell.headerNameLabel!.text = "Questions"
            case 3:
                cell.headerNameLabel!.text = "Answers"
            case 4:
                cell.headerNameLabel!.text = "Prefs"
            default:
                cell.headerNameLabel!.text = "Something wrong"
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "DebugDetail") as! DebugDetailCell
   
        var line1: String?
        var line2: String?

        switch indexPath.section {
        case 0:
            line1 =  mResponses![indexPath.row - 1].id
            line2 = String(mResponses![indexPath.row - 1].responseDate) + mResponses![indexPath.row - 1].personid!
        case 1:
            line1 =  mGroups![indexPath.row - 1].id
            line2 = String(mGroups![indexPath.row - 1].desc)
        case 2:
            line1 =  mQuestions![indexPath.row - 1].id
            line2 = String( (mQuestions![indexPath.row - 1].redAlert! ? "y" : "n" ) +  (mQuestions![indexPath.row - 1].amberAlert! ? "y" : "n" ) + (mQuestions![indexPath.row - 1].initQuestion! ? "y" : "n" ) + (mQuestions![indexPath.row - 1].multi! ? "y" : "n" )  )
        case 3:
            line1 =  mAnswers![indexPath.row - 1].id
            line2 = String(mAnswers![indexPath.row - 1].questionid )
        case 4:
            line1 = mKeys![(indexPath.row - 1)]
            line2 = mData![(indexPath.row - 1)]
        default:
            line1 = ""
            line2 = ""
        }
        cell.line1Label.text = line1
        cell.line2Label.text = line2
        return cell
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
class DebugHeaderCell: UITableViewCell {
    
    public var section: Int?
    public var expanded = false
    public var delegate: ExpandableHeaderDelegate?
    private var first = true
    @IBOutlet weak var headerNameLabel: UILabel!

    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            toggleOpen()
        }
        
    }
    func toggleOpen() {
        expanded = !expanded
        self.delegate?.sectionHeaderView(expanded: expanded, section: self.section!)
        
    }
    
}
class DebugDetailCell: UITableViewCell {
    
    @IBOutlet weak var line1Label: UILabel!
    @IBOutlet weak var line2Label: UILabel!

    
}
