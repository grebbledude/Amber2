//
//  MessageTable.swift
//  AmberLight
//
//  Created by Pete Bennett on 07/04/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//


import SQLite

final class MessageTable: TableHelper {
    public static var TABLE_NAME = "MessageTable"
    public static let C_ID = "me_id"
    public static let C_ACTION = "me_action"
    public static let C_DATA = "me_data"
    
    
    private static let table = Table(TABLE_NAME)
    
    public static let ID = Expression<String>(C_ID)
    public static let ACTION = Expression<String>(C_ACTION)
    public static let DATA = Expression<String>(C_DATA)
    public var id, action, data: String!
    
    
    
    init() {
    }
    init (row: Row) {
        getData(row: row)
    }
    private func getData(row: Row){
        self.id = row.get(type(of: self).ID)
        self.action = row.get(type(of: self).ACTION)
        self.data = row.get(type(of: self).DATA)
    }
    public static func getKey(db: DBTables, id: String) -> MessageTable? {
        if let row = try! db.con().pluck( table.filter(ID == id)){
            return MessageTable(row: row)
        }
        
        return nil
    }
    public static func getAll(db: DBTables) -> [MessageTable] {
        var result = [MessageTable]()
        for row in try! db.con().prepare(table) {
            result.append(MessageTable(row: row))
        }
        
        return result
    }
    public func insert(db: DBTables) -> Bool{
        
        do{
            let _ = try db.con().run(type(of: self).table.insert(type(of: self).ID <- id,
                                                                 type(of: self).ACTION <- action,
                                                                 type(of: self).DATA <- data))
        }
        catch { return false }
        return true
    }
    public func delete(db:DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).delete())
    }
    public func update (db: DBTables){
        let _ = try! db.con().run(type(of: self).table.filter(type(of: self).ID == id).update(type(of: self).ACTION <- action,
                                                                                              type(of: self).DATA <- data))
    }
    public static func create(db: DBTables){
        let _ = try! db.con().run ( table.create{ t in
            t.column(ID, primaryKey: true)
            t.column(ACTION)
            t.column(DATA)
            
        })
    }
    public static func drop(db: DBTables){
        let _ = try! db.con().run ( table.drop())
    }
    //    public static func testit (db: DBTables,callback: (_: Expression<Any>,_: Expression<Any>) -> Void){
    //        let stmt = try! db.run(table.filter(callback(c_id,c_email)))
    //    }
    public static func get (db: DBTables, filter: Expression<Bool>) -> [MessageTable]{
        var result = [MessageTable]()
        for row in try! db.con().prepare(table.filter(filter)) {
            result.append(MessageTable(row: row))
        }
        return result
    }
    public static func get(db: DBTables, filter: Expression<Bool>, orderby: [Expressible]) -> [MessageTable]{
        if orderby.count == 0 {
            return MessageTable.get(db: db, filter: filter)
        }
        var sortOrder = orderby
        for _ in 0...3 {
            sortOrder.append(orderby[0])
        }
        var result = [MessageTable]()
        for row in try! db.con().prepare(table.filter(filter).order(sortOrder[0],sortOrder[1],sortOrder[2],sortOrder[3],sortOrder[4])) {
            result.append(MessageTable(row: row))
        }
        return result
    }
    public func setData(payload: [String:String]) {
        data = ""
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: payload,
            options: []) {
            data = String(data: theJSONData,
                                     encoding: .ascii)
        }
    }
    public func getPayload() -> [String:String] {
        if let codedData = data.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: codedData, options: []) as? [String: Any] as! [String : String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return [:]
        
    }
}

