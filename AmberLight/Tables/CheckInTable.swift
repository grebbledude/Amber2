//
//  CheckInTable.swift
//  testsql
//
//  Created by Pete Bennett on 19/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import SQLite

final class CheckInTable: TableHelper {
    public static var TABLE_NAME = "CheckInTable"
    public static let C_ID = "ch_id"
    public static let C_STATUS = "ch_status"
    public static let C_DATE = "ch_date"
    public static let C_PSEUDONYM = "ch_pseudonym"
    public static let C_PERSONID = "ch_personId"
    public static let C_GROUP = "ch_group"
    public static let C_GROUP_NAME = "ch_groupName"
    
    
    private static let table = Table(TABLE_NAME)
    
    public static let ID = Expression<String>(C_ID)
    public static let STATUS = Expression<String>(C_STATUS)
    public static let DATE = Expression<Int>(C_DATE)
    public static let PSEUDONYM = Expression<String>(C_PSEUDONYM)
    public static let PERSONID = Expression<String>(C_PERSONID)
    public static let GROUP = Expression<String>(C_GROUP)
    public static let GROUP_NAME = Expression<String>(C_GROUP_NAME)
    public var id, status, pseudonym, personId, group, groupName: String!
    public var date: Int!
    
    
    
    init() {
    }
    init (row: Row) {
        getData(row: row)
    }
    private func getData(row: Row){
        self.id = row.get(type(of: self).ID)
        self.status = row.get(type(of: self).STATUS)
        self.date = row.get(type(of: self).DATE)
        self.pseudonym = row.get(type(of: self).PSEUDONYM)
        self.personId = row.get(type(of: self).PERSONID)
        self.group = row.get(type(of: self).GROUP)
        self.groupName = row.get(type(of: self).GROUP_NAME)
    }
    public static func getKey(db: DBTables, id: String) -> CheckInTable? {
        if let row = try! db.con().pluck( table.filter(ID == id)){
            return CheckInTable(row: row)
        }
        
        return nil
    }
    public static func getAll(db: DBTables) -> [CheckInTable] {
        var result = [CheckInTable]()
        for row in try! db.con().prepare(table) {
            result.append(CheckInTable(row: row))
        }
        
        return result
    }
    public func insert(db: DBTables) -> Bool{
        
        do{
            let _ = try db.con().run(type(of: self).table.insert(type(of: self).ID <- id,
                                                                 type(of: self).STATUS <- status,
                                                                 type(of: self).DATE <- date,
                                                                 type(of: self).PSEUDONYM <- pseudonym,
                                                                 type(of: self).PERSONID <- personId,
                                                                 type(of: self).GROUP <- group,
                                                                 type(of: self).GROUP_NAME <- groupName))
        }
        catch { return false }
        return true
    }
    public func delete(db:DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).delete())
    }
    public func update (db: DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).update(type(of: self).STATUS <- status,
                                                                                    type(of: self).DATE <- date,
                                                                                    type(of: self).PSEUDONYM <- pseudonym,
                                                                                    type(of: self).PERSONID <- personId,
                                                                                    type(of: self).GROUP <- group,
                                                                                    type(of: self).GROUP_NAME <- groupName))
    }
    public static func create(db: DBTables){
        let _ = try! db.con().run ( table.create{ t in
            t.column(ID, primaryKey: true)
            t.column(STATUS)
            t.column(DATE)
            t.column(PSEUDONYM)
            t.column(PERSONID)
            t.column(GROUP)
            t.column(GROUP_NAME)
            
        })
    }
    public static func drop(db: DBTables){
        let _ = try! db.con().run ( table.drop())
    }
    //    public static func testit (db: DBTables,callback: (_: Expression<Any>,_: Expression<Any>) -> Void){
    //        let stmt = try! db.run(table.filter(callback(c_id,c_email)))
    //    }
    public static func get (db: DBTables, filter: Expression<Bool>) -> [CheckInTable]{
        var result = [CheckInTable]()
        for row in try! db.con().prepare(table.filter(filter)) {
            result.append(CheckInTable(row: row))
        }
        return result
    }
    public static func get(db: DBTables, filter: Expression<Bool>, orderby: [Expressible]) -> [CheckInTable]{
        if orderby.count == 0 {
            return CheckInTable.get(db: db, filter: filter)
        }
        var sortOrder = orderby
        for _ in 0...3 {
            sortOrder.append(orderby[0])
        }
        var result = [CheckInTable]()
        for row in try! db.con().prepare(table.filter(filter).order(sortOrder[0],sortOrder[1],sortOrder[2],sortOrder[3],sortOrder[4])) {
            result.append(CheckInTable(row: row))
        }
        return result
    }
}

