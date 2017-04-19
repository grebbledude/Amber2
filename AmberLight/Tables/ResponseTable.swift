//
//  ResponseTable.swift
//  testsql
//
//  Created by Pete Bennett on 09/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//


import SQLite

final class ResponseTable: TableHelper {
    public static var TABLE_NAME = "ResponseTable"
    public static let C_ID = "re_id"
    public static let C_PERSONID = "re_personid"
    public static let C_DAYNO = "re_dayno"
    public static let C_RESPONSE_DATE = "re_responseDate"
    public static let C_ANSWER = "re_answer"
    public static let C_QUESTION = "re_question"
    
    public static let table = Table(TABLE_NAME)
    
    public static let ID = Expression<String>(C_ID)
    public static let PERSONID = Expression<String>(C_PERSONID)
    public static let DAYNO = Expression<Int>(C_DAYNO)
    public static let RESPONSE_DATE = Expression<Int>(C_RESPONSE_DATE)
    public static let ANSWER = Expression<String>(C_ANSWER)
    public static let QUESTION = Expression<String>(C_QUESTION)
    public var id, personid,  answer, question: String!
    public var dayno, responseDate: Int!
    
    
    init() {
    }
    init (row: Row) {
        getData(row: row)
    }
    private func getData(row: Row){
        self.id = row.get(type(of: self).ID)
        self.personid = row.get(type(of: self).PERSONID)
        self.dayno = row.get(type(of: self).DAYNO)
        self.responseDate = row.get(type(of: self).RESPONSE_DATE)
        self.answer = row.get(type(of: self).ANSWER)
        self.question = row.get(type(of: self).QUESTION)
    }
    public static func getKey(db: DBTables, id: String) -> ResponseTable? {
        if let row = try! db.con().pluck( table.filter(ID == id)){
            return ResponseTable(row: row)
        }
        
        return nil
    }
    public static func getAll(db: DBTables) -> [ResponseTable] {
        var result = [ResponseTable]()
        for row in try! db.con().prepare(table) {
            result.append(ResponseTable(row: row))
        }
        
        return result
    }
    public func insert(db: DBTables) -> Bool{
        
        do{
            let _ = try db.con().run(type(of: self).table.insert(type(of: self).ID <- id,
                                                                 type(of: self).PERSONID <- personid,
                                                                 type(of: self).DAYNO <- dayno,
                                                                 type(of: self).RESPONSE_DATE <- responseDate,
                                                                 type(of: self).ANSWER <- answer,
                                                                 type(of: self).QUESTION <- question))
        }
        catch { return false }
        return true
    }
    public func delete(db:DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).delete())
    }
    public func update (db: DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).update(type(of: self).PERSONID <- personid,
                                                                                              type(of: self).DAYNO <- dayno,
                                                                                              type(of: self).RESPONSE_DATE <- responseDate,
                                                                                              type(of: self).ANSWER <- answer,
                                                                                              type(of: self).QUESTION <- question))
    }
    public static func create(db: DBTables){
        let _ = try! db.con().run ( table.create{ t in
            t.column(ID, primaryKey: true)
            t.column(PERSONID)
            t.column(DAYNO)
            t.column(RESPONSE_DATE)
            t.column(ANSWER)
            t.column(QUESTION)
        })
    }
    public static func drop(db: DBTables){
        let _ = try! db.con().run ( table.drop())
    }
    //    public static func testit (db: DBTables,callback: (_: Expression<Any>,_: Expression<Any>) -> Void){
    //        let stmt = try! db.run(table.filter(callback(c_id,c_email)))
    //    }
    public static func get (db: DBTables, filter: Expression<Bool>) -> [ResponseTable]{
        var result = [ResponseTable]()
        for row in try! db.con().prepare(table.filter(filter)) {
            result.append(ResponseTable(row: row))
        }
        return result
    }
    public static func get(db: DBTables, filter: Expression<Bool>, orderby: [Expressible]) -> [ResponseTable]{
        if orderby.count == 0 {
            return ResponseTable.get(db: db, filter: filter)
        }
        var sortOrder = orderby
        for _ in 0...3 {
            sortOrder.append(orderby[0])
        }
        var result = [ResponseTable]()
        for row in try! db.con().prepare(table.filter(filter).order(sortOrder[0],sortOrder[1],sortOrder[2],sortOrder[3],sortOrder[4])) {
            result.append(ResponseTable(row: row))
        }
        return result
    }
}
