//
//  ScrollingView.swift
//  craptv
//
//  Created by Alex on 06/11/2021.
//

import Foundation
import Introspect
import SwiftUI

extension Animation {
  static var instant: Animation {
    return .linear(duration: 0.01)
  }
}

struct ScrollingView<Content: View>: View {

  private let direction: Axis.Set
  private let onPress: () -> Void = {}

  var timer: DispatchSourceTimer!
  private var scrolling: [String]!

  let content: Content
  @State private var vOffset: CGFloat = 0
  @State private var hOffset: CGFloat = 0
  @State private var scrollView: NSScrollView!
  @State var scrollIdx: Int = -1
  @State var scrollOffset: Int = 1
  @GestureState private var dragPosition: NSPoint = NSPoint.zero

  init(
    _ direction: Axis.Set = .vertical,
    scrolling: [String]? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.direction = direction
    self.content = content()
    guard scrolling != nil else {
      return
    }
    self.scrolling = scrolling!
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

  func autoScroll(_ proxy: ScrollViewProxy) {
    DispatchQueue.main.async {
      withAnimation(.instant) {
        withAnimation(.linear(duration: 3.0).speed(2.0)) {
          self.scrollIdx += self.scrollOffset
          print(self.scrolling.count, self.scrollIdx)
          proxy.scrollTo(self.scrolling[self.scrollIdx], anchor: .leading)
          if scrollIdx + 1 == self.scrolling.count {
            self.scrollOffset = -1
          }
          if scrollIdx == 0 {
            self.scrollOffset = 1
          }
        }
      }
    }

  }

  var body: some View {
    GeometryReader { outside in
      ScrollViewReader { proxy in
        ScrollView(direction, showsIndicators: false) {
          VStack(alignment: .center, spacing: 0) {
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
//            autoScroll(proxy)
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
}
