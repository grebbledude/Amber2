//
//  ReadQuestions.swift
//  testsql
//
//  Created by Pete Bennett on 05/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import Foundation
class ReadQuestions:  NSObject,XMLParserDelegate {
    
//    private var parser = XMLParser()
//    private var posts = NSMutableArray()
//    private var elements = NSMutableDictionary()
//    private var element = NSString()
//    private var title1 = NSMutableString()
//    private var date = NSMutableString()
    
    

    
    var qNo: String = ""
    var aNo: String = ""
    var qTitle: String = ""
    var aText: String = ""

    init(url: String){
        super.init()
        let parser = XMLParser(contentsOf: URL(string   : url)!)!
        parser.delegate = self
        parser.parse()
    }
    init(file: String){
        super.init()
        let parser = XMLParser(stream: InputStream(fileAtPath: file)!)
        parser.delegate = self
        parser.parse()
    }
    func parserDidStartDocument(_ parser: XMLParser) {
        print ("started")
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print(" parse start \(elementName)")
        switch elementName {
        case "question":
            if let number = attributeDict["number"]{
                qNo = number
            }
            qTitle = attributeDict["title"]!
        case "answer":
            aNo = attributeDict["number"]!
            aText = attributeDict["text"]!
        default: break
        }

    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(" parse found \(string)")
//        itemName?.append(string)
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print(" parse end \(elementName)")
        print(" parse end \(qName!)")
        print(" parse end \(namespaceURI!)")
        print ("Question \(qNo) Answer \(aNo) text \(aText) element \(elementName)")
    }
    func parser(_: XMLParser, parseErrorOccurred: Error) {
        print ("Error found" + parseErrorOccurred.localizedDescription)
    }
}
