//
//  History.swift
//  History
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation
import SwiftDate

extension V1 {
  class Livescore: CoreStoreObject, AbstractEntity, ImportableUniqueObject, ImportableModel {

    typealias EntityType = Livescore

    class var primaryKey: String {
      "event_id"
    }

    @Field.Stored("id")
    var id: String = ""

    @Field.Stored("event_id")
    var event_id: Int64 = 0

    @Field.Stored("sport")
    var sport: String = ""

    @Field.Stored("league_id")
    var league_id: Int64 = 0

    @Field.Stored("home_team_id")
    var home_team_id: Int64 = 0

    @Field.Stored("away_team_id")
    var away_team_id: Int64 = 0

    @Field.Stored("home_team")
    var home_team: String = ""

    @Field.Stored("away_team")
    var away_team: String = ""

    @Field.Stored("status")
    var status: String = ""

    @Field.Stored("home_score")
    var home_score: Int = 0

    @Field.Stored("away_score")
    var away_score: Int = 0

    @Field.Stored("start_time")
    var start_time: Date = Date(timeIntervalSince1970: 0)

    static var currentIds: [String] = [""]

    static func uniqueID(
      from source: [String: Any],
      in transaction: BaseDataTransaction
    ) throws -> String? {
      return Self.getId(from: source)
    }

    static func getId(from source: [String: Any]) -> String {
      let event_id = Self.asInt64(data: source, key: "idEvent")
      guard event_id == 0 else {
        return event_id.string
      }
      var hasher = Hasher()
      hasher.combine(Self.asString(data: source, key: "strHomeTeam"))
      hasher.combine(Self.asString(data: source, key: "strAwayTeam"))
      return hasher.finalize().string
    }

    func loadData(from source: [String: Any]) {
      id = Self.getId(from: source)
      event_id = Self.asInt64(data: source, key: "idEvent")
      league_id = Self.asInt64(data: source, key: "idLeague")
      home_team_id = Self.asInt64(data: source, key: "idHomeTeam")
      away_team_id = Self.asInt64(data: source, key: "idAwayTeam")
      sport = Self.asString(data: source, key: "strSport")
      home_team = Self.asString(data: source, key: "strHomeTeam")
      away_team = Self.asString(data: source, key: "strAwayTeam")
      home_score = Self.asInt(data: source, key: "intHomeScore")
      away_score = Self.asInt(data: source, key: "intAwayScore")
      status = Self.asString(data: source, key: "strStatus")
      start_time = Self.asDate(data: source, key: "startTime")
    }

    func update(from source: [String: Any], in transaction: BaseDataTransaction) throws {
      self.loadData(from: source)
      Self.currentIds.append(self.id)
    }

    func didInsert(from data: [String: Any], in transaction: BaseDataTransaction) throws {
      self.loadData(from: data)
      Self.currentIds.append(self.id)
    }

    class func doImport(
      json: [[String: Any]],
      completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
    ) async throws {
      dataStack.perform(
        asynchronous: { transaction -> Void in
          let _ = try transaction.importUniqueObjects(
            Into<Livescore>(),
            sourceArray: json
          )
        },
        completion: { r in completion(r) }
      )
    }

    @Field.Virtual(
      "viewStatus",
      customGetter: { (object, field) in
        let val = object.$status.value
        let isNotStarted = ["", "NS", "Not Started"].contains(val)
        if isNotStarted {
          return "vs"
        }
        if val ~= "^\\d+$" {
          return "\(val)'"
        }
        return val
      }
    )
    var viewStatus: String

    @Field.Virtual(
      "startTime",
      customGetter: { (object, field) in
        let val = object.$status.value
        let isNotStarted = ["", "NS", "Not Started", "PPD"].contains(val)
        if isNotStarted {
          return object.$start_time.value.HHMM
        }
        if val ~= "^\\d+$" {
          return "\(val)'"
        }
        return val
      }
    )
    var startTime: String

    @Field.Virtual(
      "inPlay",
      customGetter: { (object, field) in
        guard Date().isAfterDate(object.$start_time.value, granularity: Calendar.Component.minute)
        else {
          return false
        }
        return !["FT", "PPD"].contains(object.$status.value)
      }
    )
    var inPlay: Bool

    class var orderBy: OrderBy<Livescore> {
      OrderBy(
        .descending("start_time")
      )
    }
  }
}
