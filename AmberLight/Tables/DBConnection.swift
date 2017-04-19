//
//  DBConnection.swift
//  testsql
//
//  Created by Pete Bennett on 02/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import Foundation
import SQLite/*
class DBTables  {
    var mConnection: Connection?

    private static func connect() throws -> Connection{
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        var con: Connection
        con = try Connection("\(path)/db.sqlite3")
        return con
    }
    init(){
        
    }

    deinit {
        if let _ = mConnection {
            mConnection = nil
        }
    }
    public func con () throws -> Connection{
        if let _ = mConnection  {
        }
        else {
            mConnection = try DBTables.connect()
        }
        return mConnection!
    }
    
}
protocol TableHelper {
    static func getAll(db: Connection) -> [Self]
    static func get(db: Connection, filter: Expression<Bool>) -> [Self]
    static func get(db: Connection, filter: Expression<Bool>, orderby: [Expressible]) -> [Self]
    func delete(db: Connection)
    func insert(db: Connection) -> Bool
    func update(db: Connection)
    static func getKey(db: Connection, id: String) -> Self?
    
}
*/
