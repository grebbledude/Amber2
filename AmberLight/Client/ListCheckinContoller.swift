//
//  ListCheckinContoller.swift
//  testsql
//
//  Created by Pete Bennett on 28/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//
/*
 This is for both the checkins by group, checkins by person and checkins for the whole church as team leader
 Probably be a better option to split this, but somehing for the future.
 Also the current idea of swiping in from the side is not good.
 
 */
import UIKit
import SQLite

class ListCheckinController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExpandableHeaderDelegate, UIGestureRecognizerDelegate, DismissalDelegate, CheckList,
    Lockable, // Shouldshow lock screen
    Refreshable  // Should refresh data when returning
    {

    private var mCheckinGroups: [CheckInController.CheckinGroup]?
    private var mExpanded: [Bool] = []
    private var mDisplayDate: Date?
    private var mPersonID: String?
    public static let DISPLAY_GROUP_PERSON = 0
    public static let DISPLAY_PERSON_HIST = 1
    private var mDisplayType = ListCheckinController.DISPLAY_GROUP_PERSON;
    private var mDBT = DBTables()
    private var mIsTl = false
    public static let CheckInSeque = "checkinSegue"
    public static let SettingsSegue = "SettingsSegue"
    public static let QuestionSeque = "questionSegue"
    public static let PanicSeque = "panicSegue"
    private var mCurrentGroup: CheckInController.CheckinGroup?
    private var mLastCheck: Double = 0.0
    private var mCurrentPerson = ""
    
    public static let LOCK_SEGUE = "lockSegue"
    private var mPrayer: FloatPrayerButton?



    @IBOutlet weak var notificationButton: UIBarButtonItem!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleItem: UINavigationItem!
    @IBOutlet weak var panicButton: UIBarButtonItem!
    @IBOutlet weak var checkinButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func pressCheckin(_ sender: UIBarButtonItem) {
        if mIsTl {
            if let path = tableView!.indexPathForSelectedRow {
                let data = mCheckinGroups![path.section].children![path.row - 1]
                switchDisplay(currentDisplayType: mDisplayType, childKey: data.id!)
                
            }
            
        }
        else {
            performSegue(withIdentifier: ListCheckinController.CheckInSeque, sender: self)
    
        }
    }
    
    @IBAction func pressPanic(_ sender: UIBarButtonItem) {
/*
 * The panic button is used for both panic as a client and also to display questions as a team
 * leader.  Questions only exist for red or amber checkin though
 *
 */
        if mIsTl {
            if let path = tableView!.indexPathForSelectedRow {
                mCurrentGroup = mCheckinGroups![path.section].children![path.row - 1]
                if mCurrentGroup?.status! == CheckInController.CHECKIN_RED || mCurrentGroup?.status! == CheckInController.CHECKIN_AMBER {
                    performSegue(withIdentifier: ListCheckinController.QuestionSeque, sender: self)
                    // do question stuff.
                }
            }
        }
        else {
            performSegue(withIdentifier: ListCheckinController.PanicSeque, sender: self)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mIsTl = MyPrefs.getPrefBool(preference: MyPrefs.I_AM_TEAMLEAD)

        let date: Date = Date()
        let cal: Calendar = Calendar(identifier: .gregorian)
        
        mDisplayDate = cal.date(bySettingHour: 18, minute: 0, second: 0, of: date)!.addingTimeInterval(-3600*24)

        mPersonID = MyPrefs.getPrefString(preference: MyPrefs.PERSON_ID);

        display_group()  // Always start off by displaying by group

        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension;  // required in order for cell to auto resize
        self.tableView.estimatedRowHeight = 44.0;
        // This next bit is to allow swipe left and right to page
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        checkinButton.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.init(white: 0.8, alpha: 1.0)], for: .disabled)
    }
    
    override func viewWillAppear(_ animated: Bool) {
/*
 * Basically just set up the labels on the buttons, and which buttons are active.
 *
 */
 
        super.viewWillAppear(animated)
        self.tableView.alpha = 0
        if (mIsTl) {
            panicButton!.title = "Q's"
            checkinButton!.title = "Hist"
            notificationButton.isEnabled = false
        }
        else {
            let startTime = CheckInController.getCalDate(date: MyPrefs.getPrefInt(preference: MyPrefs.STARTDATE))
            if startTime.compare(Date()) != .orderedAscending {  // Not yet got to start date
                panicButton.isEnabled = false
                checkinButton.isEnabled = false
            }
            else {
                let daysDiff = Int(Date().timeIntervalSince(startTime) / (24*3600))
                if daysDiff > 40 {
                    panicButton.isEnabled = false
                    checkinButton.isEnabled = false
                }
                else {
                    panicButton.isEnabled = true
                    checkinButton.isEnabled = {
                        let lastCheckDt = MyPrefs.getPrefInt(preference: MyPrefs.LAST_CHECKIN)
                        if lastCheckDt > 0 {
                            let lastCheck = CheckInController.getCalDate(date: lastCheckDt)
                            let lastCheckDiff = Int(Date().timeIntervalSince(lastCheck) / (24*3600))
                            if lastCheckDiff == 0 {
                                return false
                            }
                        }
                        let hour = getHour()
                        if hour >= 18 || hour <= 2 {
                            return true
                        }
                        return false
                    }()
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        let diff = Date().timeIntervalSinceReferenceDate - mLastCheck
        if diff > 3600 {
            checkRequests()
        }
//        animateSwipe(direction: .left)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getHour() -> Int {
        let timeZone = TimeZone.init(abbreviation: MyPrefs.getPrefString(preference: MyPrefs.TIMEZONE))
        var calendar = Calendar.current
        if let tz = timeZone {
            calendar.timeZone = tz
        }
        return calendar.dateComponents([.hour], from: Date()).hour!
    }
    func checkRequests() {
        let ts = Date().timeIntervalSinceReferenceDate - (8 * 3600)
        let requests = RequestTable.get(db: mDBT, filter: RequestTable.TIMESTAMP > ts && RequestTable.REPLIED == false)
        if requests.count > 0 {
            if let prayer = mPrayer {
                prayer.setBadge(count: requests.count)
            } else {
                mPrayer = FloatPrayerButton(delegate: self, parent: self.view, count: 1)
            }
        } else {
            if let prayer = mPrayer {
                prayer.removeFromSuperview()
                mPrayer = nil
            }
        }
    }
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                mDisplayDate = Calendar.current.date(byAdding: .day, value: -1, to: mDisplayDate!)
                display_group()
                tableView!.reloadData()
                animateSwipe(direction: .right)
            case UISwipeGestureRecognizerDirection.left:
                mDisplayDate = Calendar.current.date(byAdding: .day, value: 1, to: mDisplayDate!)
                display_group()
                tableView!.reloadData()
                animateSwipe(direction: .left)
            default:
                break
            }
        }
    }
    
    // MARK table functions
    func numberOfSections(in tableView: UITableView) -> Int{
        // If not team lead, the first entry is blank - it is a placeholder for profile
        return mCheckinGroups!.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        // Let's explain the next statements.
        // First - if not team lead, then section 0 is always 1
        if !mIsTl && section == 0 {
            return 1
        }
        // If it is not a team lead we need to subtract 1 for the profile section that is in place 0
        // In any other case it is either 1 (not expanded) or 1 more than number of rows in section (+1 is for header row)
        return mExpanded[section] ? mCheckinGroups![section].children!.count + 1 : 1
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        // Three types of cell.  Profile, header and detail.  Profile is if not team lead and it is section 0.
        //  header is row 0 in a section.
        // otherwise it is detail
        var returnCell: UITableViewCell?
        if !mIsTl && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileCell
            cell.delegate = self
            if mExpanded[0] {
                let tl = MyPrefs.getPrefString(preference: MyPrefs.TL_NAME)
                let tlContact = MyPrefs.getPrefString(preference: MyPrefs.TL_CONTACT)
                let pseudonym = MyPrefs.getPrefString(preference: MyPrefs.PSEUDONYM)
                if MyPrefs.getPrefBool(preference: MyPrefs.ANON_MODE) {
                    cell.profileIInfo!.text = "You are known as \(pseudonym)"
                } else {
                    cell.profileIInfo!.text = "You are known as \(pseudonym), your team leader is \(tl) and his contact number is \(tlContact)"
            
                }
            }
            else {
                cell.profileIInfo!.text = "Click for profile info"
            }
            returnCell = cell
        }
        else {
        
            //print ("getting cell")
            // Table view cells are reused and should be dequeued using a cell identifier.
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckinHeader", for: indexPath) as! CheckInHeaderCell
                cell.headerNameLabel.text = mCheckinGroups![indexPath.section].name
                cell.headerStatusLabel.text = mCheckinGroups![indexPath.section].status
                cell.headerStatusLabel.backgroundColor = getColour(status: cell.headerStatusLabel.text!)
                cell.delegate = self
                cell.expanded = mExpanded[indexPath.section]
                cell.section = indexPath.section
                return cell
            }
            let rowNum = indexPath.row - 1
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckinDetail", for: indexPath) as! CheckinDetailCell
            let data = mCheckinGroups![indexPath.section].children![rowNum]
            cell.detailNameLabel.text = data.name
            cell.detailStatusLabel.text = data.status
            cell.detailStatusLabel.backgroundColor = getColour(status: cell.detailStatusLabel.text!)
            returnCell = cell
        }
        return returnCell!
        
    }
    func getColour(status: String) -> UIColor {
        switch status {
        case CheckInController.CHECKIN_RED: return .red
        case CheckInController.CHECKIN_AMBER: return .yellow
        case CheckInController.CHECKIN_GREEN: return .green
        default: return .lightGray
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {

        if didSelectRowAt.row == 0 {
            let expanded = !mExpanded[didSelectRowAt.section]
            mExpanded[didSelectRowAt.section] = expanded
            tableView.reloadSections([didSelectRowAt.section], with: .automatic)
        } else {
            let cell = tableView.cellForRow(at: didSelectRowAt)
            cell?.accessoryType = .checkmark
            Theme.setCellLayer(view: cell!, selected: true)
        }
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        let cell = tableView.cellForRow(at: didDeselectRowAt)
        cell?.accessoryType = .none
        
        Theme.setCellLayer(view: cell!, selected: true)
        
    }
    
    func sectionHeaderView(expanded: Bool, section: Int) {
        mExpanded [section] = expanded
        tableView.reloadSections([section], with: .automatic)
    }
    private func animateSwipe(direction: AnimDirection) {
        let dir = CGFloat(direction.rawValue)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.leadingConstraint.constant += self.view.bounds.width * dir
            self.trailConstraint.constant += self.view.bounds.width * dir
            self.view.layoutIfNeeded()
        }, completion: {(_ value: Bool) in
            self.leadingConstraint!.constant += 2 * self.view.bounds.width * dir * (-1)
            self.trailConstraint!.constant += 2 * self.view.bounds.width * dir * (-1)
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                self.leadingConstraint.constant += self.view.bounds.width * dir 
                self.trailConstraint.constant += self.view.bounds.width * dir
                self.tableView.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: nil)
        })
    }

    
    private func display_person(key: String) {
        mCheckinGroups = []
        if !mIsTl {
            mCheckinGroups?.append(CheckInController.CheckinGroup())
        }
        let checkinTable = CheckInTable.getKey(db: mDBT,id: key);
        let group = checkinTable!.group;
        titleItem!.title = checkinTable!.pseudonym!
        let personid = checkinTable!.personId;
        let checkinTables = CheckInTable.get(db: mDBT,filter: CheckInTable.PERSONID == personid!,orderby: [CheckInTable.DATE])
        let groupCheckinTables = CheckInTable.get(db: mDBT,filter: CheckInTable.GROUP == group!,orderby: [CheckInTable.DATE,CheckInTable.PERSONID])
        var currentpersonPos = checkinTables.count
        var currentGroupPos = groupCheckinTables.count
        var currentItem=0;
        /* We are now all set up to scroll backwards through both lists
        checkintables:  All checkins for this person
        group checkin tables:  All checkins by any members of the group.
        (*/
        while (currentpersonPos > 0) {  // We only stop when we reach the last entry for the person.
            
            var newGroup = CheckInController.CheckinGroup()
            currentpersonPos -= 1                               //  We started 1 more than last entry
            let currPerson = checkinTables[currentpersonPos]
            var groupMembers = 0
            currentGroupPos -= 1
            while (currentGroupPos >= 0  // stop if we reach the end
                && groupCheckinTables[currentGroupPos].date >= currPerson.date) {  // read back until we find an entry for today (or earlier)
                if groupCheckinTables[currentGroupPos].date == currPerson.date { // and count the number of entries for this day
                    groupMembers += 1;
                }
                currentGroupPos -= 1;
            }
            currentGroupPos += 1
            newGroup.name = String(currPerson.date!)
            newGroup.id = currPerson.id
            
            newGroup.status = currPerson.status
            newGroup.groupStatus = groupCheckinTables[currentGroupPos + 1].status
            newGroup.statusDate = currPerson.date
            newGroup.children = []
    /*
     At this point, group members is the total number of entries for this date, including the main group one.
     currentgrouppos is than the group entry, so to start with the group entry we start at 0 and add to currentgrouppos
     */
            for i in 0...(groupMembers - 1) {
                let otherMember = groupCheckinTables[currentGroupPos + i]
                var otherGroup = CheckInController.CheckinGroup()
                if i == 0 {
                    otherGroup.name = "Group: " + otherMember.groupName
                }
                else {
                    otherGroup.name = otherMember.pseudonym
                }
                otherGroup.id = otherMember.id
                otherGroup.status = otherMember.status
                otherGroup.groupStatus = newGroup.groupStatus
                otherGroup.statusDate = otherMember.date!
                newGroup.children?.append( otherGroup)
            }
            mCheckinGroups!.append(newGroup)
            currentItem += 1;
        }
        mExpanded = Array(repeating: false, count: (mCheckinGroups!.count))

    }
    private func display_group() {
        mCheckinGroups = []
        if !mIsTl {  // add dummy entry for where profile will show
            mCheckinGroups?.append(CheckInController.CheckinGroup())
        }
        let displayDate = CheckInController.getDate(date: mDisplayDate!)
        titleItem!.title = String(displayDate)
        let checkInTables = CheckInTable.get(db: mDBT, filter: CheckInTable.DATE == displayDate, orderby: [CheckInTable.GROUP, CheckInTable.PERSONID])
        var groupid: String?
    /*
     If we are a team leader, display for all.  If not, then first entry goes at the top - entry 0.
     */
        if mIsTl     {
            groupid = "Never find this"
        }
        
        else {
            groupid = MyPrefs.getPrefString(preference: MyPrefs.GROUP)
        }
        var currentItem = 0;  //  item 0 will start blank but be overwritten if not team lead
        var currGroup = "";
        var checkinGroup = CheckInController.CheckinGroup();
        var foundThisGroup = false
        if (checkInTables.count > 0) {
            for i in 0...(checkInTables.count - 1) {
                let thisItem = checkInTables[i]
                if thisItem.group != currGroup {
                    if currGroup == groupid {
                        mCheckinGroups![1] =  checkinGroup
                        foundThisGroup = true
                    } else {
                        if ((!mIsTl) || i > 0) { //  if not team lead then add a dummy entry 0
                            mCheckinGroups!.append( checkinGroup)
                            currentItem += 1
                        }
                    }
                    currGroup = thisItem.group;
                    checkinGroup = CheckInController.CheckinGroup();
                    checkinGroup.name = thisItem.groupName;
                    checkinGroup.groupStatus = thisItem.status;
                    checkinGroup.status = thisItem.status;
                    checkinGroup.id = thisItem.id;
                    checkinGroup.statusDate = Int(thisItem.date);
                    checkinGroup.children = []
                } else {
                    var child = CheckInController.CheckinGroup()
                    child.groupStatus = checkinGroup.groupStatus;
                    child.status = thisItem.status;
                    child.statusDate = Int(thisItem.date);
                    child.name = thisItem.pseudonym;
                    child.id = thisItem.id;
                    checkinGroup.children?.append(child)
    
                }
    
            }
            if currGroup == groupid {
                mCheckinGroups?[1] = checkinGroup
                foundThisGroup = true
            } else {
                mCheckinGroups?.append(checkinGroup)
            }
            if (!foundThisGroup) && !mIsTl  {
                mCheckinGroups!.remove(at: 1)
            }
        }
        mExpanded = Array(repeating: false, count: (mCheckinGroups!.count))
        if !mIsTl && (mCheckinGroups?.count)! > 0 && foundThisGroup {                  // For client, auto expnad my group.
            mExpanded[1] = true
        }

    }
    public func switchDisplay(currentDisplayType: Int, childKey:String) {
    
        if currentDisplayType == ListCheckinController.DISPLAY_GROUP_PERSON {
            mCurrentPerson = childKey
            display_person(key: childKey)
        }
        else {
            let checkinTable = CheckInTable.getKey(db: mDBT,id: childKey);
            mDisplayDate = CheckInController.getCalDate(date: (checkinTable?.date)!);
            display_group()

        }
        mDisplayType = (currentDisplayType - 1) * (-1)
        tableView!.reloadData()
    }
    // MARK: refresh/reload
    func releaseData() {
        mCheckinGroups = []
    }
    func refreshData() {
        if mDisplayType == ListCheckinController.DISPLAY_GROUP_PERSON {
            display_group()
        }
        else {
            display_person(key: mCurrentPerson)
        }
        tableView!.reloadData()
        checkRequests()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == ListCheckinController.QuestionSeque {
            let target = segue.destination as! EmbededQuestionController
            let checkin = CheckInTable.getKey(db: mDBT, id: mCurrentGroup!.id!)
            let group = GroupTable.getKey(db: mDBT, id: checkin!.group)
            let date = CheckInController.getCalDate(date: mCurrentGroup!.statusDate!)
            let dayno = CheckInController.getDayNo(date: date, startDay: (group?.startdate!)!)
//            target.passData(status: "", dayNo: dayno, createMode: false, displayMode: true, displayDate: checkin!.date, personId: checkin!.personId!, delegate: self)
            target.passData(dayNo: dayno, displayDate: checkin!.date, personId: checkin!.personId!)
        }
        else {
            if segue.identifier! == ListCheckinController.SettingsSegue {
                let target = segue.destination as! Dismissable
                target.dismissalDelegate = self
            }
        }
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    

}
class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var profileIInfo: UILabel!
    public var expanded = false
    public var delegate: ExpandableHeaderDelegate?
 //   private var first = true


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func toggleOpen() {
        expanded = !expanded
        self.delegate?.sectionHeaderView(expanded: expanded, section: 0)
        
    }
}
class CheckinDetailCell: UITableViewCell {
    
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var detailStatusLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
class CheckInHeaderCell: UITableViewCell {
    
    public var section: Int?
    public var expanded = false
    public var delegate: ExpandableHeaderDelegate?
    private var first = true
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var headerStatusLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func toggleOpen() {
        expanded = !expanded
        self.delegate?.sectionHeaderView(expanded: expanded, section: self.section!)
        
    }
    
}
