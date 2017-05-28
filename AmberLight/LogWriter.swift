//
//  LogWriter.swift
//  AmberLight
//
//  Created by Pete Bennett on 23/05/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import Foundation
class LogWriter {
    static let FILENAME = "log.txt"

    
    static func write(text: String) {
 
        let fileurl = getURL()
        let data = (text + "\n").data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        if let fileHandle = FileHandle(forWritingAtPath: (fileurl.path)) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
        else {
            try? data.write(to: fileurl, options: .atomic)
        }
    }
    private static func getURL() -> URL {
        let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
        return  dir.appendingPathComponent(FILENAME)
    }
    static func read() -> [String] {
        let fileurl = getURL()
        let contents = try? String(contentsOfFile: fileurl.path, encoding: .utf8)
        return contents?.components(separatedBy: .newlines) ?? []
    }
}
