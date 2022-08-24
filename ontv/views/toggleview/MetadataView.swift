////
////  MetadataView.swift
////  craptv
////
////  Created by Alex on 25/10/2021.
////
//
import Foundation
import SwiftUI

extension ToggleViews {

  struct MetadataView: View {

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
                }
                Text(
                  "\(player.metadata.video.codec) \(player.metadata.video.resolution.resolution)"
                )
                .font(Theme.Font.title)
              }
              VStack {
                Text("Audio")
                  .font(Theme.Font.programme)
                  .textCase(.uppercase)
                  .lineLimit(1)
                Text(
                  "\(player.metadata.audio.codec) \(player.metadata.audio.bitrate)"
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
