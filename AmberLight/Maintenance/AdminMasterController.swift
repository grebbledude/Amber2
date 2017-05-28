//
//  AdminMasterController.swift
//  AmberLight
//
//  Created by Pete Bennett on 18/04/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit
import SQLite

class AdminMasterController: UIViewController, Lockable, Refreshable, Themed {
    
    weak var mEmbedded: UIViewController?

    @IBOutlet weak var containerView: UIView!
    @IBAction func pressEvent(_ sender: Any) {
//        let storyboard = UIStoryboard(name: MyStory.Maintenance.rawValue, bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "events")
//        self.navigationController?.pushViewController(vc, animated: true)
        self.performSegue(withIdentifier: "eventSegue", sender: self)
    }
    @IBOutlet weak var eventButton: UIButton!
    private let mDBT = DBTables()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func releaseData() {
        if let visible = UIWindow.visibleViewController(from: mEmbedded) as? Refreshable {
            visible.releaseData()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getEventData()
    }
    func refreshData() {
        getEventData()
        if let visible = UIWindow.visibleViewController(from: mEmbedded) as? Refreshable {
            visible.refreshData()
        }
    }
    private func getEventData() {
        let ts = Date().timeIntervalSinceReferenceDate - (24 * 3600)
        let events = EventTable.get(db: mDBT, filter: EventTable.TIMESTAMP > ts)
        eventButton.setTitle("\(events.count) events recently", for: .normal)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "tabSegue" {
            mEmbedded = segue.destination
        }
    }
    

}
