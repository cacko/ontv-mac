//
//  Size.swift
//  craptv
//
//  Created by Alex on 31/10/2021.
//

import Foundation

extension NSSize {
  var resolution: String {
    "\(String(format: "%.0f", self.width))x\(String(format: "%.0f", self.height))"
  }

  var aspectSize: NSSize {
    guard let fraction = Fraction(numerator: Int(self.width), denominator: Int(self.height)) else {
      return NSSize(width: width, height: height)
    }
    let reduced = fraction.reduced()
    return NSSize(width: reduced.numerator, height: reduced.denominator)
  }

  var aspectRatio: CGFloat {
    CGFloat(self.width / self.height)
  }

  func zoom(_ op: Video.Zoom) -> NSSize {
    var newWidth: CGFloat = self.width
    switch op {
    case .shrink:
      newWidth = newWidth - 50
      break
    case .expand:
      newWidth = newWidth + 50
      break
    }
    return NSSize(width: newWidth, height: newWidth * (1 / self.aspectRatio))
  }

}
