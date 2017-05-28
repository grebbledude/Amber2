//
//  TeamLeadController.swift
//  testsql
//
//  Created by Pete Bennett on 03/01/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit

class TeamLeadController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, Lockable, Refreshable {
    
    private var mTLs: [TeamLeadTable]?
    private let mDBT = DBTables()
    private var mName: String?
    private var mWaiting = false
    private var mWaitingCount = 0
    private weak var nameText: UITextField?
    private weak var contactText: UITextField?
    private weak var actionToEnable: UIAlertAction?

    @IBAction func pressAdd(_ sender: UIBarButtonItem) {
        getTLDetails()
    }
    @IBOutlet weak var congLbl: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBAction func pressAssign(_ sender: UIBarButtonItem) {
        let row = mWaitingCount == 0 ? 0 : picker.selectedRow(inComponent: 0)+1
        if row > 0 {
            if let tlrow = tableView.indexPathForSelectedRow?.row {
                let tl = mTLs![tlrow]
                if tl.code == "" || tl.code == "Active" {
                    FcmMessage.builder(action: .ACT_ASSIGN_TL)
                        .addData(key: .NUM_ENTRIES, data: row)
                        .addData(key: .TEAM_LEADER, data: tl.id)
                        .addData(key: .CONGREGATION, data: MyPrefs.getPrefString(preference: MyPrefs.CONGREGATION))
                        .send()
                } else {
                    UIAlertController.displayOK(viewController: self, title: "Invalid", message: "The team leader is not yet active", preferredStyle: .alert)
                }
            }
        }
    }

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var numEntriesLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let cong = MyPrefs.getPrefString(preference: MyPrefs.CONG_CODE)
        congLbl!.text = "Congregation code: \(cong)"

