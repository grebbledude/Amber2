//
//  MyPrefs.swift
//  testsql
//
//  Created by Pete Bennett on 06/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import Foundation
final class MyPrefs {
    
    public static let STARTDATE = "startdate" 
    public static let CONGREGATION = "cong"
    public static let GROUP = "group"
    public static let TL = "tl"
    public static let TL_NAME = "tlname"
    public static let TL_CONTACT = "tlcont"
    public static let TIMEZONE = "timezone"
    public static let CURRENT_STATUS = "status"
    public static let I_AM_TEAMLEAD = "iamtl"
    public static let PSEUDONYM = "pseudonym"
    public static let PERSON_ID = "personid"
    public static let LOCKCODE = "lockcode"
    public static let LAST_CHECKIN = "lastchk"
    public static let INVALID_CODE_ATTEMPTS = "invcode"
    public static let CODE_ENTERED_TIMESTAMP = "codeints"
    public static let SILENT_ALERT = "silentalert"
    public static let SILENT_REMINDER = "silentrem"
    public static let QUESTION_VERSION = "questionvers"
    public static let I_AM_ADMIN = "iamadmin"
    public static let TL_KEY = "tlkey"
    public static let MSGNO = "msgno"
    public static let GROUP_NUM = "grnum"
    public static let NUM_PEOPLE = "numP"
    public static let NUM_PEOPLE_TS = "numPTS"
    public static let NOTIF_6 = "not6"
    public static let NOTIF_7 = "not7"
    public static let NOTIF_8 = "not8"
    public static let NOTIF_9 = "not9"
    public static let NOTIF_10 = "not10"
    public static let NOTIF_11 = "not11"
    public static let NOTIF_12 = "not12"
    public static let ANON_START = "anonstart"
    public static let ANON_MODE = "anonmode"
    public static let LAST_UNLOCK = "lasttunlock"
    public static let REG_CODE = "regCode"
    public static let CONG_CODE = "congCode"
    
    
    
    public static let STATUS_REG_SENT = "regsent"
    public static let STATUS_REG_ERROR = "regerror"
    public static let STATUS_REG_OK = "regok"
    public static let STATUS_REG_OK_TEMP = "regoktemp"
    public static let STATUS_REG_TL_ASS = "tl_ass"
    public static let STATUS_REG_TL_ASS_TEMP = "tl_ass_tmp"
    public static let STATUS_REG_TL_OK = "regTLok"
    public static let STATUS_ACTIVE = "active"
    public static let STATUS_OLD = "old"
    public static let STATUS_GR_ASSIGN = "gr_assign"
    public static let STATUS_INIT = "init"
    public static let STATUS_ANON = "anon"
    public static let STATUS_ANON_DONE = "anondone"  // done trial
    public static let STATUS_ADNIN_PENDING = "andmpend"  // waiting for confirmation that I am admin
    
    static var prefs: [String: String]?
    private static let prefsKey = "prefsKey"
    static private let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static private let prefsURL = DocumentsDirectory.appendingPathComponent("prefs")
    
    
    static private func getAll() {
        if let _ = prefs {
            return
        }
        if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: prefsURL.path) as? [String: String]{
            prefs = dict
        }
        else {
            prefs = [:]
            writeData()
        }
    }
    static private func writeData() {
        NSKeyedArchiver.archiveRootObject(prefs!, toFile: prefsURL.path)
    }
    static public func getPrefString(preference: String)->String{
        getAll()
        return (prefs![preference] ?? "")
    }
    static public func getPrefFloat(preference: String)->Float64{
        getAll()
        if let res = prefs![preference] {
            return Float64(res)!
        }
        return 0.0
    }
    static public func getPrefBool(preference: String)->Bool{
        getAll()
        if let res = prefs![preference] {
            return res == "true"
        }
        return false
    }
    static public func getPrefInt(preference: String)->Int{
        getAll()
        if let res = prefs![preference] {
            return Int(res)!
        }
        return 0
    }
    static public func setPref (preference: String, value: String) {
        getAll()
        let _ = prefs?.updateValue(value, forKey: preference)
        writeData()
    }
    
    static public func setPref (preference: String, value: Float64) {
        getAll()
        let _ = prefs?.updateValue(String(value), forKey: preference)
        writeData()
    }
    static public func setPref (preference: String, value: Int) {
        getAll()
        let _ = prefs?.updateValue(String(value), forKey: preference)
        writeData()
    }
    static public func setPref (preference: String, value: Bool) {
        getAll()
        let _ = prefs?.updateValue(String(value), forKey: preference)
        writeData()
    }
    static public func getPrefs () -> [String : String] {
        getAll()
        return prefs!
    }
    static public func reset() {
        prefs = [:]
        writeData()
    }
    
}
