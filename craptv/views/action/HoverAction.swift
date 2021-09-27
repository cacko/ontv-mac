//
//  HoverAction.swift
//  craptv
//
//  Created by Alex on 27/10/2021.
//

import Foundation
import SwiftUI

struct HoverAction: ViewModifier {

  enum Mode {
    case cursor, colors
  }

  @State var mode: [Mode] = [.cursor, .colors]

  let center = NotificationCenter.default
  let mainQueue = OperationQueue.main

  private let state: [() -> Void] = [
    { NSCursor.arrow.set() },
    { NSCursor.pointingHand.set() },
  ]

  private let colors: [Color] = [
    Theme.Color.Hover.listItem.off,
    Theme.Color.Hover.listItem.on,
  ]

  private let bright: [Double] = [
    0.0,
    0.3,
  ]

  @State private var brightness: Double = 0.0
  @State private var background: Color = Theme.Color.Hover.listItem.off

  @State var isHovered: Bool = false {
    didSet {
      if self.mode.contains(.cursor) {
        state[isHovered.intValue]()
      }
      if self.mode.contains(.colors) {
        self.brightness = self.bright[isHovered.intValue]
        self.background = self.colors[isHovered.intValue]
      }
    }
  }

  func body(content: Content) -> some View {

    center.addObserver(forName: .search_navigate, object: nil, queue: mainQueue) { _ in
      isHovered = false
    }

    return
      content
      .onHover(perform: { _ in isHovered.toggle() })
      .brightness(brightness)
      .background(background)
  }
}

extension View {

  func hoverAction(mode: [HoverAction.Mode]? = nil) -> some View {
    modifier(
      HoverAction(mode: mode ?? [.cursor, .colors])
    )
  }

}
