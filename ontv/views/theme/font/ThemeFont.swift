//
//  Font.swift
//  Font
//
//  Created by Alex on 14/10/2021.
//

import Foundation
import Kingfisher
import SwiftUI

extension Theme.Font {

  enum Size {
    static let base =
      (NSScreen.main?.frame.height ?? 1920) / 50
    static let large = Size.base + Size.base * 0.05
    static let larger = Size.large + Size.large * 0.05
    static let small = Size.base - Size.base * 0.05
    static let smaller = Size.small - Size.small * 0.05
    static let smallest = Size.smaller - Size.smaller * 0.05
    static let big = Size.base * 1.5
    static let superbig = Size.base * 3.5
    static let title = Size.base * 1.5
    static let EPGRow = CGSize(
      width: NSFont.systemFontSize * 40,
      height: Size.base + (Size.small * 3) + 10
    )
  }

  static let channel: SwiftUI.Font = Font.custom(
    "Atami Stencil Bold",
    size: Size.base,
    relativeTo: .title
  )
  static let programme: SwiftUI.Font = Font.custom("Teko SemiBold", size: Size.base)
  static let result: SwiftUI.Font = Font.custom("Atami Stencil Bold", size: Size.large)
  static let title: SwiftUI.Font = Font.custom("Atami Stencil Bold", size: Size.larger)
  static let desc: SwiftUI.Font = Font.custom("Teko Light", size: Size.small)
  static let time: SwiftUI.Font = Font.system(size: Size.small, weight: .bold, design: .monospaced)
  static let searchTime: SwiftUI.Font = Font.custom("Teko Light", size: Size.smallest)
  static let hint: SwiftUI.Font = Font.custom("Teko Light", size: Size.small)
  static let status: SwiftUI.Font = Font.custom("Teko Light", size: Size.small)
  static let score: SwiftUI.Font = Font.custom("Atami Stencil Bold", size: Size.large)

  static let scheduleHeader: SwiftUI.Font = Font.custom(
    "Atami Stencil Bold",
    size: Size.large,
    relativeTo: .title
  )

  enum Ticker {
    static let team: SwiftUI.Font = Font.custom(
      "Atami Stencil Bold",
      size: Size.smaller,
      relativeTo: .title
    )
    static let score: SwiftUI.Font = Font.custom("Atami Stencil Bold", size: Size.base)
    static let hint: SwiftUI.Font = Font.custom("Teko Light", size: Size.small)
  }

  static let searchInput = NSFont(name: "Atami Stencil Bold", size: Size.big)
  static let timeHint = NSFont.monospacedSystemFont(ofSize: Size.base, weight: .bold)
  static let progress = Font.system(size: Size.base, weight: .light, design: .monospaced)

  enum Preferences {
    static let userLabel = Font.custom("Atami Stencil", size: Size.smallest)
    static let userValue = Font.custom("Atami Stencil Bold", size: Size.smallest)
  }

  enum Bookmark {
    static let button = Font.system(size: Size.superbig, weight: .heavy, design: .monospaced)
    static let title = Font.system(size: Size.big, weight: .heavy, design: .rounded)
  }

  enum Control {
    static let button = Font.title
  }

}
