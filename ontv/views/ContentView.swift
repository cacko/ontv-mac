//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import AppKit
import Defaults
import Preferences
import SwiftUI

enum ContentToggle {
  case guide, category, epglist, search, title, loading, controls, errror, activityepg, bookmarks,
    metadata, schedule, livescores, livescoresticker
}

struct ContentView: View {
  @ObservedObject var player = Player.instance
  @ObservedObject var api = API.Adapter
  @State private var hasBorder = false

  let showSearch = Binding<Bool>(
    get: {
      Player.instance.contentToggle == .search
    },
    set: { _ in
    }
  )

  func onVideoDblClick() {
    NotificationCenter.default.post(name: Notification.Name.fullscreen, object: nil)
  }

  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .center) {
        VideoViewRep()
          .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
          .aspectRatio(player.size.aspectSize, contentMode: .fill)
          .opacity(player.display ? 1 : 0)
          .onHover { over in
            hasBorder = over
          }
          .sheet(isPresented: showSearch) {
            SearchView()
              .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
              .cornerRadius(player.isFullscreen ? 0 : 5)
          }
        if [PlayerState.opening, PlayerState.buffering].contains(player.state) {
          LoadingView()
        }
        if player.state == .error || api.state == .error || player.state == .retry {
          ErrorView()
        }
        if api.loading != .loaded {
          ApiLoadingView()
        }
        ToggleView()
      }.border(.clear, width: !hasBorder || player.isFullscreen ? 0 : 5)
        .cornerRadius(player.isFullscreen ? 0 : 5)
        .onTapGesture(perform: {
          if [ContentToggle.guide, ContentToggle.category].contains(player.contentToggle) {
            NotificationCenter.default.post(name: .onTap, object: nil)
          }
        })
    }
  }
}