        tableView.delegate = self
        tableView.dataSource = self
        getTLs()
  //      clearNavBar()
        //Theme.clearNavBar(viewController: self)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        self.tabBarController?.tabBar.backgroundColor = UIColor.blue
        self.tabBarController?.tabBar.isTranslucent = false
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        Theme.clearNavBar(viewController: self)
    }
    override func viewDidAppear(_ animated: Bool) {
                reloadPicker()
    }
    func releaseData() {
        mTLs = []
    }
    func refreshData() {
        getTLs()
        tableView.reloadData()
    }
    func reloadPicker() {
        mWaitingCount = MyPrefs.getPrefInt(preference: MyPrefs.NUM_PEOPLE)
        numEntriesLabel!.text = String(mWaitingCount)
        let time = Double(MyPrefs.getPrefFloat(preference: MyPrefs.NUM_PEOPLE_TS))
        if time > 0 {
            let date = Date(timeIntervalSinceReferenceDate: time)
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            
            dateLabel!.text = formatter.string(from: date)
            picker.dataSource = self
            picker.delegate = self
        }
    }
    private func getTLs() {
        mTLs = TeamLeadTable.getAll(db: mDBT)
        FcmMessage.builder(action: .ACT_GET_COUNT)
            .addData(key: .CONGREGATION, data: MyPrefs.getPrefString(preference: MyPrefs.CONGREGATION))
            .send()
    }
    private func getTLDetails() {
        let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            self.mName = (alertController.textFields![0] as UITextField).text! as String
            if self.mName!.characters.count > 0 {
                RegistrationController.generateCode(type: .REG_CODE_TL, callback: self.gotCode)
                UIApplication.shared.beginIgnoringInteractionEvents()
                let deadlineTime = DispatchTime.now() + .seconds(6)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                    self.gotCode("", .REG_CODE_TIMEOUT)
                })
                self.mWaiting = true
                
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Name"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    private func activateTL() {
        
        let alert = UIAlertController(title: "Activate yourself as team leader", message: "Enter your name and phone number for clients to contact you as a team leader", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "Name"
            self.nameText = textField
            textField.addTarget(self, action: #selector(self.textChanged(_ :)), for: .editingChanged)
        })
        
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "Contact"
            self.contactText = textField
            textField.addTarget(self, action: #selector(self.textChanged(_ :)), for: .editingChanged)
        })
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        let action = (UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let name = alert!.textFields![0].text! // Force unwrapping because we know it exists.
            let contact = alert!.textFields![1].text!
            MyPrefs.setPref(preference: MyPrefs.TL_NAME, value: name)  // We now have user's name and coontact
            MyPrefs.setPref(preference: MyPrefs.TL_CONTACT, value: contact)     // save them away for the future
            let tl = TeamLeadTable.getKey(db: self.mDBT, id: MyPrefs.getPrefString(preference: MyPrefs.PERSON_ID))
            MyPrefs.setPref(preference: MyPrefs.I_AM_TEAMLEAD, value: true)
            tl!.code = ""
            tl!.update(db: self.mDBT)
            FcmMessage.builder(action: .ACT_SETUP_TL)
                .addData(key: .PERSON_ID, data: MyPrefs.getPrefString(preference: MyPrefs.PERSON_ID))
                .addData(key: .TL_NAME, data: name)
                .addData(key: .TL_CONTACT, data: contact)
                .send()
            //self.refreshData()
            let nc = UIApplication.shared.windows[0].rootViewController as! UINavigationController
            let storyboard = UIStoryboard(name: MyStory.Maintenance.rawValue, bundle: nil)
            nc.setViewControllers([storyboard.instantiateViewController(withIdentifier: "Admin")], animated: true)

        }))
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        actionToEnable = action
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        

    }
    func textChanged(_ sender:UITextField) {
        if let name = self.nameText?.text {
            if let contact = self.contactText?.text {
                self.actionToEnable?.isEnabled = (name != ""  && contact != "" )
                return
                
            }
        }
        self.actionToEnable?.isEnabled = false
    }
    public func gotCode(_ code: String, _ rc: RegCodeType) {
        if mWaiting {
            if rc.rawValue > 0 {
                mWaiting = false
                let tl = TeamLeadTable()
                tl.name = mName!
                tl.code = code
                var max = 0
                for teamlead in mTLs! {
                    if let value = Int(teamlead.id) {
                        if value > max {
                            max = Int(teamlead.id)!
                        }
                    }
                }
                max += 1
                tl.id = String(max)
                let _ = tl.insert(db: mDBT)
                UIApplication.shared.endIgnoringInteractionEvents()
                FcmMessage.builder(action: .ACT_NEW_CODE)
                    .addData(key: .REG_CODE, data: code)
                    .addData(key: .CONGREGATION, data: MyPrefs.getPrefString(preference: MyPrefs.CONGREGATION))
                    .addData(key: .REG_TYPE, data: RegCodeType.REG_CODE_TL.rawValue)
                    .addData(key: .TEAM_LEADER, data: "none")
                    .send()
                mTLs!.append(tl)
                tableView!.reloadData()
            }
            else {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.mWaiting = false
                let alertController = UIAlertController(title: "Cannot get new code", message: "An error occured getting a new code.  Are you connected to the internet?", preferredStyle: .alert)
                

                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                    (action : UIAlertAction!) -> Void in
                    
                })
                
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }

    }
    
    // MARK: Table stuff
    func numberOfSections(in tableView: UITableView) -> Int{
        // print("got sections")
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return mTLs!.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //print ("getting cell")
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") else {
                // Never fails:
                return UITableViewCell(style: .subtitle, reuseIdentifier: "UITableViewCell")
            }
            return cell
        }()
        cell.textLabel?.text = mTLs![indexPath.row].name
        cell.detailTextLabel?.text = "Code: " + mTLs![indexPath.row].code
        return cell

        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
      
        // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        // need to handle delete
        if mTLs![didSelectRowAt.row].code == "PENDING" {
            activateTL()
        } else {
            let cell = tableView.cellForRow(at: didSelectRowAt)
            cell?.accessoryType = .checkmark
            Theme.setCellLayer(view: cell!, selected: true)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        let cell = tableView.cellForRow(at: didDeselectRowAt)
        cell?.accessoryType = .none
        Theme.setCellLayer(view: cell!, selected: false)
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
    }
// MARK: Picker stuff
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ _pickerView: UIPickerView,numberOfRowsInComponent component: Int
        ) -> Int {
        return mWaitingCount == 0 ? 1 : mWaitingCount

    }
    func pickerView(_ _pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        return mWaitingCount == 0 ? "0" : String(row + 1)
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

class TeamLeadCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // MARK: Properties
    @IBOutlet weak var tlNameTxt: UILabel!
    @IBOutlet weak var tlCodeTxt: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func pressDelete(_ sender: UIButton) {
    }


    
}
