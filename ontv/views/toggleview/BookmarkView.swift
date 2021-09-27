//
//  BookmarkView.swift
//  BookmarkView
//
//  Created by Alex on 01/10/2021.
//

import Foundation
import Kingfisher
import SwiftUI

extension ToggleViews {
  struct BookmarkView: View {
    @ObservedObject var player = Player.instance
    @ObservedObject var quickStreams = Provider.Stream.QuickStreams

    func bookmark(_ s: QuickStream) {
      Task.init {
        do {
          try await quickStreams.bookmark(s)
          NotificationCenter.default.post(name: .updatebookmarks, object: nil)
          player.contentToggle = .bookmarks
        }
        catch let error {
          logger.error("\(error.localizedDescription)")
        }

      }
    }

    var body: some View {
      VStack {
        Spacer()
        VStack {
          Text("Select slot")
            .font(Theme.Font.Bookmark.title)
            .textCase(.uppercase)
          HStack {
            Spacer()
            ForEach(quickStreams.streams, id: \.idx) { qs in
              Button(action: { bookmark(qs) }) {
                ZStack {
                  Text(String(qs.idx))
                    .foregroundColor(qs.isValid ? .gray : .primary)
                  if let icon = qs.icon {
                    KFImage(icon)
                      .cacheOriginalImage()
                      .setProcessor(
                        DownsamplingImageProcessor(
                          size: .init(width: 80, height: 40)
                        )
                      ).opacity(0.5)
                  }
                }
                .padding()
              }.buttonStyle(CustomButtonStyle(Theme.Font.Bookmark.button)).cornerRadius(10)
            }
            Spacer()
          }
        }.padding()
          .background(Theme.Color.Background.header)

        Spacer()
      }
    }
  }

}
