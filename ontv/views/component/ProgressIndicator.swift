//
//  ProgressIndicator.swift
//  ProgressIndicator
//
//  Created by Alex on 05/10/2021.
//

import Foundation
import SwiftUI

struct ProgressIndicator: NSViewRepresentable {
  typealias NSViewType = NSProgressIndicator

  private let v: NSProgressIndicator = NSProgressIndicator(frame: .zero)

  func makeNSView(context: Self.Context) -> Self.NSViewType {
    v.style = .spinning
    v.startAnimation(nil)
    return v
  }

  func start() {
    let _ = self.v.startAnimation(_:)
    return
  }

  func stop() {
    let _ = self.v.stopAnimation(_:)
    return
  }

  func updateNSView(_ nsView: Self.NSViewType, context: Self.Context) {}
}
