//
//  TeamLeadTable.swift
//  testsql
//
//  Created by Pete Bennett on 09/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//


import SQLite

final class TeamLeadTable: TableHelper {
    public static var TABLE_NAME = "TeamLeadTable"
    public static let C_ID = "tl_id"
    public static let C_NAME = "tl_name"
    public static let C_CODE = "tl_code"

    
    public static let table = Table(TABLE_NAME)
    
    public static let ID = Expression<String>(C_ID)
    public static let NAME = Expression<String>(C_NAME)
    public static let CODE = Expression<String>(C_CODE)

    public var id, name, code: String!

    
    
    init() {
    }
    init (row: Row) {
        getData(row: row)
    }
    private func getData(row: Row){
        self.id = row.get(type(of: self).ID)
        self.name = row.get(type(of: self).NAME)
        self.code = row.get(type(of: self).CODE)
    }
    public static func getKey(db: DBTables, id: String) -> TeamLeadTable? {
        if let row = try! db.con().pluck( table.filter(ID == id)){
            return TeamLeadTable(row: row)
        }
        
        return nil
    }
    public static func getAll(db: DBTables) -> [TeamLeadTable] {
        var result = [TeamLeadTable]()
        for row in try! db.con().prepare(table) {
            result.append(TeamLeadTable(row: row))
        }
        
        return result
    }
    public func insert(db: DBTables) -> Bool{
        
        do{
            let _ = try db.con().run(type(of: self).table.insert(type(of: self).ID <- id,
                                                                 type(of: self).NAME <- name,
                                                                 type(of: self).CODE <- code))
        }
        catch { return false }
        return true
    }
    public func delete(db:DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).delete())
    }
    public func update (db: DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).update(type(of: self).NAME <- name,
                                                                                              type(of: self).CODE <- code))
    }
    public static func create(db: DBTables){
        let _ = try! db.con().run ( table.create{ t in
            t.column(ID, primaryKey: true)
            t.column(NAME)
            t.column(CODE)

        })
    }
    public static func drop(db: DBTables){
        let _ = try! db.con().run ( table.drop())
    }
    //    public static func testit (db: DBTables,callback: (_: Expression<Any>,_: Expression<Any>) -> Void){
    //        let stmt = try! db.run(table.filter(callback(c_id,c_email)))
    //    }
    public static func get (db: DBTables, filter: Expression<Bool>) -> [TeamLeadTable]{
        var result = [TeamLeadTable]()
        for row in try! db.con().prepare(table.filter(filter)) {
            result.append(TeamLeadTable(row: row))
        }
        return result
    }
    public static func get(db: DBTables, filter: Expression<Bool>, orderby: [Expressible]) -> [TeamLeadTable]{
        if orderby.count == 0 {
            return TeamLeadTable.get(db: db, filter: filter)
        }
        var sortOrder = orderby
        for _ in 0...3 {
            sortOrder.append(orderby[0])
        }
        var result = [TeamLeadTable]()
        for row in try! db.con().prepare(table.filter(filter).order(sortOrder[0],sortOrder[1],sortOrder[2],sortOrder[3],sortOrder[4])) {
            result.append(TeamLeadTable(row: row))
        }
        return result
    }
}
