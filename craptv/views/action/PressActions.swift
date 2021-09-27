//
//  PressActions.swift
//  craptv
//
//  Created by Alex on 27/10/2021.
//

import Foundation
import SwiftUI

extension NSView {
  public override func mouseDragged(with event: NSEvent) {
    if Player.instance.contentToggle != .search {
      window?.performDrag(with: event)
    }
    super.mouseDragged(with: event)
  }

  public override func mouseDown(with event: NSEvent) {
    if Player.instance.contentToggle != .search {
      window?.performDrag(with: event)
    }
    super.mouseDown(with: event)
  }

}

struct PressActions: ViewModifier {
  func body(content: Content) -> some View {
    content
      .simultaneousGesture(
        DragGesture(minimumDistance: 1)
          .onChanged { _ in onDragStart() }
          .onEnded { _ in onDragEnd() }
          .exclusively(
            before:
              TapGesture()
              .onEnded { _ in onPress() }

          )
      )
  }

  var onPress: () -> Void
  var onDragStart: () -> Void
  var onDragEnd: () -> Void
}

extension View {
  func pressAction(
    onPress: @escaping (() -> Void),
    onDragStart: @escaping (() -> Void),
    onDragEnd: @escaping (() -> Void)
  ) -> some View {
    modifier(
      PressActions(
        onPress: { onPress() },
        onDragStart: { onDragStart() },
        onDragEnd: { onDragEnd() }
      )
    )
  }

}
