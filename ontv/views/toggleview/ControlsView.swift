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
  private let icon: ContentToggleIcon!
  private let image: String!
  private var hint: String!

  func onClick() {
    guard note != nil else {
      return
    }
    player.controlsState = .visible
    NotificationCenter.default.post(name: note, object: object)
  }

  init(
    icon: ContentToggleIcon,
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
        ControlSFSymbolView(icon: icon, width: player.iconSize.width)
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
        icon: .streams,
        note: Notification.Name.contentToggle,
        obj: ContentToggle.streams,
        hint: "Streams"
      )
      if player.stream != nil {
        ControlItemView(
          icon: .category,
          note: Notification.Name.contentToggle,
          obj: ContentToggle.category,
          hint: "Category streams"
        )
        ControlItemView(
          icon: .next,
          note: Notification.Name.navigate,
          obj: AppNavigation.next,
          hint: "Next stream"
        )
        ControlItemView(
          icon: .previous,
          note: Notification.Name.navigate,
          obj: AppNavigation.previous,
          hint: "Previous stream"
        )
      }
    }
  }

  struct EPGControlsView: View {
    @ObservedObject var player = Player.instance
    @ObservedObject var api = API.Adapter

    var body: some View {
      if api.epgState == .ready {
        if player.epgId.count > 0 {
          ControlItemView(
            icon: .guide,
            note: .contentToggle,
            obj: ContentToggle.guide,
            hint: "Show programme for the stream"
          )
        }
        ControlItemView(
          icon: .epglist,
          note: .contentToggle,
          obj: ContentToggle.epglist,
          hint: "Show programmes for all streams"
        )
//        ControlItemView(
//          icon: .activityepg,
//          note: .contentToggle,
//          obj: ContentToggle.activityepg,
//          hint: "Show programme for recently opened streams"
//        )
      }
    }
  }

  struct PlayerControlsView: View {
    @ObservedObject var player = Player.instance

    func volumeStage(stage: Int) -> ContentToggleIcon {
      switch stage {
      case 1:
        return ContentToggleIcon.volumeStage1
      case 2: return ContentToggleIcon.volumeStage2
      case 3: return ContentToggleIcon.volumeStage3
      default:
        return ContentToggleIcon.isMutedOn
      }
    }

    var body: some View {
      ControlItemView(
        icon: player.isFullscreen
          ? .fullscreenOff : .fullscreenOn,
        note: Notification.Name.toggleFullscreen,
        obj: nil,
        hint: "Exit fullscreen"
      )
      ControlItemView(
        icon: player.isMuted
          ? ContentToggleIcon.isMutedOn : volumeStage(stage: player.volumeStage),
        note: Notification.Name.toggleAudio,
        hint: "Toggle audio"
      )
      if !player.isFullscreen {
        ControlItemView(
          icon: player.onTop ? .onTopOn : .onTopOff,
          note: Notification.Name.toggleOnTop,
          hint: "Toggle Always on top"
        )
      }

    }
  }

  struct StreamControlsView: View {
    @ObservedObject var ticker = LivescoreStorage.events

    var body: some View {
      ControlItemView(
        icon: .schedule,
        note: Notification.Name.contentToggle,
        obj: ContentToggle.schedule,
        hint: "TheSportsDb Schedule"
      )
      ControlItemView(
        icon: .livescores,
        note: Notification.Name.contentToggle,
        obj: ContentToggle.livescores,
        hint: "Livescores"
      )
      if ticker.tickerAvailable {
        ControlItemView(
          icon: .livescoreticler,
          note: Notification.Name.contentToggle,
          obj: ContentToggle.livescoresticker,
          hint: "Livescore Ticker"
        )
      }
      ControlItemView(
        icon: .search,
        note: Notification.Name.contentToggle,
        obj: ContentToggle.search,
        hint: "Search for whatever"
      )
      ControlItemView(
        icon: .bookmark,
        note: Notification.Name.contentToggle,
        obj: ContentToggle.bookmarks,
        hint: "Open bookmarks"
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
            guard player.controlsState != .always else {
              return
            }
            guard ToggleViews.hideControls.contains(self.player.contentToggle ?? .none) == false else {
              player.controlsState = .hidden
              return
            }
            player.controlsState = hover ? .hovered : .visible
          })
          .background(player.controlsState == .always ? .clear : Theme.Color.Background.controls)
          .cornerRadius(10)
          Spacer()
        }
        .background(
          player.controlsState == .always
            ? Theme.Color.Background.header
            : .linearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom)
        )
        .padding()
        if player.controlsState == .always {
          Spacer()
        }
      }
    }
  }
}
