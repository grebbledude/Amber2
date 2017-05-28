//
//  HelpViewController.swift
//  playpen
//
//  Created by Pete Bennett on 01/05/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//
/*
 This is a combined tble view and page view.
 The table view gives a table of contents
 The page view enables you to swipe through the pages.
 
 We could develop this with a page indicator at the botom and move the table view to the current page and highlight it.  
 It's not very many pages though, so not sure it's worth the effort
 
 */

import UIKit

class HelpViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, Themed {
    @IBAction func pressReturn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func pressRight(_ sender: Any) {
        if let vc = pageController.viewControllers?[0] {
            let targetVC = pageViewController(pageController, viewControllerAfter: vc)
            
             pageController.setViewControllers([targetVC!], direction: .forward, animated: true, completion: nil)
        }
    }
    @IBAction func pressLeft(_ sender: Any) {
        if let vc = pageController.viewControllers?[0] {
            let targetVC = pageViewController(pageController, viewControllerBefore: vc)
            pageController.setViewControllers([targetVC!], direction: .reverse, animated: true, completion: nil)
        }
    }
    // This is the storyboard referemce, a title, and a source view controller (if help is pressed from that view controller, display this page)
    static let HELP_SOURCE = [
        ["helpIntro","What is Amber Light?", String(describing: ThemedViewController.self)],
        ["helpIntro1","How does it work?", ""],
        ["helpanon","What if my church isn't registered?", ""],
        ["helpCheckin","How do I check in?", ""],
        ["helpRegChurch","How to register my church", String(describing: RequestAdminController.self)],
        ["helpTeamLead","What do I do as a team leader?", String(describing: AdminMasterController.self)]
        ]

    @IBOutlet weak var tabView: UITableView!
    weak var pageController: UIPageViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        tabView.delegate = self
        tabView.dataSource = self
        
        tabView.rowHeight = UITableViewAutomaticDimension;
        tabView.estimatedRowHeight = 35.0;
  

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func pageViewController(_ pageView: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pNum: Int = {
            if let pagedController = viewController as? PagingViewController {
                let page = pagedController.pageNum! - 1
                if page < 0 {
                    return HelpViewController.HELP_SOURCE.count - 1
                }
                return page
            } else {
                return 0
            }
        }()
        return createVewController(pageNumber: pNum)
    }
    func pageViewController(_ pageView: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pNum: Int = {
            if let pagedController = viewController as? PagingViewController {
                let page = pagedController.pageNum! + 1
                if page >= HelpViewController.HELP_SOURCE.count {
                    return 0
                }
                return page
            } else {
                return 0
            }
        }()
        return createVewController(pageNumber: pNum)
    }
    private func createVewController (pageNumber: Int) -> PagingViewController{
        let vc = self.storyboard?.instantiateViewController(withIdentifier: HelpViewController.HELP_SOURCE[pageNumber][0]) as! PagingViewController
        vc.pageNum = pageNumber
        return vc
    }
    
    func tableView (_ view: UITableView, numberOfRowsInSection : Int) -> Int {
        return HelpViewController.HELP_SOURCE.count + 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "help",
                                                 for: indexPath) as! HelpCell
        cell.helpLabel!.text = indexPath.row == 0 ? "List of Contents:" : HelpViewController.HELP_SOURCE[indexPath.row - 1][1]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            pageController.setViewControllers([createVewController(pageNumber: indexPath.row - 1)], direction: .forward, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed" {
            if let pageViewController = segue.destination as? UIPageViewController
            {
                pageViewController.delegate = self
                pageViewController.dataSource = self
                let vc =  String(describing: self.presentingViewController)
                let index: Int = {
                    for i in 0...(HelpViewController.HELP_SOURCE.count - 1) {
                        if vc == HelpViewController.HELP_SOURCE[i][2] {
                            return i
                        }
                    }
                    return 0
                }()
                pageViewController.setViewControllers([createVewController(pageNumber: index)], direction: .forward, animated: true, completion: nil)
                pageController = pageViewController
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
class HelpCell: UITableViewCell {
    @IBOutlet weak var helpLabel: UILabel!
    
}
