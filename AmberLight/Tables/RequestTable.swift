//
//  RequestTable.swift
//  AmberLight
//
//  Created by Pete Bennett on 18/03/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//
import Foundation
import SQLite

final class RequestTable: TableHelper {
    public static var TABLE_NAME = "RequestTable"
    public static let C_ID = "rq_id"
    public static let C_TEXT = "rq_text"
    public static let C_TIMESTAMP = "rq_timeStamp"
    public static let C_PERSON_ID = "rq_personid"
    public static let C_PSEUDONYM = "rq_pseudonym"
    public static let C_REPLIED = "rq_replied"
    
    public static let TYPE_PANIC = "panic"
    public static let TYPE_NEW_PERSON = "person"
    
    
    public static let table = Table(TABLE_NAME)
    
    public static let ID = Expression<String>(C_ID)
    public static let TEXT = Expression<String>(C_TEXT)
    public static let TIMESTAMP = Expression<Double>(C_TIMESTAMP)
    public static let PERSON_ID = Expression<String>(C_PERSON_ID)
    public static let PSEUDONYM = Expression<String>(C_PSEUDONYM)
    public static let REPLIED = Expression<Bool>(C_REPLIED)
    
    public var id, text,  personId, pseudonym : String!
    public var timeStamp: Double!
    public var replied: Bool!
    
    
    init() {
    }
    init (row: Row) {
        getData(row: row)
    }
    private func getData(row: Row){
        self.id = row.get(type(of: self).ID)
        self.text = row.get(type(of: self).TEXT)
        self.timeStamp = row.get(type(of: self).TIMESTAMP)
        
        self.personId = row.get(type(of: self).PERSON_ID)
        self.pseudonym = row.get(type(of: self).PSEUDONYM)
        self.replied = row.get(type(of: self).REPLIED)
        
    }
    public static func getKey(db: DBTables, id: String) -> RequestTable? {
        if let row = try! db.con().pluck( table.filter(ID == id)){
            return RequestTable(row: row)
        }
        
        return nil
    }
    public static func getAll(db: DBTables) -> [RequestTable] {
        var result = [RequestTable]()
        for row in try! db.con().prepare(table) {
            result.append(RequestTable(row: row))
        }
        
        return result
    }
    public func insert(db: DBTables) -> Bool{
        
        do{
            let _ = try db.con().run(type(of: self).table.insert(type(of: self).ID <- id,
                                                                 type(of: self).TEXT <- text,
                                                                 type(of: self).TIMESTAMP <- timeStamp,
                                                                 type(of: self).PERSON_ID <- personId,
                                                                 type(of: self).PSEUDONYM <- pseudonym,
                                                                 type(of: self).REPLIED <- replied))
        }
        catch { return false }
        return true
    }
    public func delete(db:DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).delete())
    }
    public func update (db: DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id)
            .update(type(of: self).TEXT <- text,
                    type(of: self).TIMESTAMP <- timeStamp,
                    type(of: self).PERSON_ID <- personId,
                    type(of: self).PSEUDONYM <- pseudonym,
                    type(of: self).REPLIED <- replied))
    }
    public static func create(db: DBTables){
        let _ = try! db.con().run ( table.create{ t in
            t.column(ID, primaryKey: true)
            t.column(TEXT)
            t.column(TIMESTAMP)
            t.column(PERSON_ID)
            t.column(PSEUDONYM)
            t.column(REPLIED)
        })
    }
    public static func drop(db: DBTables){
        let _ = try! db.con().run ( table.drop())
    }
    //    public static func testit (db: DBTables,callback: (_: Expression<Any>,_: Expression<Any>) -> Void){
    //        let stmt = try! db.run(table.filter(callback(c_id,c_email)))
    //    }
    public static func get (db: DBTables, filter: Expression<Bool>) -> [RequestTable]{
        var result = [RequestTable]()
        for row in try! db.con().prepare(table.filter(filter)) {
            result.append(RequestTable(row: row))
        }
        return result
    }
    public static func get(db: DBTables, filter: Expression<Bool>, orderby: [Expressible]) -> [RequestTable]{
        if orderby.count == 0 {
            return RequestTable.get(db: db, filter: filter)
        }
        var sortOrder = orderby
        for _ in 0...3 {
            sortOrder.append(orderby[0])
        }
        var result = [RequestTable]()
        for row in try! db.con().prepare(table.filter(filter).order(sortOrder[0],sortOrder[1],sortOrder[2],sortOrder[3],sortOrder[4])) {
            result.append(RequestTable(row: row))
        }
        return result
    }
}

