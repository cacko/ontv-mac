//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import AppKit
import CoreStore
import SwiftUI

struct ControlItemView: View {

  @ObservedObject var player = Player.instance

  @State var showHint: Bool = false

  private var note: Notification.Name!
  private var object: Any?
  private let icon: String!
  private let image: String!
  private var hint: String!

  func onClick() {
    guard note != nil else {
      return
    }
    NotificationCenter.default.post(name: note, object: object)
  }

  init(
    icon: String,
    note: Notification.Name,
    obj: Any? = nil,
    hint: String = ""
  ) {
    self.note = note
    object = obj
    self.icon = icon
    self.hint = hint
    self.image = nil
  }

  init(
    image: String,
    note: Notification.Name,
    obj: Any? = nil,
    hint: String = ""
  ) {
    self.image = image
    self.hint = hint
    self.icon = nil
    self.note = note
    object = obj
  }

  var body: some View {
    Button(action: {
      onClick()
    }) {
      if icon != nil {
        Image(systemName: icon)
          .font(Theme.Font.Control.button)
      }
      else {
        Image(image)
          .resizable()
          .frame(
            width: NSFont.systemFontSize * 2,
            height: NSFont.systemFontSize * 2,
            alignment: .center
          ).grayscale(0.6)
      }
    }
    .buttonStyle(.plain)
    .hoverAction(mode: [.cursor])
    .onHover(perform: { over in showHint = over })
  }
}

extension ToggleViews {

  struct ControlsView: View {
    @ObservedObject var player = Player.instance
    @ObservedObject var api = API.Adapter

    var body: some View {
      VStack {
        Spacer()
        HStack(alignment: .center, spacing: 2) {
          Spacer()
          HStack {
            ControlItemView(
              image: player.icon,
              note: Notification.Name.contentToggle,
              obj: ContentToggle.metadata,
              hint: player.hint
            )
            ControlItemView(
              icon: "list.bullet.rectangle",
              note: Notification.Name.contentToggle,
              obj: ContentToggle.category,
              hint: "Category"
            )
            ControlItemView(
              icon: "backward.frame.fill",
              note: Notification.Name.navigate,
              obj: AppNavigation.previous,
              hint: "Previous stream"
            )
            ControlItemView(
              icon: "forward.frame.fill",
              note: Notification.Name.navigate,
              obj: AppNavigation.next,
              hint: "Next stream"
            )
            if api.epgState == .loaded {
              if player.epgId.count > 0 {
                ControlItemView(
                  icon: "appletvremote.gen4",
                  note: .contentToggle,
                  obj: ContentToggle.guide,
                  hint: "Show programme"
                ).contentShape(Rectangle())
              }
              ControlItemView(
                icon: "play.tv",
                note: .contentToggle,
                obj: ContentToggle.epglist,
                hint: "Show programme"
              ).contentShape(Rectangle())
              ControlItemView(
                icon: "heart.text.square",
                note: .contentToggle,
                obj: ContentToggle.activityepg,
                hint: "Show programme"
              ).contentShape(Rectangle())
            }
            ControlItemView(
              icon: "rectangle.and.text.magnifyingglass",
              note: Notification.Name.contentToggle,
              obj: ContentToggle.search,
              hint: "Search"
            )

            ControlItemView(
              icon: player.isFullscreen
                ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right",
              note: Notification.Name.toggleFullscreen,
              obj: nil,
              hint: "Exit fullscreen"
            )
            ControlItemView(
              icon: "speaker.slash",
              note: Notification.Name.toggleAudio,
              hint: "Toggle audio"
            ).foregroundColor(
              player.isMuted
                ? Theme.Color.Icon.enabled : Theme.Color.Icon.disabled
            ).contentShape(Rectangle())
            if !player.isFullscreen {
              ControlItemView(
                icon: "square.3.stack.3d.top.fill",
                note: Notification.Name.toggleOnTop,
                hint: "Toggle always on top"
              )
              .foregroundColor(
                player.onTop
                  ? Theme.Color.Icon.enabled : Theme.Color.Icon.disabled
              ).contentShape(Rectangle())
            }
          }
          .padding()
          .background(.black.opacity(0.6))
          .cornerRadius(10)
          Spacer()
        }.padding()
      }
    }
  }
}
