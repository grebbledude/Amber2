//
//  EncourageControllerViewController.swift
//  AmberLight
//
//  Created by Pete Bennett on 14/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit

class EncourageController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = self.view!.viewWithTag(1) as! UIButton
        button.addTarget(self, action: #selector(pressReturn), for: .touchUpInside)
        self.navigationItem.hidesBackButton = true

        // Do any additional setup after loading the view.
    }
    func pressReturn(sender: UIButton) {
        let navC = self.navigationController!
        var stackSize = navC.viewControllers.count
        while stackSize > 0 {
            stackSize -= 1
            if navC.viewControllers[stackSize] is CheckList {
                navC.popToViewController(navC.viewControllers[stackSize], animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
protocol CheckList {
    func viewDidLoad()
}
