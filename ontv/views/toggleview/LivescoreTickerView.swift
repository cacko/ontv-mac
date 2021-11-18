import AppKit
import CoreStore
import Defaults
import Kingfisher
import SwiftUI

extension ToggleViews {
  struct LivescoreTickerView: View {

    struct TitleTextView: View {
      var text: String
      var body: some View {
        Text(text)
          .font(Theme.Font.Ticker.team)
          .lineSpacing(30)
          .lineLimit(1)
          .textCase(.uppercase)
          .truncationMode(.tail)
          .multilineTextAlignment(.leading)
      }
    }

    struct BadgeView: View {
      var icon: Icon
      var size: CGFloat! = 30.0
      var body: some View {
        if icon.hasIcon {
          KFImage(icon.url)
            .cacheOriginalImage()
            .setProcessor(
              DownsamplingImageProcessor(size: .init(width: size, height: size))
            ).onSuccess { _ in
              icon.hasIcon = true
            }.onFailure { _ in
              icon.hasIcon = false
            }.resizable()
            .frame(width: icon.hasIcon ? size : 0, height: size, alignment: .center)
        }
      }
    }

    struct LivescoreItem: View {
      @ObjectState var livescore: ObjectSnapshot<Livescore>?
      private var homeTeam: Schedule.Team!
      private var awayTeam: Schedule.Team!

      init(
        _ objectPublisher: ObjectPublisher<Livescore>
      ) {
        self._livescore = .init(objectPublisher)
        self.homeTeam = Schedule.Team(id: objectPublisher.home_team ?? "")
        self.awayTeam = Schedule.Team(id: objectPublisher.away_team ?? "")
      }

      var body: some View {
        if let ls = self.livescore {
          //          if ls.$inPlay {
          HStack(alignment: .center, spacing: 3) {
            BadgeView(icon: homeTeam.icon)
            TitleTextView(text: homeTeam.id)
            Text(ls.$home_score.score)
              .font(Theme.Font.Ticker.score)
              .foregroundColor(Theme.Color.Font.score)
            Text(ls.$viewStatus)
              .textCase(.uppercase)
              .font(Theme.Font.Ticker.hint)
            Text(ls.$away_score.score)
              .font(Theme.Font.Ticker.score)
              .foregroundColor(Theme.Color.Font.score)
            TitleTextView(text: awayTeam.id)
            BadgeView(icon: awayTeam.icon)
          }.frame(height: 40, alignment: .center)
            .padding()
        }
        //        }
      }
    }

    @ObservedObject var liverscoreProvider = LivescoreStorage.ticker
    @ObservedObject var player = Player.instance

    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    func onScrollTo(to: String, proxy: ScrollViewProxy) {
      withAnimation {
        proxy.scrollTo(to, anchor: .leading)
      }
    }

    var body: some View {
      VStack {
        HStack(alignment: .center) {
          Spacer()
          ScrollViewReader { proxy in
            ScrollingView(.horizontal) {
              ListReader(liverscoreProvider.list) { snapshot in
                ForEach(objectIn: snapshot) { livescore in
                  LivescoreItem(livescore)
                    .id(livescore.id)
                    .onTapGesture(count: 2) {
                      guard var ticker = Defaults[.ticker] as [String]? else {
                        return
                      }
                      guard ticker.contains(livescore.id!) else {
                        return
                      }
                      ticker.removeAll { $0 == livescore.id }
                      Defaults[.ticker] = ticker
                    }.hoverAction()
                }
              }
            }
            .onReceive(
              liverscoreProvider.$scrollTo,
              perform: {
                value in onScrollTo(to: value, proxy: proxy)
              }
            )
          }
          .background(Theme.Color.Background.ticker)
          .frame(height: 50, alignment: .center)
          .onAppear { liverscoreProvider.active = true }
          .onDisappear { liverscoreProvider.active = false }
          Spacer()
        }
        Spacer()
      }
    }
  }
}
