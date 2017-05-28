//
//  QuestionMultipleController.swift
//  testsql
//
//  Created by Pete Bennett on 11/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class QuestionMultiController: QuestionPageController, UITableViewDelegate, UITableViewDataSource{

    private var mAnswers: [AnswerTable]?

    override func viewDidLoad() {
        super.viewDidLoad()
        mAnswers = mParent!.getAnswers(index: pageNum!)
        QuestionLabel.text = mParent?.getText(index: pageNum!)
        if mParent!.checkForPreset(question: pageNum!, answer: nil) {
            noneSwitch.setOn(true, animated: false)
        }
        if mParent!.mDisplayMode {
            tabView.isUserInteractionEnabled = false
            noneSwitch.isUserInteractionEnabled = false
        }
        tabView.dataSource = self
        tabView.delegate = self
        tabView!.rowHeight = UITableViewAutomaticDimension
        tabView!.estimatedRowHeight = 50

    }
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)

    }
    // MARK: outlets and actions
    
    @IBOutlet weak var noneSwitch: UISwitch!
    @IBOutlet weak var tabView: UITableView!
    @IBAction func switchChanged(_ sender: UISwitch) {
        // this is the switch for "none of the above"
        tabView.isUserInteractionEnabled = !sender.isOn
        if sender.isOn {
            mParent!.setAnswer(questionNum: pageNum!, answer: "NONE")
        }
        else {
            setAnswers()
        }
    }
    @IBOutlet weak var QuestionLabel: UILabel!
    // MARK: table View stuff
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
        setAnswers()
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        let cell = tableView.cellForRow(at: didDeselectRowAt)
        cell?.accessoryType = .none
        Theme.setCellLayer(view: cell!, selected: false)
        mSelect![didDeselectRowAt.row] = false
        setAnswers()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
    }
 //   func tableView(_ tableView: UITableView,
 //                  shouldHighlightRowAt indexPath: IndexPath) -> Bool {
 //       return false
 //   }
    // MARK: other
    private func setAnswers() {
        var answers: [String]  = []
        for i in 0...(mAnswers!.count - 1) {
            if mSelect![i] {
                answers.append(mAnswers![i].id)
            }
        }
        mParent?.setAnswer(questionNum: pageNum!, answerSet: answers)
    }


}
