//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import AppKit
import CoreStore
import Introspect
import SwiftUI

struct ControlItemView: View {

  @ObservedObject var player = Player.instance

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
    hint: String? = ""
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
          .symbolVariant(.rectangle.fill)
          .symbolRenderingMode(.hierarchical)
          .font(.system(size: player.iconSize.width))
      }
      else {
        Image(image)
          .resizable()
          .frame(
            width: player.iconSize.width,
            height: player.iconSize.height,
            alignment: .center
          ).grayscale(1)
      }
    }
    .buttonStyle(.borderless)
    .help(hint)
    .hoverAction(mode: [.cursor])
  }
}

extension ToggleViews {

  struct AlwaysOnControlsView: View {

    @ObservedObject var player = Player.instance

    var body: some View {
      ControlItemView(
        image: player.vendor.icon,
        note: Notification.Name.vendorToggle,
        hint: player.vendor.hint
      )
      ControlItemView(
        icon: "list.bullet.rectangle",
        note: Notification.Name.contentToggle,
        obj: ContentToggle.category,
        hint: "Category streams"
      )
      ControlItemView(
        icon: "chevron.down",
        note: Notification.Name.navigate,
        obj: AppNavigation.next,
        hint: "Next stream"
      )
      ControlItemView(
        icon: "chevron.up",
        note: Notification.Name.navigate,
        obj: AppNavigation.previous,
        hint: "Previous stream"
      )
    }
  }

  struct EPGControlsView: View {
    @ObservedObject var player = Player.instance
    @ObservedObject var api = API.Adapter

    var body: some View {
      if api.epgState == .loaded {
        if player.epgId.count > 0 {
          ControlItemView(
            icon: "appletvremote.gen4",
            note: .contentToggle,
            obj: ContentToggle.guide,
            hint: "Show programme for the stream"
          )
        }
        ControlItemView(
          icon: "play.tv",
          note: .contentToggle,
          obj: ContentToggle.epglist,
          hint: "Show programmes for all streams"
        )
        ControlItemView(
          icon: "heart.text.square",
          note: .contentToggle,
          obj: ContentToggle.activityepg,
          hint: "Show programme for recently opened streams"
        )
      }
    }
  }

  struct PlayerControlsView: View {
    @ObservedObject var player = Player.instance

    var body: some View {
      ControlItemView(
        icon: player.isFullscreen
          ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right",
        note: Notification.Name.toggleFullscreen,
        obj: nil,
        hint: "Exit fullscreen"
      )
      ControlItemView(
        icon: player.isMuted
          ? "speaker.slash" : "speaker.wave.\(String(player.volumeStage))",
        note: Notification.Name.toggleAudio,
        hint: "Toggle audio"
      )
      if !player.isFullscreen {
        ControlItemView(
          icon: player.onTop ? "square.stack.3d.up.fill" : "square.stack.3d.up.slash",
          note: Notification.Name.toggleOnTop,
          hint: "Toggle Always on top"
        )
      }

    }
  }

  struct StreamControlsView: View {

    var body: some View {
      ControlItemView(
        icon: "calendar",
        note: Notification.Name.contentToggle,
        obj: ContentToggle.schedule,
        hint: "TheSportsDb Schedule"
      )
      ControlItemView(
        icon: "sportscourt",
        note: Notification.Name.contentToggle,
        obj: ContentToggle.livescores,
        hint: "Livescores"
      )
      ControlItemView(
        icon: "rectangle.and.text.magnifyingglass",
        note: Notification.Name.contentToggle,
        obj: ContentToggle.search,
        hint: "Search for whatever"
      )
    }
  }

  struct ControlsView: View {
    @ObservedObject var player = Player.instance

    var body: some View {
      VStack {
        Spacer()
        HStack(alignment: .center, spacing: 2) {
          Spacer()
          HStack {
            AlwaysOnControlsView()
            EPGControlsView()
            StreamControlsView()
            PlayerControlsView()
          }
          .padding()
          .onHover(perform: { hover in
            player.controlsState = hover ? .hovered : .visible
          })
          .background(.black.opacity(0.6))
          .cornerRadius(10)
          Spacer()
        }.padding()
      }
    }
  }
}
