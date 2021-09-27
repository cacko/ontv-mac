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
                } catch let error {
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
                                    Text(String(qs.idx)).padding().opacity(qs.isValid ? 0.5 : 1)
                                    if let icon = qs.icon {
                                        KFImage(icon)
                                            .cacheOriginalImage()
                                            .setProcessor(
                                                DownsamplingImageProcessor(
                                                    size: .init(width: 80, height: 40))
                                            )
                                    }
                                }
                            }.buttonStyle(CustomButtonStyle(Theme.Font.Bookmark.button))
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
