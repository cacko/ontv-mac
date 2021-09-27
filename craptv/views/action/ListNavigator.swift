//
//  NavigateAction.swift
//  craptv
//
//  Created by Alex on 27/10/2021.
//

import Foundation
import SwiftUI

struct ListHighlightAction: ViewModifier {

  @ObservedObject var player = Player.instance

  private let colors: [Color] = [
    Theme.Color.Hover.listItem.off,
    Theme.Color.Hover.listItem.on,
  ]

  private let stateColors: [Color] = [
    Theme.Color.State.off,
    Theme.Color.State.live,
  ]

  @State private var state: Bool = false

  @Binding var selectedId: Int

  var itemId: Int

  @State var highlightPlaying: Bool = false
  
  func body(content: Content) -> some View {

    content
      .background(colors[(selectedId == itemId).intValue])
      .background(highlightPlaying ? stateColors[(player.stream.id == itemId).intValue] : .clear)
  }
}

extension View {

  func listHighlight(
    selectedId: Binding<Int>,
    itemId: Int,
    highlightPlaying: Bool = false
  ) -> some View {
    modifier(
      ListHighlightAction(
        selectedId: selectedId,
        itemId: itemId,
        highlightPlaying: highlightPlaying
      )
    )
  }
}
