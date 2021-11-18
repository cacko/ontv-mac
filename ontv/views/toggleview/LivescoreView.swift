import AppKit
import CoreStore
import Kingfisher
import SwiftUI

extension ToggleViews {
  struct LivescoreView: View {

    struct TitleTextView: View {
      var text: String
      var body: some View {
        Text(text)
          .font(Theme.Font.scheduleHeader)
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

    struct TeamView: View {

      var team: Schedule.Team

      var body: some View {
        HStack {
          BadgeView(icon: team.icon)
          TitleTextView(text: team.id)
          Spacer()
        }
      }
    }

    struct ScoreView: View {

      var score: Int

      var body: some View {
        VStack(alignment: .center, spacing: 0) {
          Text(score.score)
            .font(Theme.Font.score)
            .foregroundColor(Theme.Color.Font.score)
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
        HStack {
          VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Text(livescore?.$startTime ?? "")
              .rotationEffect(.degrees(-90))
              .lineLimit(1)
              .fixedSize()
              .font(Theme.Font.channel)
            Spacer()
          }.frame(width: 30, alignment: .center)
          VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 5) {
              TeamView(team: homeTeam)
              Spacer()
              ScoreView(score: livescore!.$home_score)
            }
            HStack(alignment: .center, spacing: 5) {
              TeamView(team: awayTeam)
              Spacer()
              ScoreView(score: livescore!.$away_score)
            }
          }
        }
      }
    }

    @ObservedObject var liverscoreProvider = LivescoreStorage.events
    @ObservedObject var player = Player.instance

    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    func onTapItem(_ item: ObjectPublisher<Livescore>) {
      print(item)
    }

    var body: some View {
      VStack(alignment: .trailing) {
        ContentHeaderView(title: "Livescores", icon: ContentToggleIcon.livescores)
        ScrollingView {
          ListReader(liverscoreProvider.list) { snapshot in
            ForEach(objectIn: snapshot) { livescore in
              if livescore.$inPlay! || livescore.$status == LivescoreStatus.fulltime {
                LazyVStack(alignment: .leading, spacing: 0) {
                  LivescoreItem(livescore)

                }
                .padding()
                .hoverAction()
                .pressAction {
                  onTapItem(livescore)
                }
                .background(Theme.Color.Background.header)
              }
            }
          }
        }.onAppear {
          liverscoreProvider.active = true
        }.onDisappear(perform: {
          liverscoreProvider.active = false
        })
      }
    }
  }
}
