//
//  ContestManager.swift
//  ContestBeacon
//
//  Created by Jim Sugg on 2/21/17.
//  Copyright © 2017 BrightSign, LLC. All rights reserved.
//

import UIKit
//import Alamofire

class Participant: NSObject {
    var name = UserDefaults.standard.string(forKey: "ptcpName")
    var company = UserDefaults.standard.string(forKey: "ptcpCompany")
    var phoneNumber = UserDefaults.standard.string(forKey: "ptcpPhone")
    var email = UserDefaults.standard.string(forKey: "ptcpEmail")
    var proximity = UserDefaults.standard.bool(forKey: "ptcpProximity")
    
    var isValid : Bool {
        get {
            if let name = name , !name.isEmpty,
                let company = company , !company.isEmpty,
                let phoneNumber = phoneNumber , !phoneNumber.isEmpty,
                let email = email , email.characters.count > 4 && email.range(of: "@") != nil
            {
                return true
            }
            return false
        }
    }
    
    // Return true if current values are different from those saved
    var didChange : Bool {
        get {
            var last = UserDefaults.standard.string(forKey: "ptcpName")
            if last != name {
                return true
            }
            last = UserDefaults.standard.string(forKey: "ptcpCompany")
            if last != company {
                return true
            }
            last = UserDefaults.standard.string(forKey: "ptcpPhone")
            if last != phoneNumber {
                return true
            }
            last = UserDefaults.standard.string(forKey: "ptcpEmail")
            if last != email {
                return true
            }
            return false
        }
    }
    
    func save() {
        // Reset proximity if credentials are not completely entered
        if !isValid {
            proximity = false
        }
        if let name = name {
            UserDefaults.standard.set(name, forKey: "ptcpName")
        }
        if let company = company {
            UserDefaults.standard.set(company, forKey: "ptcpCompany")
        }
        if let phoneNumber = phoneNumber {
            UserDefaults.standard.set(phoneNumber, forKey: "ptcpPhone")
        }
        if let email = email {
            UserDefaults.standard.set(email, forKey: "ptcpEmail")
        }
        UserDefaults.standard.set(proximity, forKey: "ptcpProximity")
        UserDefaults.standard.synchronize()
    }
    
    var paramDictionary : [String : String] {
        get {
            return [
                "name" : name != nil ? name! : "",
                "company" : company != nil ? company! : "",
                "email" : email != nil ? email! : "",
                "phone" : phoneNumber != nil ? phoneNumber! : "",
                "proximity" : proximity.description
            ]
        }
    }
}

class ContestManager: NSObject {

    // Singleton
    static let sharedInstance = ContestManager()
    
    let contestServerUrlBase = ""      // TODO: Server URL needs to be added
    
    var participant = Participant()
    
    var clientId = UserDefaults.standard.string(forKey: "clientId")
    var writtenToServer = UserDefaults.standard.bool(forKey: "ptcpWrittenToServer")
    var serverUpdatePending = UserDefaults.standard.bool(forKey: "ptcpServerUpdatePending")
    var serverUpdateInProcess = UserDefaults.standard.bool(forKey: "ptcpServerUpdateInProcess")
    
    override init() {
        if clientId == nil {
            // Create persistent clientId if it doesn't exist
            clientId = UUID().uuidString
            UserDefaults.standard.set(clientId, forKey: "clientId")
            UserDefaults.standard.synchronize()
        }
    }
    
    fileprivate func updateContestServer(_ params : [String : String]) {
        UserDefaults.standard.set(true, forKey: "ptcpServerUpdatePending")
        UserDefaults.standard.set(true, forKey: "ptcpServerUpdateInProcess")
        UserDefaults.standard.synchronize()
        // Add clientId to params
        var serverParams = params
        serverParams["uuid"] = clientId!
//        Alamofire.request(contestServerUrlBase + "user", method: .post, parameters: serverParams, encoding: JSONEncoding.default)
//            .responseJSON { response in
//                if let error = response.result.error {
//                    BBTLog.write("Error updating content server: %@", error.localizedDescription)
//                }
//                else if let result = response.result.value as? [String:String?],
//                    let serverError = result["error"],
//                    let errorString = serverError
//                {
//                    BBTLog.write("Error updating content server: %@", errorString)
//                }
//                else {
//                    BBTLog.write("Contest server updated")
//                    UserDefaults.standard.set(true, forKey: "ptcpWrittenToServer")
//                    UserDefaults.standard.set(false, forKey: "ptcpServerUpdatePending")
//                }
//                UserDefaults.standard.set(false, forKey: "ptcpServerUpdateInProcess")
//                UserDefaults.standard.synchronize()
//        }
    }
    
    func updateParticipant(_ newData : Participant) {
        if newData.didChange {
            participant = newData
            participant.save()
            updateContestServer(participant.paramDictionary)
        }
    }
    
    func updateProximity(_ close : Bool) {
        // Always update proximity
        participant.proximity = close
        UserDefaults.standard.set(participant.proximity, forKey: "ptcpProximity")
        UserDefaults.standard.synchronize()
        updateContestServer(["proximity":participant.proximity.description])
    }
    
    func checkPendingUpdate() {
        serverUpdatePending = UserDefaults.standard.bool(forKey: "ptcpServerUpdatePending")
        serverUpdateInProcess = UserDefaults.standard.bool(forKey: "ptcpServerUpdateInProcess")
        if serverUpdatePending && !serverUpdateInProcess {
            BBTLog.write("Contest server checkPendingUpdate: calling updateContestServer")
            updateContestServer(participant.paramDictionary)
        }
    }
}
