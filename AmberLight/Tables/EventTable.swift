//
//  EventTable.swift
//  testsql
//
//  Created by Pete Bennett on 24/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import SQLite

final class EventTable: TableHelper {
    public static var TABLE_NAME = "EventTable"
    public static let C_ID = "ev_id"
    public static let C_TEXT = "ev_text"
    public static let C_TIMESTAMP = "ev_timeStamp"
    public static let C_TYPE = "ev_type"
    
    public static let TYPE_PANIC = "panic"
    public static let TYPE_NEW_PERSON = "person"

    
    public static let table = Table(TABLE_NAME)
    
    public static let ID = Expression<String>(C_ID)
    public static let TEXT = Expression<String>(C_TEXT)
    public static let TIMESTAMP = Expression<Double>(C_TIMESTAMP)

    public static let TYPE = Expression<String>(C_TYPE)

    public var id, text,  type : String!
    public var timeStamp: Double!
    
    
    init() {
    }
    init (row: Row) {
        getData(row: row)
    }
    private func getData(row: Row){
        self.id = row.get(type(of: self).ID)
        self.text = row.get(type(of: self).TEXT)
        self.timeStamp = row.get(type(of: self).TIMESTAMP)

        self.type = row.get(type(of: self).TYPE)

    }
    public static func getKey(db: DBTables, id: String) -> EventTable? {
        if let row = try! db.con().pluck( table.filter(ID == id)){
            return EventTable(row: row)
        }
        
        return nil
    }
    public static func getAll(db: DBTables) -> [EventTable] {
        var result = [EventTable]()
        for row in try! db.con().prepare(table) {
            result.append(EventTable(row: row))
        }
        
        return result
    }
    public func insert(db: DBTables) -> Bool{
        
        do{
            let _ = try db.con().run(type(of: self).table.insert(type(of: self).ID <- id,
                                                                 type(of: self).TEXT <- text,
                                                                 type(of: self).TIMESTAMP <- timeStamp,
                                                                 type(of: self).TYPE <- type))
        }
        catch { return false }
        return true
    }
    public func delete(db:DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).delete())
    }
    public func update (db: DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).update(type(of: self).TEXT <- text,
                                                                                              type(of: self).TIMESTAMP <- timeStamp,
                                                                                              type(of: self).TYPE <- type))
    }
    public static func create(db: DBTables){
        let _ = try! db.con().run ( table.create{ t in
            t.column(ID, primaryKey: true)
            t.column(TEXT)
            t.column(TIMESTAMP)
            t.column(TYPE)
        })
    }
    public static func drop(db: DBTables){
        let _ = try! db.con().run ( table.drop())
    }
    //    public static func testit (db: DBTables,callback: (_: Expression<Any>,_: Expression<Any>) -> Void){
    //        let stmt = try! db.run(table.filter(callback(c_id,c_email)))
    //    }
    public static func get (db: DBTables, filter: Expression<Bool>) -> [EventTable]{
        var result = [EventTable]()
        for row in try! db.con().prepare(table.filter(filter)) {
            result.append(EventTable(row: row))
        }
        return result
    }
    public static func get(db: DBTables, filter: Expression<Bool>, orderby: [Expressible]) -> [EventTable]{
        if orderby.count == 0 {
            return EventTable.get(db: db, filter: filter)
        }
        var sortOrder = orderby
        for _ in 0...3 {
            sortOrder.append(orderby[0])
        }
        var result = [EventTable]()
        for row in try! db.con().prepare(table.filter(filter).order(sortOrder[0],sortOrder[1],sortOrder[2],sortOrder[3],sortOrder[4])) {
            result.append(EventTable(row: row))
        }
        return result
    }
}
