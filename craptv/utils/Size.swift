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
  func getRandom() -> NSSize {
    return NSSize(
      width: self.width + (CGFloat.random(in: 1...10) / 10),
      height: self.height + (CGFloat.random(in: 1...10) / 10)
    )

  }
}
