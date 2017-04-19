//
//  QuestionSingle.swift
//  testsql
//
//  Created by Pete Bennett on 11/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class QuestionSingleController: QuestionPageController, UITableViewDataSource, UITableViewDelegate {

    private var mAnswers: [AnswerTable]?

    override func viewDidLoad() {
        super.viewDidLoad()

        mAnswers = mParent!.getAnswers(index: pageNum!)
        QuestionLabel.text = mParent?.getText(index: pageNum!)

    }
    
    // MARK: outlets and actions
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Table view stuff
    func numberOfSections(in tableView: UITableView) -> Int{
        print("got sections")
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print ("got lines \(mAnswers!.count)")
        return mAnswers!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print ("getting cell")
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "AnswerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AnswerCell
        
        // Fetches the appropriate meal for the data source layout.
        let answer = mAnswers?[indexPath.row]
        
        cell.answerLabel.text = answer?.text
        // Now check if we are in display mode, and also the answer was previously selected
        if mParent!.checkForPreset(question: pageNum!, answer: answer!) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        let cell = tableView.cellForRow(at: didSelectRowAt)
        cell?.accessoryType = .checkmark
        mSelect![didSelectRowAt.row] = true
        mParent?.setAnswer(questionNum: pageNum!, answer: mAnswers![didSelectRowAt.row].id)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        let cell = tableView.cellForRow(at: didDeselectRowAt)
        cell?.accessoryType = .none
        mSelect![didDeselectRowAt.row] = false
    }
}
