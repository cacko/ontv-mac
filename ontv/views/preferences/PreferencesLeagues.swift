//
//  Preferences.swift
//  Preferences
//
//  Created by Alex on 21/09/2021.
//

import CoreStore
import Defaults
import Preferences
import SwiftUI

extension PreferencesView {
  struct Leagues: View {
    @Default(.liveScoreLeagues) var leagues
    private var leagueProvider = LeagueStorage.list

    private let contentWidth: Double = 450.0
    private let padding: Double = 15

    func isSelected(_ id: Int64) -> Binding<Bool> {
      Binding(
        get: {
          leagues.contains(id)
        },
        set: { state in
          if state {
            leagues.insert(id)
          }
          else {
            leagues.remove(id)
          }
        }
      )
    }

    var body: some View {
      Preferences.Container(contentWidth: contentWidth) {
        Preferences.Section(title: "") {
          VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
              ScrollingView {
                ListReader(leagueProvider.list) { snapshot in
                  ForEach(objectIn: snapshot) { league in
                    Toggle(league.$league_name!, isOn: isSelected(league.$league_id!))
                  }
                }
              }
            }
          }
        }
      }.frame(width: contentWidth, height: 500, alignment: .leading)
    }
  }

}
