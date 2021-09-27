//
//  MetadataView.swift
//  craptv
//
//  Created by Alex on 25/10/2021.
//

import Foundation
import SwiftUI

extension ToggleViews {

  struct MetadataView: View {

    struct SwitchVendor: View {

      var vendor: PlayerVendorProtocol.Type
      @ObservedObject var player = Player.instance

      func onClick() {
        NotificationCenter.default.post(name: .vendorChange, object: vendor.id)
      }

      var body: some View {
        Button(action: {
          onClick()
        }) {
          Image(vendor.icon)
            .resizable()
            .frame(
              width: NSFont.systemFontSize * 2,
              height: NSFont.systemFontSize * 2,
              alignment: .center
            ).grayscale(0.6)
        }
        .buttonStyle(.plain)
        .hoverAction(mode: [.cursor])
      }
    }

    @ObservedObject var player = Player.instance
    var body: some View {
      if player.metadataState == .loaded {
        VStack {
          Spacer()
          HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
              VStack {
                HStack {
                  Text("Video")
                    .font(Theme.Font.programme)
                    .textCase(.uppercase)
                  SwitchVendor(vendor: PlayerAV.self)
                  SwitchVendor(vendor: PlayerVLC.self)
                }
                Text(
                  "\(player.metadata.video.codec) \(player.metadata.video.resolution.toResolution())"
                )
                .font(Theme.Font.title)
              }
              VStack {
                Text("Audio")
                  .font(Theme.Font.programme)
                  .textCase(.uppercase)
                  .lineLimit(1)
                Text(
                  "\(player.metadata.audio.codec) \(player.metadata.audio.rate) / \(player.metadata.audio.channels)"
                )
                .font(Theme.Font.title)
              }
            }
            .padding()
            .background(Theme.Color.Background.metadata)
            .cornerRadius(10)
            Spacer()
          }
          Spacer()
        }
      }
    }
  }
}
