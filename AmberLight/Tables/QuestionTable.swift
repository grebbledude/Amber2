//
//  QuestionTable.swift
//  testsql
//
//  Created by Pete Bennett on 07/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import Foundation
import SQLite

final class QuestionTable: TableHelper {
    public static var TABLE_NAME = "QuestionTable"
    public static let C_ID = "qu_id"
    public static let C_REDALERT = "qu_redAlert"
    public static let C_AMBERALERT = "qu_amberAlert"
    public static let C_INITQUESTION = "qu_initQuestion"
    public static let C_TEXT = "qu_text"
    public static let C_MULTI = "qu_multi"
    
    public static let table = Table(TABLE_NAME)
    
    public static let ID = Expression<String>(C_ID)
    public static let REDALERT = Expression<Bool>(C_REDALERT)
    public static let AMBERALERT = Expression<Bool>(C_AMBERALERT)
    public static let INITQUESTION = Expression<Bool>(C_INITQUESTION)
    public static let TEXT = Expression<String>(C_TEXT)
    public static let MULTI = Expression<Bool>(C_MULTI)
    public var id, text: String!
    public var amberAlert, redAlert, initQuestion, multi: Bool!

    
    init() {
    }
    init (row: Row) {
        getData(row: row)
    }
    private func getData(row: Row){
        self.id = row.get(type(of: self).ID)
        self.redAlert = row.get(type(of: self).REDALERT)
        self.amberAlert = row.get(type(of: self).AMBERALERT)
        self.initQuestion = row.get(type(of: self).INITQUESTION)
        self.text = row.get(type(of: self).TEXT)
        self.multi = row.get(type(of: self).MULTI)
    }
    public static func getKey(db: DBTables, id: String) -> QuestionTable? {
        if let row = try! db.con().pluck( table.filter(ID == id)){
            return QuestionTable(row: row)
        }
        
        return nil
    }
    public static func getAll(db: DBTables) -> [QuestionTable] {
        var result = [QuestionTable]()
        for row in try! db.con().prepare(table) {
            result.append(QuestionTable(row: row))
        }
        
        return result
    }
    public func insert(db: DBTables) -> Bool{
        
        do{
            let _ = try db.con().run(type(of: self).table.insert(type(of: self).ID <- id,
                                                           type(of: self).REDALERT <- redAlert,
                                                           type(of: self).AMBERALERT <- amberAlert,
                                                           type(of: self).INITQUESTION <- initQuestion,
                                                           type(of: self).TEXT <- text,
                                                           type(of: self).MULTI <- multi))
        }
        catch { return false }
        return true
    }
    public func delete(db:DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).delete())
    }
    public func update (db: DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).update(type(of: self).REDALERT <- redAlert,
                                                                                        type(of: self).AMBERALERT <- amberAlert,
                                                                                        type(of: self).INITQUESTION <- initQuestion,
                                                                                        type(of: self).TEXT <- text,
                                                                                        type(of: self).MULTI <- multi))
    }
    public static func create(db: DBTables){
        let _ = try! db.con().run ( table.create{ t in
            t.column(ID, primaryKey: true)
            t.column(REDALERT)
            t.column(AMBERALERT)
            t.column(INITQUESTION)
            t.column(TEXT)
            t.column(MULTI)
        })
    }
    public static func drop(db: DBTables){
        let _ = try! db.con().run ( table.drop())
    }
    //    public static func testit (db: DBTables,callback: (_: Expression<Any>,_: Expression<Any>) -> Void){
    //        let stmt = try! db.run(table.filter(callback(c_id,c_email)))
    //    }
    public static func get (db: DBTables, filter: Expression<Bool>) -> [QuestionTable]{
        var result = [QuestionTable]()
        for row in try! db.con().prepare(table.filter(filter)) {
            result.append(QuestionTable(row: row))
        }
        return result
    }
    public static func get(db: DBTables, filter: Expression<Bool>, orderby: [Expressible]) -> [QuestionTable]{
        if orderby.count == 0 {
            return QuestionTable.get(db: db, filter: filter)
        }
        var sortOrder = orderby
        for _ in 0...3 {
            sortOrder.append(orderby[0])
        }
        var result = [QuestionTable]()
        for row in try! db.con().prepare(table.filter(filter).order(sortOrder[0],sortOrder[1],sortOrder[2],sortOrder[3],sortOrder[4])) {
            result.append(QuestionTable(row: row))
        }
        return result
    }
    public static func getWithResponseDate (db: DBTables, personid: String, dayNo: Int) -> [QuestionTable]{
        let query = table
            .select(distinct: table[*])
            .join(ResponseTable.table, on: QuestionTable.ID == ResponseTable.QUESTION)
            .filter (ResponseTable.DAYNO == dayNo && ResponseTable.PERSONID == personid)
        var result = [QuestionTable]()
        for row in try! db.con().prepare(query) {
            result.append(QuestionTable(row: row))
        }
        return result
    }
}
