//
//  File.swift
//  testsql
//
//  Created by Pete Bennett on 11/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import SQLite

final class AnswerTable: TableHelper {
    public static var TABLE_NAME = "AnswerTable"
    public static let C_ID = "an_id"
    public static let C_QUESTIONID = "an_questionid"
    public static let C_TEXT = "an_text"

    
    private static let table = Table(TABLE_NAME)
    
    public static let ID = Expression<String>(C_ID)
    public static let QUESTIONID = Expression<String>(C_QUESTIONID)
    public static let TEXT = Expression<String>(C_TEXT)
    public var id, questionid, text: String!

    
    
    init() {
    }
    init (row: Row) {
        getData(row: row)
    }
    private func getData(row: Row){
        self.id = row.get(type(of: self).ID)
        self.questionid = row.get(type(of: self).QUESTIONID)
        self.text = row.get(type(of: self).TEXT)
    }
    public static func getKey(db: DBTables, id: String) -> AnswerTable? {
        if let row = try! db.con().pluck( table.filter(ID == id)){
            return AnswerTable(row: row)
        }
        
        return nil
    }
    public static func getAll(db: DBTables) -> [AnswerTable] {
        var result = [AnswerTable]()
        for row in try! db.con().prepare(table) {
            result.append(AnswerTable(row: row))
        }
        
        return result
    }
    public func insert(db: DBTables) -> Bool{
        
        do{
            let _ = try db.con().run(type(of: self).table.insert(type(of: self).ID <- id,
                                                                 type(of: self).QUESTIONID <- questionid,
                                                                 type(of: self).TEXT <- text))
        }
        catch { return false }
        return true
    }
    public func delete(db:DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).delete())
    }
    public func update (db: DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).update(type(of: self).QUESTIONID <- questionid,
                                                                                              type(of: self).TEXT <- text))
    }
    public static func create(db: DBTables){
        let _ = try! db.con().run ( table.create{ t in
            t.column(ID, primaryKey: true)
            t.column(QUESTIONID)
            t.column(TEXT)

        })
    }
    public static func drop(db: DBTables){
        let _ = try! db.con().run ( table.drop())
    }
    //    public static func testit (db: DBTables,callback: (_: Expression<Any>,_: Expression<Any>) -> Void){
    //        let stmt = try! db.run(table.filter(callback(c_id,c_email)))
    //    }
    public static func get (db: DBTables, filter: Expression<Bool>) -> [AnswerTable]{
        var result = [AnswerTable]()
        for row in try! db.con().prepare(table.filter(filter)) {
            result.append(AnswerTable(row: row))
        }
        return result
    }
    public static func get(db: DBTables, filter: Expression<Bool>, orderby: [Expressible]) -> [AnswerTable]{
        if orderby.count == 0 {
            return AnswerTable.get(db: db, filter: filter)
        }
        var sortOrder = orderby
        for _ in 0...3 {
            sortOrder.append(orderby[0])
        }
        var result = [AnswerTable]()
        for row in try! db.con().prepare(table.filter(filter).order(sortOrder[0],sortOrder[1],sortOrder[2],sortOrder[3],sortOrder[4])) {
            result.append(AnswerTable(row: row))
        }
        return result
    }
}

