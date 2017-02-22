//
//  BBTLog.swift
//  BrightSignBT
//
//  Created by Jim Sugg on 1/26/16.
//  Copyright © 2016 BrightSign, LLC. All rights reserved.
//

import Foundation

protocol BBTLogDelegate {
    func gotLogText(_ text: String)
}
class BBTLog: NSObject {
    
    static var delegate: BBTLogDelegate?
    
    static var enabled : Bool {
        get {
            if let enab = UserDefaults.standard.object(forKey: "bbtLogEnabled") as? Bool {
                return enab
            } else {
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "bbtLogEnabled")
            UserDefaults.standard.synchronize()
        }
    }
    
    static func write(_ format: String, _ args: CVarArg...) {
        let s = String(format: format, arguments: args)
        NSLog(s)
        delegate?.gotLogText(s)
    }
}
