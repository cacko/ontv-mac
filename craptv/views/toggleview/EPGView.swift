import AppKit
import CoreStore
import SwiftUI

struct EPGRow: View {
  var epg: ObjectPublisher<EPG>
  var proxy: ScrollViewProxy
  var color: Color = .white

  init(
    item: ObjectPublisher<EPG>,
    proxy: ScrollViewProxy
  ) {
    epg = item
    self.proxy = proxy
    color = item.isLive! ? Theme.Color.State.live : Theme.Color.State.off
  }

  var body: some View {
    HStack(alignment: .center, spacing: 10) {
      HStack {
        Spacer()
        VStack(alignment: .trailing) {
          Text(epg.title!)
            .font(Theme.Font.programme)
            .lineLimit(3)
            .multilineTextAlignment(.trailing)
          Text(epg.desc!)
            .font(Theme.Font.desc)
            .multilineTextAlignment(.trailing)
        }
      }
      Text(epg.showTime!)
        .rotationEffect(.degrees(90))
        .font(Theme.Font.searchTime)
        .foregroundColor(.mint.opacity(0.8))
    }.padding().background(color)
  }
}

extension ToggleViews {
  struct EPGView: View {
    @ObservedObject var epgStorage = EPGStorage.guide

    @ObservedObject var player = Player.instance

    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    func scrollToLive(proxy: ScrollViewProxy, item: ObjectPublisher<EPG>?) {
      //        if item != nil {
      //            proxy.scrollTo(item.id, anchor: .center)
      //        }
    }

    var body: some View {
      ZStack(alignment: .top) {
        VStack(alignment: .leading) {
          HStack {
            Spacer()
            if let stream = player.stream {
              StreamTitleView.IconView(stream.icon)
              Text("\(stream.title)")
                .font(Theme.Font.title)
                .lineLimit(1)
                .textCase(.uppercase)
                .fixedSize(horizontal: false, vertical: false)
                .opacity(1)
                .padding()
            }
          }
          .background(Theme.Color.Background.header)
        }
        if epgStorage.state == .notavail {
          VStack(alignment: .trailing) {
            Spacer()
            Text("EPG is not available").font(Theme.Font.result)
            Spacer()
          }
        }
        ScrollViewReader { proxy in
          ScrollView {
            LazyVStack {
              if epgStorage.state != .notavail {
                ListReader(epgStorage.list) { listSnapshot in
                  ForEach(objectIn: listSnapshot) { epg in
                    EPGRow(item: epg, proxy: proxy)
                      .id(epg.id).hoverAction()
                  }
                }
              }
            }
          }.onAppear(perform: {
            epgStorage.search = player.stream!.epg_channel_id
          })
          .onChange(
            of: player.stream.epg_channel_id,
            perform: { newid in epgStorage.search = newid }
          )

        }.padding(EdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 0))
      }
    }
  }

}
