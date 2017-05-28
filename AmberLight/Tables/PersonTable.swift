//
//  PersonTable.swift
//  testsql
//
//  Created by Pete Bennett on 19/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//


import SQLite

final class PersonTable: TableHelper {
    public static var TABLE_NAME = "PersonTable"
    public static let C_ID = "pe_id"
    public static let C_STATUS = "pe_status"
    public static let C_NAME = "pe_name"
    public static let C_PSEUDONYM = "pe_pseudonym"
    public static let C_REG_CODE = "pe_regCode"
    public static let C_GROUP = "pe_group"
    public static let C_LAST_STATUS = "pe_lastStatus"
    
    
    private static let table = Table(TABLE_NAME)
    
    public static let ID = Expression<String>(C_ID)
    public static let STATUS = Expression<String>(C_STATUS)
    public static let NAME = Expression<String>(C_NAME)
    public static let PSEUDONYM = Expression<String>(C_PSEUDONYM)
    public static let REG_CODE = Expression<String>(C_REG_CODE)
    public static let GROUP = Expression<String>(C_GROUP)
    public static let LAST_STATUS = Expression<String>(C_LAST_STATUS)
    public var id, status, pseudonym, name, regCode, group, lastStatus: String!

    public var formatStatus: String {
        get  {
            if let stat = status {
                switch stat {
                case PersonTable.STATUS_WAIT_REGCODE: return "waiting"
                case PersonTable.STATUS_WAIT_GROUP: return "unassigned"
                case PersonTable.STATUS_GROUP_NOT_CONFIRMED: return "unconfirmed"
                case PersonTable.STATUS_WAIT_CONTACT: return "registered"
                case PersonTable.STATUS_ACTIVE: return "active"
                default: return "new"
                }
            } else {
                return "new"
            }
        }
    }
    
    public static let STATUS_WAIT_REGCODE = "R"
    public static let STATUS_WAIT_GROUP = "G"
    public static let STATUS_GROUP_NOT_CONFIRMED = "W"
    public static let STATUS_WAIT_CONTACT = "C"
    public static let STATUS_ACTIVE = "A"

    public static var x: Expression<Bool>?
    
   
    
    init() {
        PersonTable.x = PersonTable.STATUS == PersonTable.STATUS_WAIT_GROUP
        
    }
    init (row: Row) {
        getData(row: row)
    }
    private func getData(row: Row){
        self.id = row.get(type(of: self).ID)
        self.status = row.get(type(of: self).STATUS)
        self.name = row.get(type(of: self).NAME)
        self.pseudonym = row.get(type(of: self).PSEUDONYM)
        self.regCode = row.get(type(of: self).REG_CODE)
        self.group = row.get(type(of: self).GROUP)
        self.lastStatus = row.get(type(of: self).LAST_STATUS)
    }
    public static func getKey(db: DBTables, id: String) -> PersonTable? {
        if let row = try! db.con().pluck( table.filter(ID == id)){
            return PersonTable(row: row)
        }
        
        return nil
    }
    public static func getAll(db: DBTables) -> [PersonTable] {
        var result = [PersonTable]()
        for row in try! db.con().prepare(table) {
            result.append(PersonTable(row: row))
        }
        
        return result
    }
    public func insert(db: DBTables) -> Bool{
        
        do{
            let _ = try db.con().run(type(of: self).table.insert(type(of: self).ID <- id,
                                                                 type(of: self).STATUS <- status,
                                                                 type(of: self).NAME <- name,
                                                                 type(of: self).PSEUDONYM <- pseudonym,
                                                                 type(of: self).REG_CODE <- regCode,
                                                                 type(of: self).GROUP <- group,
                                                                 type(of: self).LAST_STATUS <- lastStatus))
        }
        catch { return false }
        return true
    }
    public func delete(db:DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).delete())
    }
    public func update (db: DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).update(  type(of: self).STATUS <- status,
                                                                                              type(of: self).NAME <- name,
                                                                                              type(of: self).PSEUDONYM <- pseudonym,
                                                                                              type(of: self).REG_CODE <- regCode,
                                                                                              type(of: self).GROUP <- group,
                                                                                              type(of: self).LAST_STATUS <- lastStatus))
    }
    public static func create(db: DBTables){
        let _ = try! db.con().run ( table.create{ t in
            t.column(ID, primaryKey: true)
            t.column(STATUS)
            t.column(NAME)
            t.column(PSEUDONYM)
            t.column(REG_CODE)
            t.column(GROUP)
            t.column(LAST_STATUS)
            
        })
    }
    public static func drop(db: DBTables){
        let _ = try! db.con().run ( table.drop())
    }
    //    public static func testit (db: DBTables,callback: (_: Expression<Any>,_: Expression<Any>) -> Void){
    //        let stmt = try! db.run(table.filter(callback(c_id,c_email)))
    //    }
    public static func get (db: DBTables, filter: Expression<Bool>) -> [PersonTable]{
        var result = [PersonTable]()
        for row in try! db.con().prepare(table.filter(filter)) {
            result.append(PersonTable(row: row))
        }
        return result
    }
    public static func get(db: DBTables, filter: Expression<Bool>, orderby: [Expressible]) -> [PersonTable]{
        if orderby.count == 0 {
            return PersonTable.get(db: db, filter: filter)
        }
        var sortOrder = orderby
        for _ in 0...3 {
            sortOrder.append(orderby[0])
        }
        var result = [PersonTable]()
        for row in try! db.con().prepare(table.filter(filter).order(sortOrder[0],sortOrder[1],sortOrder[2],sortOrder[3],sortOrder[4])) {
            result.append(PersonTable(row: row))
        }
        return result
    }
    public static func updateStatus (group: String, toStatus: String, db: DBTables) {
        let _ = try! db.con().run(PersonTable.table.filter(PersonTable.GROUP == group).update(  PersonTable.STATUS <-                toStatus))
    }
}

