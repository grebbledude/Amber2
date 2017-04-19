//
//  QuestiionListController.swift
//  testsql
//
//  Created by Pete Bennett on 10/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import SQLite

class QuestionListController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    
    private var mDBT = DBTables()
    private var mPageViewController: UIPageViewController?
    private var mQuestions: [QuestionTable] = []
    private var mAnswers: [[String]] = []
    private var mAnswerTable: [[AnswerTable]] = []
    private var mValid: [Bool] = []
    private var mDisplayMode = false
    private var mCreateMode = false
    private var mDisplayDate = 0
    private var mDayNo = 0
    private var mCurrentPage = 0
    private var mPersonid=""
//    private var mRegCode = ""
    private var mStatus = ""
    private var mPageCount: Int?
    @IBOutlet weak var containerView: UIView!
    private var mPages: [QuestionPageController] = []
    private var mTarget = ""
    private var returnDelegate: UIViewController?
//    private var containerViewController: UIViewController!
    public static let EMPTY: [String] = []
    public static let PAGE_CONTAINER = "pageContainer"
    public static let LOCK_SEGUE = "questionToLock"
    public static let UNWIND_SEGUE = "unwindToRegistration"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if mQuestions.count == 0 {
            var prevResponses: [ResponseTable]?
            if mDisplayMode  {
                prevResponses = ResponseTable.get(db: mDBT,filter: ResponseTable.PERSONID == mPersonid && ResponseTable.DAYNO == mDayNo)
                mQuestions = QuestionTable.getWithResponseDate(db: mDBT, personid: mPersonid, dayNo: mDayNo)
            }
            else {
                prevResponses = ResponseTable.get(db: mDBT, filter: ResponseTable.PERSONID == mPersonid && ResponseTable.DAYNO == mDayNo)
                if prevResponses!.count == 0 {
                    mQuestions = QuestionTable.get(db: mDBT,filter: getQuestionType(), orderby: [QuestionTable.ID])
                }
                else {
                    mQuestions = QuestionTable.getWithResponseDate(db: mDBT, personid: mPersonid, dayNo: mDayNo)
                }
            }
            mValid = [Bool](repeating: false, count: mQuestions.count)
        
            var index = 0
            for question in mQuestions {
                mAnswerTable.append(AnswerTable.get(db: mDBT, filter: AnswerTable.QUESTIONID == question.id))
                index += 1
            }
            mAnswers = [[String]](repeating: [], count: mQuestions.count)
            if prevResponses!.count != 0 {
                for i in 0...(mQuestions.count - 1) {
                    for response in prevResponses! {
                        if response.question == mQuestions[i].id {
                            mAnswers[i].append(response.answer)
                        }
                    }
                }
            }
            mPageCount = mQuestions.count
            mPages.append(setControllerAt(0))
        }

  
    }
    public func passData(status: String = "", dayNo: Int = 0, createMode: Bool = true, displayMode: Bool = true, displayDate: Int = 0, personId: String = "", delegate: UIViewController? = nil){
//        mRegCode = regCode
        mDayNo = dayNo
        mCreateMode = createMode
        mDisplayMode = displayMode
        mDisplayDate = displayDate
        mPersonid = personId
        mStatus = status
        returnDelegate = delegate
        print ("passData")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        containerView.alpha = 0
        
    }
    
    // MARK: outlets
    @IBOutlet weak var trailConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!


    // MARK: actions
    @IBAction func pressSubmit(_ sender: UIBarButtonItem) {
        if mCreateMode {
            answersDone()
            let _ = navigationController?.popViewController(animated: true)
            // performSegue(withIdentifier: QuestionListController.LOCK_SEGUE, sender: self)
        }
        else {
            answersDone()
            if let vc_ci = returnDelegate as? CheckInController {
                vc_ci.returnResult(save: true)
                print ("got a return value")
            }
            let _ = self.navigationController?.popViewController(animated: true)
            
            print ("can continue")
            //performSegue(withIdentifier: CheckInController.QUESTION_CHECKIN, sender: self)
        }
    }
    @IBAction func pressCancel(_ sender: UIBarButtonItem) {
    }
    @IBAction func unwindToQuestionSegue (sender: UIStoryboardSegue) {
        print (sender.identifier ?? "no identifier")
        switch sender.identifier! {
        case LockController.LOCKQUESTION:
            updateResponses()
            mTarget = QuestionListController.UNWIND_SEGUE
        default: mTarget = ""
        }
    }
    
    // MARK: get Functions
    private func getQuestionType() -> Expression<Bool> {
        switch mStatus {
        case CheckInController.CHECKIN_INIT: return QuestionTable.INITQUESTION == true
        case CheckInController.CHECKIN_AMBER: return QuestionTable.AMBERALERT == true
        case CheckInController.CHECKIN_RED: return QuestionTable.REDALERT == true
        default:                                  return QuestionTable.INITQUESTION == true
        }

    }
    public func getAnswers(index: Int) -> [AnswerTable] {
        return mAnswerTable[index]
    }
    public func getText(index: Int) -> String {
        return mQuestions[index].text
    }
    public func checkForPreset(question: Int, answer: AnswerTable?) -> Bool{
        if !mDisplayMode {
            return false
        }
        if let ans = answer {
            for answerId in mAnswers[question] {
                if answerId == ans.id {
                    return true
                }
            }
        }
        else {
            if mAnswers[question][0] == "NONE" {
                return true
            }
        }
        return false
    }
    public func answersDone() {
        updateResponses()
        if mStatus != "" {  // This is a checkin ("" = initial questions)

            CheckInController.sendCheckinMessage(status: mStatus, dbt: mDBT)
        }
    }
    private func updateResponses() {
        
        // This first bit shouldn't ever happen.  Cleanup in case we hit an error in registration
        let responses = ResponseTable.get(db: mDBT, filter: ResponseTable.PERSONID == mPersonid && ResponseTable.DAYNO == mDayNo)
        for response in responses {
            response.delete(db: mDBT)
        }
        // Build a new one
        let responseTable = ResponseTable()
        responseTable.personid = ""
        responseTable.dayno = mDayNo
        responseTable.responseDate = CheckInController.getDate(date: Date())
        for i in 0...(mQuestions.count - 1) {
            responseTable.question = mQuestions[i].id
            for answer in mAnswers[i] {
                responseTable.answer = answer
                responseTable.id = "D" + String( mDayNo) + "Q" + responseTable.question + "A" + answer
                let _ = responseTable.insert(db: mDBT)
            }
        }
    }


    // MARK: Paging
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pagingView  = viewController as! PagingViewController
        if pagingView.pageNum! <= 0 {
            return nil
        }
        return getControllerAt(pagingView.pageNum! - 1)
        
    }
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let pagingView  = viewController as! PagingViewController
        if pagingView.pageNum! + 1 >= mPageCount! {
            return nil
        }
        return getControllerAt(pagingView.pageNum! + 1)
    }
    private func setControllerAt(_ index: Int) -> QuestionPageController{
        print(index)
        let page = (self.storyboard?.instantiateViewController(withIdentifier: mQuestions[index].multi! ? "questionmulti" : "questionsingle"))! as! QuestionPageController
        page.pageNum = index
        page.mParent = self
        page.mSelect = [Bool](repeatElement(false, count: mAnswerTable[index].count))
        for response in mAnswers[index] {
            for i in 0...(mAnswerTable[index].count - 1) {
                if mAnswerTable[index][i].id == response {
                    page.mSelect![i] = true
                }
            }
        }
        return page
    }
    private func getControllerAt(_ index: Int) -> UIViewController{
        if index >= mPages.count {
            mPages.append(setControllerAt(index))
        }
        print ("requested page \(index)")
        return mPages[index]
    }
    public func setAnswer(questionNum: Int, answer: String){
        print ("single " + answer)
        mAnswers[questionNum] = [answer]
        mValid[questionNum] = true
        navigationItem.leftBarButtonItems?.first?.isEnabled = canSubmit()        
        submitButton.isEnabled = canSubmit()
//        submitButton.isUserInteractionEnabled = canSubmit()
    }
    
    public func setAnswer(questionNum: Int, answerSet: [String]){
        for an in answerSet {
         print ("set " + an)
        }
        print("done")
        mAnswers[questionNum] = answerSet
        mValid[questionNum] = (answerSet.count != 0)
        submitButton.isEnabled = canSubmit()
  //      navigationItem.leftBarButtonItems?.first?.isEnabled = canSubmit()

    }
    public func canSubmit() -> Bool {
        if mDisplayMode {
            return false
        }
        for i in 0...(mValid.count - 1) {
            if !mValid[i] {
                return false
            }
        }
        return true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case QuestionListController.PAGE_CONTAINER:
            print("setting the pager")
            mPageViewController = segue.destination as? UIPageViewController
            mTarget = QuestionListController.PAGE_CONTAINER
        case QuestionListController.LOCK_SEGUE:
            let lockController = segue.destination as! LockController
            lockController.passData(lockCode: MyPrefs.getPrefString(preference: MyPrefs.LOCKCODE), source: LockController.LOCKQUESTION)
        default: break
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateSwipe(direction: .left)

        switch mTarget {
        case QuestionListController.PAGE_CONTAINER:
            let pageView = mPageViewController!
            pageView.delegate = self
            pageView.dataSource = self
            //           pageView.setTansitionStyle = .scroll  would need to achieve by overriding
            let _ = getControllerAt(0)
            pageView.setViewControllers(mPages, direction: .forward, animated: true, completion: nil)
        case QuestionListController.UNWIND_SEGUE:
            performSegue(withIdentifier: QuestionListController.UNWIND_SEGUE, sender: self)
        default: break

        }
            

        
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
                self.containerView.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: nil)
        })
    }
  // MARK: Static
    public static func sendResponse(dayno: Int, dbt: DBTables) {
        let responses = ResponseTable.get(db: dbt, filter: ResponseTable.DAYNO == dayno)
        let gcm = FcmMessage.builder(action: .ACT_ANSWERS)
            .addData(key: .PERSON_ID, data: MyPrefs.getPrefString(preference: MyPrefs.PERSON_ID))
            .addData(key: .DAYNO, data: dayno)
            .addData(key: .DATE, data: responses[0].responseDate)
            .addData(key: .NUM_ENTRIES, data: responses.count)
            .addData(key: .TEAM_LEADER, data: MyPrefs.getPrefString(preference: MyPrefs.TL))
        var answers = 0
        for response in responses {
            let _ = gcm
                .addData(key: .ANSWER, data: response.answer, suffix: String(answers))
                .addData(key: .QUESTION, data: response.question, suffix: String(answers))
            answers += 1
        }
        gcm.addData(key: .NUM_ENTRIES, data: answers ).send()
    }


}

class QuestionPageController: PagingViewController {
    public weak var mParent: QuestionListController?
    public var mSelect: [Bool]?
    
}
class AnswerCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // MARK: Properties
    @IBOutlet weak var answerLabel: UILabel!
    
}



