//
//  ScrollingView.swift
//  craptv
//
//  Created by Alex on 06/11/2021.
//

import Foundation
import Introspect
import SwiftUI

struct ScrollingView<Content: View>: View {

  private let direction: Axis.Set
  private let onPress: () -> Void = {}

  let content: Content
  @State private var vOffset: CGFloat = 0
  @State private var hOffset: CGFloat = 0
  @State private var scrollView: NSScrollView!
  @GestureState private var dragPosition: NSPoint = NSPoint.zero

  init(
    _ direction: Axis.Set = .vertical,
    @ViewBuilder content: () -> Content
  ) {
    self.direction = direction
    self.content = content()
  }

  func onVerticalScroll(_ drag: NSPoint, _ geo: GeometryProxy) {
    let delta = drag.y
    let maxOffset = geo.frame(in: .global).maxY * -1
    vOffset = min(max(maxOffset, vOffset + delta), 0)
    scrollView.scroll(NSPoint(x: 0, y: vOffset))
  }

  func onHorizontalScroll(_ drag: NSPoint, _ geo: GeometryProxy) {
    let delta = drag.x
    hOffset += 100 * (delta > 0 ? 1 : -1)
    scrollView?.scroll(NSPoint(x: hOffset, y: 0))
  }

  var body: some View {
    GeometryReader { outside in
      ScrollView(direction, showsIndicators: false) {
        VStack {
          if direction == .vertical {
            LazyVStack {
              content
            }
          }
          else {
            LazyHStack {
              content
            }
          }
        }.introspectScrollView { view in
          scrollView = view
        }.simultaneousGesture(
          DragGesture(minimumDistance: 0).updating($dragPosition) {
            (value, gestureState, transaction) in
            gestureState = NSPoint(
              x: value.startLocation.x - value.location.x,
              y: value.startLocation.y - value.location.y
            )
          }.exclusively(
            before:
              TapGesture()
              .onEnded { _ in }
          )
        ).onChange(
          of: dragPosition,
          perform: { (drag) in
            switch direction {
            case .vertical:
              return onVerticalScroll(drag, outside)
            case .horizontal:
              return onHorizontalScroll(drag, outside)
            default:
              break
            }
          }
        )
      }
    }
  }
}
