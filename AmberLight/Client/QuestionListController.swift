//
//  QuestiionListController.swift
//  testsql
//
//  Created by Pete Bennett on 10/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//
/*
 This is the main controller around the questions. It has an embedded page view controller
 
 There is a problem withe the back button.  It comes from a navigation controller for checkin and registration, but needs a different view for display.
 On registration it needs to be hidden.
 //TODO: This would be better if we did it all modally and set it to appear or not that programmatically
 */
import UIKit
import SQLite

class QuestionListController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, Lockable, Themed {

    
    private var mDBT = DBTables()
    private var mPageViewController: UIPageViewController?
    private var mQuestions: [QuestionTable] = []
    private var mAnswers: [[String]] = []
    private var mAnswerTable: [[AnswerTable]] = []
    private var mValid: [Bool] = []
    public var mDisplayMode = false
    private var mCreateMode = false
    private var mDisplayDate = 0
    private var mDayNo = 0
    private var mCurrentPage = 0
    private var mPersonid=""
    public var mPageNumDisplay: PageNumIndicator!
//    private var mRegCode = ""
    private var mStatus = ""
    private var mPageCount: Int?
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageNumView: UIStackView!
    
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

        if mQuestions.count == 0 {  //Sometimes set before we get here?
            var prevResponses: [ResponseTable]?
            if mDisplayMode  {  // There must already be some answers to get
                prevResponses = ResponseTable.get(db: mDBT,filter: ResponseTable.PERSONID == mPersonid && ResponseTable.DAYNO == mDayNo)
                mQuestions = QuestionTable.getWithResponseDate(db: mDBT, personid: mPersonid, dayNo: mDayNo)
                mValid = [Bool](repeating: true, count: mQuestions.count)
            }
            else { // check if there are previous answers - don't think there can be in this setup
                prevResponses = ResponseTable.get(db: mDBT, filter: ResponseTable.PERSONID == mPersonid && ResponseTable.DAYNO == mDayNo)
                if prevResponses!.count == 0 {
                    mQuestions = QuestionTable.get(db: mDBT,filter: getQuestionType(), orderby: [QuestionTable.ID])
                }
                else {
                    mQuestions = QuestionTable.getWithResponseDate(db: mDBT, personid: mPersonid, dayNo: mDayNo)
                }
                mValid = [Bool](repeating: false, count: mQuestions.count)
            }
            mPageNumDisplay = PageNumIndicator(stackView: pageNumView!, initStatus: mValid)
        
            var index = 0
            for question in mQuestions {
                mAnswerTable.append(AnswerTable.get(db: mDBT, filter: AnswerTable.QUESTIONID == question.id))
                index += 1
            }
            mAnswers = [[String]](repeating: [], count: mQuestions.count)
            // If we have previous responses, split them between the answers
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
        if mDayNo == 0 {  // If this is registration, then you cannot uses the back button
            self.navigationItem.setHidesBackButton(true, animated:true);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
 //       containerView.alpha = 0
        pageNumView.backgroundColor = .black
        
    }
    
    // MARK: outlets
    @IBOutlet weak var trailConstraint: NSLayoutConstraint!

    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!


    // MARK: actions
    @IBAction func pressSubmit(_ sender: UIBarButtonItem) {
        answersDone()
        if !mCreateMode {
            if let vc_ci = returnDelegate as? CheckInController {  // if we  are checking in, then tell the checkin controller we have saved
                vc_ci.returnResult(save: true)
            }
        }
        let _ = self.navigationController?.popViewController(animated: true)
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
        return mPages[index]
    }
    // This is called from the question controller to set answers
    public func setAnswer(questionNum: Int, answer: String){

        mAnswers[questionNum] = [answer]
        mValid[questionNum] = true
        mPageNumDisplay.setStatus(number: questionNum, status: true)
        navigationItem.leftBarButtonItems?.first?.isEnabled = canSubmit()        
        submitButton.isEnabled = canSubmit()
    }
    
    public func setAnswer(questionNum: Int, answerSet: [String]){
        mAnswers[questionNum] = answerSet
        mValid[questionNum] = (answerSet.count != 0)
        mPageNumDisplay.setStatus(number: questionNum, status: mValid[questionNum])
        submitButton.isEnabled = canSubmit()

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
        //animateSwipe(direction: .left)

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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mParent?.mPageNumDisplay.setSelected(number: pageNum!)
    }
    
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



