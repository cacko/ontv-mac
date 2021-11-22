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

    private let contentWidth: Double = 550.0
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
        Preferences.Section(title: "Leagues", verticalAlignment: .top) {
          VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
              ScrollingView(
                direction: .vertical,
                columns: Array(repeating: .init(.adaptive(minimum: 180)), count: 2),
                spacing: 5
              ) {
                ListReader(leagueProvider.list) { snapshot in
                  ForEach(objectIn: snapshot) { league in
                    Toggle(isOn: isSelected(league.$league_id!)) {
                      Text(league.$league_name!)
                        .frame(maxWidth: 180, alignment: .leading)
                    }
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