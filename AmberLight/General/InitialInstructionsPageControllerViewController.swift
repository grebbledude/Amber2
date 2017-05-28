//
//  InitialInstructionsPageControllerViewController.swift
//  AmberLight
//
//  Created by Pete Bennett on 07/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit

/*
 This is just a page view controller with fixed names for the view controllers
 */

class InitialInstructionsPageControllerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    
    private var mPageno = 0
    private var mPages: [UIViewController] = []
    public var initialDelegate: InitialTextDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        mPages.append(UIStoryboard(name: MyStory.Registration.rawValue , bundle: nil) .
            instantiateViewController(withIdentifier: "inst1"))
        mPages.append(UIStoryboard(name: MyStory.Registration.rawValue, bundle: nil) .
            instantiateViewController(withIdentifier: "inst2"))
        mPages.append(UIStoryboard(name: MyStory.Registration.rawValue, bundle: nil) .
            instantiateViewController(withIdentifier: "inst3"))
        self.dataSource = self
        self.delegate = self
        if let firstViewController = mPages.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        initialDelegate!.pageViewController(self, didUpdatePageCount: mPages.count)

        // Do any additional setup after loading the view.

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
    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let firstViewController = self.viewControllers?.first,
            let index = mPages.index(of: firstViewController) {
            initialDelegate?.pageViewController(self,
                                                         didUpdatePageIndex: index)
        }
    }


    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = mPages.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard mPages.count > previousIndex else {
            return nil
        }
        
        return mPages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = mPages.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let pagesCount = mPages.count
        
        guard pagesCount != nextIndex else {
            return nil
        }
        
        guard pagesCount > nextIndex else {
            return nil
        }
        
        return mPages[nextIndex]
    }
 /*   func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return mPages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = mPages.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    } */
}

        
