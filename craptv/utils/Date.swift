//
//  Date.swift
//  Date
//
//  Created by Alex on 03/10/2021.
//

import Foundation

func isSameDay(date1: Date, date2: Date) -> Bool {
    let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
    if diff.day == 0 {
        return true
    } else {
        return false
    }
}
