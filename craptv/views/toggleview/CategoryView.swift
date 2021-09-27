import AppKit
import CoreStore
import Kingfisher
import SwiftUI

extension ToggleViews {
  struct CategoryView: View {

    struct CategoryRow: View {
      var stream: ObjectPublisher<Stream>

      func openStream() {
        NotificationCenter.default.post(name: .selectStream, object: stream.object)
      }

      var body: some View {
        Button(action: { openStream() }) {
          HStack(alignment: .top) {
            StreamTitleView.TitleView(stream.icon!) {
              Text(stream.title!)
                .font(Theme.Font.programme)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
            }
            Spacer()
          }.padding()
        }
        .buttonStyle(ListButtonStyle())
      }
    }

    @ObservedObject var categoryProvider = StreamStorage.category

    @ObservedObject var player = Player.instance

    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    var body: some View {
      VStack(alignment: .trailing) {
        HStack {
          Spacer()
          Text(player.category?.title ?? "streams")
            .font(Theme.Font.title)
            .lineLimit(1)
            .textCase(.uppercase)
            .opacity(1)
            .padding()
        }.background(Theme.Color.Background.header)
        ScrollViewReader { proxy in
          ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
              ListReader(categoryProvider.list) { snapshot in
                ForEach(objectIn: snapshot) { stream in
                  CategoryRow(stream: stream)
                    .id(stream.id)
                    .hoverAction()
                    .listHighlight(
                      selectedId: $categoryProvider.selectedId,
                      itemId: stream.id!,
                      highlightPlaying: true
                    )
                }
              }.navigate(proxy: proxy, id: $categoryProvider.selectedId)
            }
          }
        }
      }
    }
  }
}
