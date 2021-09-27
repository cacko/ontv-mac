//
//  Size.swift
//  craptv
//
//  Created by Alex on 31/10/2021.
//

import Foundation

extension NSSize {
  func toResolution() -> String {
    return "\(String(format: "%.0f", self.width))x\(String(format: "%.0f", self.height))"
  }
}
