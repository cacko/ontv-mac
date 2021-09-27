//
//  String.swift
//  String
//
//  Created by Alex on 15/10/2021.
//

import Foundation

extension String {
    func withoutHtmlTags() -> String {
        return components(separatedBy: "\"").first ?? self
    }
}


