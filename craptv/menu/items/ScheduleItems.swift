//
//  Schedule.swift
//  Schedule
//
//  Created by Alex on 03/10/2021.
//

import Foundation

class ScheduleItem: BaseItem, Collection {
    var corelazy: LazyStreams
      
    required init(action: Selector?, corelazy: LazyStreams) {
        self.corelazy = corelazy
        super.init(title: corelazy.title, action: action, keyEquivalent: "")
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var expiresIn = TimeInterval(60*60*2 + 60*15)
    
    var startTime: Date {
        if let object = corelazy as? Schedule {
            return object.timestamp
        }
        return Date()
    }
    
    var hasExpired: Bool {
        Date().timeIntervalSince(startTime) > expiresIn
    }
}
