//
//  FcmInbound.swift
//  testsql
//
//  Created by Pete Bennett on 22/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import Foundation
import SQLite
import FirebaseMessaging
import UIKit

class FCMInbound  {
    
    private static let TAG = "MyFirebaseMsgService"
    private static var mSaveId: Double!
    
    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
 
    // [START receive_message]
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        // [START_EXCLUDE]
        // There are two types of messages data messages and notification messages. Data messages are handled
        // here in onMessageReceived whether the app is in the foreground or background. Data messages are the type
        // traditionally used with GCM. Notification messages are only received here in onMessageReceived when the app
        // is in the foreground. When the app is in the background an automatically generated notification is displayed.
        // When the user taps on the notification they are returned to the app. Messages containing both notification
        // and data payloads are treated as notification messages. The Firebase console always sends notification
        // messages. For more see: https://firebase.google.com/docs/cloud-messaging/concept-options
        // [END_EXCLUDE]
        Log.d(TAG, "From: " + remoteMessage.getFrom())
        
        // Check if message contains a data payload.
        if (remoteMessage.getData().size() > 0) {
            payload: [String: String] = new MapHelper(remoteMessage.getData())
            Log.e(TAG, "Received message " + payload["action"))
            processData(payload)
        }
        
        
    } */
    
    // [END receive_message]
    public func dataFound(payload payloadIn: [String:String]?) {
        if let payload = payloadIn {
            let status = MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS)
            let dbt = DBTables()
            let actionString = payload[FcmMessageKey.ACTION.rawValue]!
            let action = FcmMessageAction(rawValue: actionString)!
            LogWriter.write(text: "Inbound: \(action)")
            if checkForInvalid(action: action, status: status) {
                let message = MessageTable()
                if let msgId = FCMInbound.mSaveId {
                    FCMInbound.mSaveId = msgId + 1
                } else {
                    FCMInbound.mSaveId = Date().timeIntervalSinceReferenceDate
                }
                message.id = String(FCMInbound.mSaveId)
                message.setData(payload: payload)
                message.action = actionString
                _ = message.insert(db: dbt)
                LogWriter.write(text: "Inbound message deferred")
            } else {
                processData(payload: payload, dbt: dbt, action: action)
            }
            var messages = MessageTable.getAll(db: dbt)
            var changed = true
            while changed && messages.count > 0 {
                changed = false
                var remaining: [MessageTable] = []
                for message in messages {
                    let payload = message.getPayload()
                    if checkForInvalid(action: action, status: status) {
                        remaining.append(message)
                    } else {
                        LogWriter.write(text: "Deferred: \(message.action)")
                        changed = true
                        message.delete(db: dbt)
                        processData(payload: payload, dbt: dbt, action: action)
                    }
                }
                messages = remaining
                
            }
            

            
        }
    }
    private func checkForInvalid(action: FcmMessageAction, status: String) -> Bool {
        switch action {
        case .ACT_REG_OK:
            return !(status == MyPrefs.STATUS_REG_SENT)
        case .ACT_TL_ASSIGN, .ACT_ASSIGN_TL:
            return !(status == MyPrefs.STATUS_REG_OK  || status == MyPrefs.STATUS_REG_OK_TEMP)
        case .ACT_GROUP_ASSIGN:
            return !(status == MyPrefs.STATUS_REG_TL_OK)
        case .ACT_START_GROUP:
            return !(status == MyPrefs.STATUS_ANON_DONE)
        case .ACT_TL_CONFIRMED:
            return !(status == MyPrefs.STATUS_REG_TL_ASS || status == MyPrefs.STATUS_REG_TL_ASS_TEMP)
        case .ACT_BECOME_TEAM_LEAD:
            return !(status == MyPrefs.STATUS_REG_SENT)
        case .ACT_BECOME_ADMIN:
            return !(status == MyPrefs.STATUS_INIT || status == MyPrefs.STATUS_REG_SENT)
        default:
            return false
        }
    }

    private func processData(payload payloadIn: [String:String]?, dbt: DBTables, action: FcmMessageAction) {

        if let payload = payloadIn {
            let actionString = payload[FcmMessageKey.ACTION.rawValue]!
            let action = FcmMessageAction(rawValue: actionString)!

            switch (action) {
            case .ACT_REG_INVALID:
                processActRegInvalid(payload: payload, dbt: dbt)
                return
            case .ACT_REG_OK:
                processActRegOK(payload: payload, dbt: dbt)
                return
            case .ACT_ASSIGN_TL, .ACT_TL_ASSIGN:  // Why are there 2 of them?
                processActTLAssign(payload: payload, dbt: dbt)
                return
            case .ACT_TL_CONFIRMED:
                processActTLConfirmed(payload: payload, dbt: dbt)
                return
            
            case .ACT_GROUP:
                processActGroup(payload: payload, dbt: dbt)
                return
                
            case .ACT_SENDRESPONSE:
                processActSendResponse(payload: payload, dbt: dbt)
                return
                
            case .ACT_ANSWERS:
                processActAnswers(payload: payload, dbt: dbt)
                return
                
            case .ACT_BECOME_TEAM_LEAD:
                processActBecomeTeamLead(payload: payload, dbt: dbt)
                return
                
            case .ACT_GROUP_ASSIGN:
                processActGroupAssign(payload: payload, dbt: dbt)
                return
                
            case .ACT_NEW_UNLOCKCODE:
                processActNewUnlockCode(payload: payload, dbt: dbt)
                return
                
            case .ACT_PRAY:
                processActPray(payload: payload, dbt: dbt)
                return
                
            case .ACT_PANIC:
                processActPanic(payload: payload, dbt: dbt)
                return
                
            case .ACT_DAILY_SUMMARY:
                processActDailySummary(payload: payload, dbt: dbt)
                
                
                return
                
            case .ACT_NEW_PERSON:
                processActNewPerson(payload: payload, dbt: dbt)
                return
                
            case .ACT_NEW_QUESTION_FILE:
                processActNewQuestion(payload: payload, dbt: dbt)
                return
                
            case .ACT_SETVAR:
                setPreference(key: payload[FcmMessageKey.KEY.rawValue]!, value: payload[FcmMessageKey.TEXT.rawValue]!)
                return
                
            case .ACT_BECOME_ADMIN:
                processActBecomeAdmin(payload: payload, dbt: dbt)
                return
            case .ACT_RESPOND_COUNT:
                processRespondCount(payload: payload, dbt: dbt)
                return
            case .ACT_FOUND_TL:
                processFoundTL(payload: payload, dbt: dbt)
                return
            case .ACT_START_GROUP:
                processActStartGroup(payload: payload, dbt: dbt)
                return
            case .ACT_PANIC_ANON:
                processActPanicAnon(payload: payload, dbt: dbt)
                return
            case .ACT_BOUNCE:
                FcmMessage.builder(action: .ACT_BOUNCE).send()
                return
            case .ACT_SHOW_LOG:
                MyPrefs.setPref(preference: MyPrefs.SHOW_LOG, value: true)
                return
            default:
                return
            }
        }
    }
    
    private func processActRegInvalid(payload: [String:String], dbt: DBTables) {
        
        MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_REG_ERROR)
        //TODO Toast.makeText(this, "Amber Light Registration failed", Toast.LENGTH_SHORT).show()
    }
    
    private func processActRegOK(payload: [String:String], dbt: DBTables) {
        let personid = payload[FcmMessageKey.PERSON_ID.rawValue]!
        let pseudonym = payload[FcmMessageKey.PSEUDONYM.rawValue]!
        let congregation = payload[FcmMessageKey.CONGREGATION.rawValue]!
        MyPrefs.setPref(preference:  MyPrefs.PSEUDONYM, value: pseudonym)
        MyPrefs.setPref(preference:  MyPrefs.CONGREGATION, value: congregation)
        MyPrefs.setPref(preference:  MyPrefs.PERSON_ID, value: personid)
        let tlPreAssigne = payload[FcmMessageKey.TL_PRE_ASSIGNED.rawValue]
        if  let _ = tlPreAssigne, tlPreAssigne == "Y" {  // i this really right?
            MyPrefs.setPref(preference:  MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_REG_OK_TEMP)
        }
        else {
            MyPrefs.setPref(preference:  MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_REG_OK)
        }
    }
    
    private func processActTLAssign(payload: [String: String], dbt: DBTables) {
        MyPrefs.setPref(preference:  MyPrefs.TL, value: payload[FcmMessageKey.TEAM_LEADER.rawValue]!)
        MyPrefs.setPref(preference:  MyPrefs.TL_NAME, value: payload[FcmMessageKey.TL_NAME.rawValue]!)
        MyPrefs.setPref(preference:  MyPrefs.TL_CONTACT, value: payload[FcmMessageKey.TL_CONTACT.rawValue]!)
        let tlPreAssigne = payload[FcmMessageKey.TL_PRE_ASSIGNED.rawValue]
        if let _ = tlPreAssigne,  tlPreAssigne == "Y" {
            MyPrefs.setPref(preference:  MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_REG_TL_ASS_TEMP)
        }
        else {
            MyPrefs.setPref(preference:  MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_REG_TL_ASS)
        }
 //       NotificationHandler.setTimer()  // Not sure this is allowed
        QuestionListController.sendResponse(dayno: 0, dbt: dbt)   // Send answers to initial questions

    }
    
    private func processActTLConfirmed(payload: [String: String], dbt: DBTables) {
        MyPrefs.setPref(preference:  MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_REG_TL_OK)
    }
    
    private func processActGroup(payload: [String: String], dbt: DBTables) {
        let groupID = payload[FcmMessageKey.GROUP_ID.rawValue]
        var groupTable = GroupTable.getKey(db: dbt, id: groupID!)
        var insert = false
        if (groupTable == nil) {
            groupTable = GroupTable()
            groupTable!.members = 0
            insert = true
        }
        groupTable!.startdate = Int(payload[FcmMessageKey.STARTDATE.rawValue]!)
        groupTable!.id = payload[FcmMessageKey.GROUP_ID.rawValue]
        groupTable!.desc = payload[FcmMessageKey.TEXT.rawValue]
        groupTable!.status = payload[FcmMessageKey.STATUS.rawValue]
        if (insert) {
            let _ = groupTable!.insert(db: dbt)
        }
        else {
            groupTable!.update(db: dbt)
        }
        NotificationHandler.setTimer()  // Not sure this is allowed
    }
    
    private func processActSendResponse(payload: [String: String], dbt: DBTables) {
        let dayno = Int(payload[FcmMessageKey.DAYNO.rawValue]!)!
        QuestionListController.sendResponse( dayno: dayno, dbt: dbt)
    }
    
    private func processActAnswers(payload: [String: String], dbt: DBTables) {
        let response = ResponseTable()
        response.dayno = Int(payload[FcmMessageKey.DAYNO.rawValue]!)
        let numEntries = Int(payload[FcmMessageKey.NUM_ENTRIES.rawValue]!)
        response.responseDate = Int(payload[FcmMessageKey.DATE.rawValue]!)
        response.personid = payload[FcmMessageKey.PERSON_ID.rawValue]
        for i  in 0...(numEntries! - 1) {
            response.answer = payload["\(FcmMessageKey.ANSWER.rawValue)\(i)"]
            response.question = payload["\(FcmMessageKey.QUESTION.rawValue)\(i)"]
            response.id = response.personid + "D" + String(response.dayno) + "E" + String(i)
            let _ = response.insert(db: dbt)
        }
    }
    private func processActBecomeTeamLead(payload: [String: String], dbt: DBTables) {
        MyPrefs.setPref(preference: MyPrefs.I_AM_TEAMLEAD, value: true)
        MyPrefs.setPref(preference:  MyPrefs.PERSON_ID, value: payload[FcmMessageKey.PERSON_ID.rawValue]!)
        MyPrefs.setPref(preference:  MyPrefs.TL, value: payload[FcmMessageKey.TEAM_LEADER.rawValue]!)
        let congregation = payload[FcmMessageKey.CONGREGATION.rawValue]
        MyPrefs.setPref(preference:  MyPrefs.CONGREGATION, value: congregation!)
        let tlkey = payload[FcmMessageKey.TLKEY.rawValue]
        MyPrefs.setPref(preference:  MyPrefs.TL_KEY, value: tlkey!)

        Messaging.messaging().subscribe(toTopic: "/topics/" + congregation!)
        Messaging.messaging().subscribe(toTopic: "/topics/" + congregation! + "ios")
        //FirebaseMessaging.getInstance().subscribeToTopic(congregation)
    }
    private func processActGroupAssign(payload: [String: String], dbt: DBTables) {
        let groupId = payload[FcmMessageKey.GROUP_ID.rawValue]
        MyPrefs.setPref(preference:  MyPrefs.GROUP, value: groupId!)
        let tz = payload[FcmMessageKey.TIMEZONE.rawValue]!
        if let locale: TimeZone = TimeZone(abbreviation: tz) {
            NSTimeZone.default = locale   // caters for any invalid values that might arise.
        }
        MyPrefs.setPref(preference:  MyPrefs.TIMEZONE, value: tz)
        MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS,value: MyPrefs.STATUS_GR_ASSIGN)
        MyPrefs.setPref(preference:  MyPrefs.STARTDATE, value: Int(payload[FcmMessageKey.STARTDATE.rawValue]!)!)
  //      UnfinishStuff.subscribe()
        let congregation = MyPrefs.getPrefString(preference: MyPrefs.CONGREGATION)
        Messaging.messaging().subscribe(toTopic: "/topics/" + groupId!)
    
        Messaging.messaging().subscribe(toTopic: "/topics/" + groupId! + "ios")
        Messaging.messaging().subscribe(toTopic: "/topics/" + congregation)
  //      FirebaseMessaging.getInstance().subscribeToTopic(MyPrefs.getPreferenceString(this,MyPrefs.CONGREGATION))
  //      AlarmReceiver.setTimer(this)  // set reminders
    }
    private func processActNewUnlockCode(payload: [String: String], dbt: DBTables) {
        MyPrefs.setPref(preference:  MyPrefs.LOCKCODE, value: payload[FcmMessageKey.LOCKCODE.rawValue]!)
       // We haven't written the other end of this yet
    }
    private func processActPray(payload: [String: String], dbt: DBTables) {
      // This is just a notification
        
    }
    private func processActPanic(payload: [String: String], dbt: DBTables) {
    //    let serviceIntent = Intent(this, PopupAlertService.class)
        let event = EventTable()
        event.timeStamp = Date().timeIntervalSinceReferenceDate
        event.id = String(event.timeStamp)
        let pseudonym = payload[FcmMessageKey.PSEUDONYM.rawValue]
        event.text = pseudonym! + " : " + payload[FcmMessageKey.TEXT.rawValue]!
        event.type = EventTable.TYPE_PANIC
        let _ = event.insert(db: dbt)

    }
    private func processActDailySummary(payload: [String: String], dbt: DBTables) {
        let group = payload[FcmMessageKey.GROUP_ID.rawValue]
        let checkInTable = CheckInTable()
        checkInTable.group = group
        checkInTable.groupName = payload[FcmMessageKey.GROUP_NAME.rawValue]
        checkInTable.date = Int(payload[FcmMessageKey.DATE.rawValue]!)
        checkInTable.pseudonym = ""
        checkInTable.personId = ""
        checkInTable.status = payload[FcmMessageKey.STATUS.rawValue]
        checkInTable.id = checkInTable.group + String(checkInTable.date)
        let _ = checkInTable.insert(db: dbt)
        if (group == MyPrefs.getPrefString(preference: MyPrefs.GROUP))
            || MyPrefs.getPrefBool(preference: MyPrefs.I_AM_TEAMLEAD) {
            let people = Int(payload[FcmMessageKey.NUM_ENTRIES.rawValue]!)
            for i in 0...(people! - 1) {
                checkInTable.personId = payload[FcmMessageKey.PERSON_ID.rawValue + String(i)]
                checkInTable.pseudonym = payload[FcmMessageKey.PSEUDONYM.rawValue + String(i)]
                checkInTable.status = payload[FcmMessageKey.STATUS.rawValue + String(i)]
                checkInTable.id = String(checkInTable.date) + checkInTable.personId
                let _ = checkInTable.insert(db: dbt)
            }
        }
    }
    private func processActStartGroup(payload: [String: String], dbt: DBTables) {
        //  Anonymous user assigned to a group
        /* Get variables and set the anon_start to 0 */
        let personId = payload[FcmMessageKey.PERSON_ID.rawValue]!
        let pseudonym = payload[FcmMessageKey.PSEUDONYM.rawValue]!
        let congregation = payload[FcmMessageKey.CONGREGATION.rawValue]!
        let startDate = Int(payload[FcmMessageKey.STARTDATE.rawValue]!)!
        let groupId = payload[FcmMessageKey.GROUP_ID.rawValue]!
        let groupname = payload[FcmMessageKey.GROUP_NAME.rawValue]!
        
        MyPrefs.setPref(preference:  MyPrefs.PSEUDONYM, value: pseudonym)
        MyPrefs.setPref(preference:  MyPrefs.CONGREGATION, value: congregation)
        MyPrefs.setPref(preference:  MyPrefs.PERSON_ID, value: personId)
        MyPrefs.setPref(preference:  MyPrefs.STARTDATE, value: startDate)
        MyPrefs.setPref(preference:  MyPrefs.GROUP, value: groupId)
        MyPrefs.setPref(preference:  MyPrefs.ANON_START, value: 0)
        MyPrefs.setPref(preference:  MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_ACTIVE)
        let checkins = CheckInTable.getAll(db: dbt)
        for checkin in checkins {
            checkin.group = groupId
            checkin.groupName = groupname
            checkin.pseudonym = pseudonym
            checkin.update(db: dbt)
            checkin.personId = ""
            checkin.pseudonym = ""
            checkin.id=String(checkin.date)
            let _ = checkin.insert(db: dbt)
            
        }
        Messaging.messaging().subscribe(toTopic: "/topics/" + groupId + "ios")
        Messaging.messaging().subscribe(toTopic: "/topics/" + congregation)
        
        //  QuestionListController.sendResponse(dayno: 0, dbt: dbt)  will not do this at the moment.
        //  sine we have nowhere to send the responses to.
        
    }
    private func processActPanicAnon(payload: [String: String], dbt: DBTables) {
        //  Anonymous user assigned to a group
        /* Get variables and set the anon_start to 0 */
        let personid = payload[FcmMessageKey.PERSON_ID.rawValue]!
        let pseudonym = payload[FcmMessageKey.PSEUDONYM.rawValue]!
        let text = payload[FcmMessageKey.TEXT.rawValue]!
        let request = RequestTable()
        request.personId = personid
        request.pseudonym = pseudonym
        request.timeStamp = Date().timeIntervalSinceReferenceDate
        request.text = text
        request.replied = false
        request.id = personid + String(request.timeStamp)
        let _ = request.insert(db: dbt)
        
    }
    private func processActNewPerson(payload: [String: String], dbt: DBTables) {
        let personId = payload[FcmMessageKey.PERSON_ID.rawValue]
        let pseudonym = payload[FcmMessageKey.PSEUDONYM.rawValue]
        let regCode = payload[FcmMessageKey.REG_CODE.rawValue]
        var person: PersonTable
        if regCode == "" {
            //  This is the first I know of this person - just insert
            person = PersonTable()
            person.id = personId
            person.name = ""
            person.pseudonym = pseudonym
            person.status = PersonTable.STATUS_WAIT_CONTACT
            person.lastStatus = ""
            person.regCode = ""
            person.group = ""
            let _ = person.insert(db: dbt)
            //TODO surely I have to tell them?  Or does server do that?  With which message?
        } else {
            
            let people = PersonTable.get(db: dbt, filter: PersonTable.REG_CODE == regCode!)

            person = people[0]
            person.delete(db: dbt)
            person.id = personId
            person.pseudonym = pseudonym
            person.status = PersonTable.STATUS_WAIT_GROUP
            person.regCode = ""
            let _ = person.insert(db: dbt)
            FcmMessage.builder(action: .ACT_TL_CONFIRMED)    // update status on client machine
                .addData(key: .PERSON_ID, data: person.id)
                .send()
            let eventTable = EventTable()
            eventTable.timeStamp = Date().timeIntervalSinceReferenceDate
            eventTable.id = "e" + String(eventTable.timeStamp) + "new"
            eventTable.text = pseudonym! + " has registered"
            eventTable.type = EventTable.TYPE_NEW_PERSON
            let _ = eventTable.insert(db: dbt)
            
        }
        
    }
    
    
    private func processRespondCount(payload: [String: String], dbt: DBTables) {
        let numPeople = Int(payload[FcmMessageKey.NUM_ENTRIES.rawValue]!)!
        MyPrefs.setPref(preference: MyPrefs.NUM_PEOPLE, value: numPeople)
        MyPrefs.setPref(preference: MyPrefs.NUM_PEOPLE_TS, value: Float64(Date().timeIntervalSinceReferenceDate))
        if let vc = UIWindow.visibleViewController(from: UIApplication.shared.keyWindow?.rootViewController) as? TeamLeadController{
            vc.reloadPicker()
        }
    }
    private func processFoundTL(payload: [String: String], dbt: DBTables) {
        let teamLeadId = payload[FcmMessageKey.TEAM_LEADER.rawValue]!
        let code = payload[FcmMessageKey.REG_CODE.rawValue]!
        let tls = TeamLeadTable.get(db: dbt, filter: TeamLeadTable.CODE == code)
        tls[0].delete(db: dbt)
        tls[0].code = ""
        tls[0].id = teamLeadId
        _ = tls[0].insert(db: dbt)
    }
    
    private func processActNewQuestion(payload: [String: String], dbt: DBTables) {
        let version = payload[FcmMessageKey.VERSION.rawValue]
        if version == MyPrefs.getPrefString(preference: MyPrefs.QUESTION_VERSION) {
            return  // already processed this file
        }
 //       _this is not yet written on the server or tested
    }
    
    private func setPreference(key: String, value: String){
        MyPrefs.setPref(preference: key, value: value)


    }
    private func processActBecomeAdmin(payload: [String: String], dbt: DBTables) {
        // This gets called twice.
        //  The initial "I am a church" registration and validation will call first.
        //  Then after entering the reg code this will be called again with different parameters
        let status = MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS)
        if status == MyPrefs.STATUS_REG_SENT {
            MyPrefs.setPref(preference: MyPrefs.PERSON_ID, value: payload[FcmMessageKey.PERSON_ID.rawValue]!)
            MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_ACTIVE)
            let tl = TeamLeadTable()
            tl.id = MyPrefs.getPrefString(preference: MyPrefs.PERSON_ID)
            tl.name = "Me"
            tl.code = "PENDING"
            _ = tl.insert(db: dbt)
            let congregation = MyPrefs.getPrefString(preference: MyPrefs.CONGREGATION)
            Messaging.messaging().subscribe(toTopic: "/topics/" + congregation)
            
        } else {
            
            MyPrefs.setPref(preference: MyPrefs.I_AM_ADMIN, value: true)
            let congregation = payload[FcmMessageKey.CONGREGATION.rawValue]
            MyPrefs.setPref(preference: MyPrefs.CONGREGATION, value: congregation!)
            MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_ADNIN_PENDING)
            MyPrefs.setPref(preference: MyPrefs.REG_CODE, value: payload[FcmMessageKey.REG_CODE.rawValue]!)
            MyPrefs.setPref(preference: MyPrefs.CONG_CODE, value: payload[FcmMessageKey.CONG_CODE.rawValue]!)
            let tlkey = payload[FcmMessageKey.TLKEY.rawValue]
            MyPrefs.setPref(preference:  MyPrefs.TL_KEY, value: tlkey!)
        }
    }
}

