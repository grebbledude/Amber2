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
        // mParent has been set in the passData function.  It exists in the QuestionPageController subclass of TableViewController
        // This isn't the preferred way of doing this - it should be called delegate
        
        //Get the Question and possible answers from the parent.
        
        mAnswers = mParent!.getAnswers(index: pageNum!)
        QuestionLabel.text = mParent?.getText(index: pageNum!)
        tableView.dataSource = self
        tableView.delegate = self
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 50
        if mParent!.mDisplayMode {
            tableView.isUserInteractionEnabled = false
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // MARK: outlets and actions
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Table view stuff
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return mAnswers!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "AnswerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AnswerCell
        
        // Fetches the appropriate meal for the data source layout.
        let answer = mAnswers?[indexPath.row]
        
        cell.answerLabel.text = answer?.text
        // Now check if we are in display mode, and also the answer was previously selected
        if mParent!.checkForPreset(question: pageNum!, answer: answer!) {
            cell.accessoryType = .checkmark
            Theme.setCellLayer(view: cell, selected: true)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        let cell = tableView.cellForRow(at: didSelectRowAt)
        cell?.accessoryType = .checkmark
        Theme.setCellLayer(view: cell!, selected: true)
        mSelect![didSelectRowAt.row] = true
        mParent?.setAnswer(questionNum: pageNum!, answer: mAnswers![didSelectRowAt.row].id)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        let cell = tableView.cellForRow(at: didDeselectRowAt)
        cell?.accessoryType = .none
        Theme.setCellLayer(view: cell!, selected: false)
        mSelect![didDeselectRowAt.row] = false
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
    }
//    func tableView(_ tableView: UITableView,
//                   shouldHighlightRowAt indexPath: IndexPath) -> Bool {
 //       return false
 //   }
}
