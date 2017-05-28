//
//  GroupTable.swift
//  testsql
//
//  Created by Pete Bennett on 19/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import SQLite

final class GroupTable: TableHelper {
    public static var TABLE_NAME = "GrpTable"
    public static let C_ID = "gr_id"
    public static let C_STATUS = "gr_status"
    public static let C_STARTDATE = "gr_startdate"
    public static let C_DESC = "gr_desc"
    public static let C_MEMBERS = "gr_members"

    
    
    private static let table = Table(TABLE_NAME)
    
    public static let ID = Expression<String>(C_ID)
    public static let STATUS = Expression<String>(C_STATUS)
    public static let STARTDATE = Expression<Int>(C_STARTDATE)
    public static let DESC = Expression<String>(C_DESC)
    public static let MEMBERS = Expression<Int>(C_MEMBERS)
    
    public static let STATUS_BUILD = "b"
    public static let STATUS_WAIT = "w"
    public static let STATUS_ACTIVE = "a"
    public static let STATUS_OLD = "o"

    public var id, status, desc: String!
    public var startdate, members: Int!
    public var formatStatus: String {
        get  {
            if let stat = status {
                switch stat {
                case GroupTable.STATUS_BUILD: return "build"
                case GroupTable.STATUS_WAIT: return "waiting"
                case GroupTable.STATUS_ACTIVE: return "active"
                case GroupTable.STATUS_OLD: return "old"
                default: return "new"
                }
            } else {
                return "new"
            }
        }
    }
    
    
    
    init() {
    }
    init (row: Row) {
        getData(row: row)
    }
    private func getData(row: Row){
        self.id = row.get(type(of: self).ID)
        self.status = row.get(type(of: self).STATUS)
        self.startdate = row.get(type(of: self).STARTDATE)
        self.desc = row.get(type(of: self).DESC)
        self.members = row.get(type(of: self).MEMBERS)

    }
    public static func getKey(db: DBTables, id: String) -> GroupTable? {
        if let row = try! db.con().pluck( table.filter(ID == id)){
            return GroupTable(row: row)
        }
        
        return nil
    }
    public static func getAll(db: DBTables) -> [GroupTable] {
        var result = [GroupTable]()
        for row in try! db.con().prepare(table) {
            result.append(GroupTable(row: row))
        }
        
        return result
    }
    public func insert(db: DBTables) -> Bool{
        
        do{
            let _ = try db.con().run(type(of: self).table.insert(type(of: self).ID <- id,
                                                                 type(of: self).STATUS <- status,
                                                                 type(of: self).STARTDATE <- startdate,
                                                                 type(of: self).DESC <- desc,
                                                                 type(of: self).MEMBERS <- members))
        }
        catch { return false }
        return true
    }
    public func delete(db:DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).delete())
    }
    public func update (db: DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).update(type(of: self).STATUS <- status,
                                                                                              type(of: self).STARTDATE <- startdate,
                                                                                              type(of: self).DESC <- desc,
                                                                                              type(of: self).MEMBERS <- members))
    }
    public static func create(db: DBTables){
        let _ = try! db.con().run ( table.create{ t in
            t.column(ID, primaryKey: true)
            t.column(STATUS)
            t.column(STARTDATE)
            t.column(DESC)
            t.column(MEMBERS)

        })
    }
    public static func drop(db: DBTables){
        let _ = try! db.con().run ( table.drop())
    }
    //    public static func testit (db: DBTables,callback: (_: Expression<Any>,_: Expression<Any>) -> Void){
    //        let stmt = try! db.run(table.filter(callback(c_id,c_email)))
    //    }
    public static func get (db: DBTables, filter: Expression<Bool>) -> [GroupTable]{
        var result = [GroupTable]()
        for row in try! db.con().prepare(table.filter(filter)) {
            result.append(GroupTable(row: row))
        }
        return result
    }
    public static func get(db: DBTables, filter: Expression<Bool>, orderby: [Expressible]) -> [GroupTable]{
        if orderby.count == 0 {
            return GroupTable.get(db: db, filter: filter)
        }
        var sortOrder = orderby
        for _ in 0...3 {
            sortOrder.append(orderby[0])
        }
        var result = [GroupTable]()
        for row in try! db.con().prepare(table.filter(filter).order(sortOrder[0],sortOrder[1],sortOrder[2],sortOrder[3],sortOrder[4])) {
            result.append(GroupTable(row: row))
        }
        return result
    }
}

