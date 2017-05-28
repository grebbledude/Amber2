//
//  InitialTextViewController.swift
//  AmberLight
//
//  Created by Pete Bennett on 07/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit
/*
  This is a wrapper aroud the initial instructions page view controller.  It handles the page counter
 */

class InitialTextViewController: UIViewController, InitialTextDelegate, Themed {
    @IBOutlet weak var pageControl: UIPageControl!
    public weak var destination:UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        Theme.clearNavBar(viewController: self)
    }
    func pageViewController(_ pageViewController: InitialInstructionsPageControllerViewController,
                                    didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func pageViewController(_ pageViewController: InitialInstructionsPageControllerViewController,
                                    didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let initialPageViewController = segue.destination as? InitialInstructionsPageControllerViewController {
            initialPageViewController.initialDelegate = self
            destination = initialPageViewController
        }
    }
    

}
protocol InitialTextDelegate {
    /**
     Called when the number of pages is updated.
     
     - parameter count: the total number of pages.
     */
    func pageViewController(_ pageViewController: InitialInstructionsPageControllerViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter index: the index of the currently visible page.
     */
    func pageViewController(_ pageViewController: InitialInstructionsPageControllerViewController,
                                    didUpdatePageIndex index: Int)
    
}

