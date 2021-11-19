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

  static let channel: SwiftUI.Font = Font.custom(
    "Atami Stencil Bold",
    size: 18,
    relativeTo: .title
  )
  static let programme: SwiftUI.Font = Font.custom("Teko SemiBold", size: 18, relativeTo: .title)
  static let result: SwiftUI.Font = Font.custom("Atami Stencil Bold", size: 20, relativeTo: .title)
  static let title: SwiftUI.Font = Font.custom("Atami Stencil Bold", size: 22, relativeTo: .title)
  static let desc: SwiftUI.Font = Font.custom("Teko Light", size: 15, relativeTo: .title)
  static let time: SwiftUI.Font = Font.system(size: 15, weight: .bold, design: .monospaced)
  static let searchTime: SwiftUI.Font = Font.system(size: 10, design: .monospaced)
  static let hint: SwiftUI.Font = Font.custom("Teko Light", size: 13, relativeTo: .title)
  static let score: SwiftUI.Font = Font.custom("Major Mono Display", size: 20)

  static let scheduleHeader: SwiftUI.Font = Font.custom(
    "Atami Stencil Bold",
    size: 20,
    relativeTo: .title
  )

  enum Ticker {
    static let team: SwiftUI.Font = Font.custom(
      "Atami Stencil Bold",
      size: 14,
      relativeTo: .title
    )
    static let score: SwiftUI.Font = Font.custom("Major Mono Display", size: 20)
    static let hint: SwiftUI.Font = Font.custom("Teko Light", size: 13, relativeTo: .title)
  }

  static let searchInput = NSFont(name: "Atami Stencil Bold", size: 30)
  static let timeHint = NSFont.monospacedSystemFont(ofSize: 18, weight: .bold)

  enum Preferences {
    static let userLabel = Font.system(size: 15, weight: .thin, design: .monospaced)
    static let userValue = Font.system(size: 15, weight: .heavy, design: .rounded)
  }

  enum Bookmark {
    static let button = Font.system(size: 80, weight: .heavy, design: .monospaced)
    static let title = Font.system(size: 30, weight: .heavy, design: .rounded)
  }

  enum Control {
    static let button = Font.title
  }

}
