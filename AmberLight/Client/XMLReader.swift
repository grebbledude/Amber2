//
//  XMLReader.swift
//  testsql
//
//  Created by Pete Bennett on 15/01/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import Foundation
class XMLReader: NSObject, XMLParserDelegate {
    
    private var mAnswers: [AnswerTable]
    private var mFoundCharacters = "";
    private var mCurrentQuestion: QuestionTable?
    private var mCurrentAnswer: AnswerTable?
    private var mDBT: DBTables
    
    static let QUESTION_TAG = "question"
    static let ANSWER_TAG = "answer"
    static let ID_TAG = "id"
    static let AMBER_TAG = "amber"
    static let RED_TAG = "red"
    static let INIT_TAG = "init"
    static let MULTI_TAG = "multi"
    static let TEXT_TAG = "text"
    
    
    init (fileName: String, db: DBTables) {
        mAnswers = []
        mDBT = db
        super.init()
        let resourceFile = Bundle.main.path(forResource: fileName, ofType: "xml")
        let inputStream = InputStream(fileAtPath: resourceFile!)
  //      let xmlData = xmlString.dataUsingEncoding(NSUTF8StringEncoding)!
        let parser = XMLParser(stream: inputStream!)
        
        parser.delegate = self;
        
        parser.parse()

    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case XMLReader.QUESTION_TAG:
            mCurrentQuestion = QuestionTable()
            mCurrentQuestion!.id = "Q" + attributeDict[XMLReader.ID_TAG]!
            mCurrentQuestion!.text = attributeDict[XMLReader.TEXT_TAG] ?? ""
            if let amber = attributeDict[XMLReader.AMBER_TAG] {
                mCurrentQuestion!.amberAlert = (amber == "y")
            }
            else {
                mCurrentQuestion!.amberAlert = false
            }
            if let red = attributeDict[XMLReader.RED_TAG] {
                mCurrentQuestion!.redAlert = (red == "y")
            }
            else {
                mCurrentQuestion!.redAlert = false
            }
            if let initQ = attributeDict[XMLReader.INIT_TAG] {
                mCurrentQuestion!.initQuestion = (initQ == "y")
            }
            else {
                mCurrentQuestion!.initQuestion = false
            }
            if let multi = attributeDict[XMLReader.MULTI_TAG] {
                mCurrentQuestion!.multi = (multi == "y")
            }
            else {
                mCurrentQuestion!.multi = false
            }
            mAnswers = []
        case XMLReader.ANSWER_TAG:
            mCurrentAnswer = AnswerTable()
            mCurrentAnswer!.text = attributeDict[XMLReader.TEXT_TAG]!
            mCurrentAnswer?.questionid = mCurrentQuestion!.id!
            mCurrentAnswer!.id = mCurrentAnswer!.questionid + "A" + attributeDict[XMLReader.ID_TAG]!
            mAnswers.append(mCurrentAnswer!)
        default:
            break
        }

    }
/*    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.mFoundCharacters += string;
    } */

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        if elementName == XMLReader.QUESTION_TAG {
            if !(mCurrentQuestion?.insert(db: mDBT))! {
                let oldQuestion = QuestionTable.getKey(db: mDBT, id: mCurrentQuestion!.id)
                oldQuestion?.amberAlert = mCurrentQuestion!.amberAlert!
                oldQuestion!.redAlert = mCurrentQuestion!.redAlert!
                oldQuestion?.initQuestion = mCurrentQuestion?.initQuestion!
                oldQuestion!.update(db: mDBT)
                // handle replace
            }
            for answer in mAnswers {
                if !(answer.insert(db: mDBT)) {
                    // handle replace here as well
                }
            }
        }
//        self.mFoundCharacters = ""
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        print ("finished")
 /*       for item in self.items {
            print("\(item.author)\n\(item.desc)");
            for tags in item.tag {
                if let count = tags.count {
                    print("\(tags.name), \(count)")
                } else {
                    print("\(tags.name)")
                }
            }
            print("\n")
        } */
    }
}
