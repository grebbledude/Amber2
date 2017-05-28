//
//  ReplaceSegue.swift
//  AmberLight
//
//  Created by Pete Bennett on 14/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit
/* 
 Not really sure this is doing anything worthwhile
 */

class ReplaceSegue: UIStoryboardSegue {
    override func perform() {
        let destVC = destination
        let navVC =    UIApplication.shared.keyWindow?.rootViewController   as! UINavigationController!
        navVC?.setViewControllers([destVC], animated: true)
    }

}
