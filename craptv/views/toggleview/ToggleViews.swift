//
//  ToggleViews.swift
//  craptv
//
//  Created by Alex on 25/10/2021.
//

import Foundation
import SwiftUI

enum ToggleViews {

}

struct ToggleView: View {

    @ObservedObject var player = Player.instance

    var body: some View {
        GeometryReader { geo in

            ZStack {
                if player.contentToggle == .title {
                    ToggleViews.TitleView()
                }
                if [.epglist, .activityepg].contains(player.contentToggle) {
                    ToggleViews.EPGContentView()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .background(.black.opacity(0.8))
                        .cornerRadius(player.isFullscreen ? 0 : 5)
                }
                if player.contentToggle == .guide {
                    HStack {
                        Spacer()
                        ToggleViews.EPGView()
                            .frame(width: geo.size.width * 0.5, height: geo.size.height)
                            .background(.black.opacity(0.8))
                    }
                }
                if player.contentToggle == .category {
                    HStack {
                        ToggleViews.CategoryView()
                            .frame(width: geo.size.width * 0.5, height: geo.size.height)
                            .background(.black.opacity(0.8))
                        Spacer()
                    }
                }
                if player.contentToggle == .metadata {
                    ToggleViews.MetadataView()
                }
                if player.showControls {
                    ToggleViews.ControlsView()

                }
                if player.contentToggle == .bookmarks {
                    ToggleViews.BookmarkView()
                }
            }
        }
    }

}
