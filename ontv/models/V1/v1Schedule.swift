//
//  Schedule.swift
//  Schedule
//
//  Created by Alex on 10/10/2021.
//

import CoreStore
import Defaults
import Foundation

extension V1 {
  class Schedule: CoreStoreObject, AbstractEntity, LazyStreams, ImportableUniqueObject,
    ImportableModel
  {

    typealias EntityType = Schedule

    static let expiresIn = TimeInterval(60 * 60 * 2 + 60 * 15)

    static var currentIds: [String] = [""]

    class var primaryKey: String {
      "name"
    }

    static var clearQuery: Where<EntityType> {
      get {
        let startOfDate = Calendar.current.startOfDay(for: Date())
        return Where<EntityType>(NSPredicate(format: "timestamp < %@", startOfDate as NSDate))
      }
      set {}
    }

    @Field.Stored("id")
    var id: String = ""

    @Field.Stored("event_id")
    var event_id: Int = 0

    @Field.Stored("name")
    var name: String = ""

    @Field.Stored("timestamp")
    var timestamp = Date()

    @Field.Stored("channels")
    var channels: String = ""

    @Field.Stored("streams")
    var streams: String = ""

    @Field.Stored("home_team")
    var home_team: String = ""

    @Field.Stored("away_team")
    var away_team: String = ""

    @Field.Stored("sport")
    var sport: String = ""

    @Field.Stored("country")
    var country: String = ""

    @Field.Stored("season")
    var season: String = ""

    static func uniqueID(
      from source: [String: Any],
      in transaction: BaseDataTransaction
    ) throws -> String? {
      return self.asString(data: source, key: uniqueIDKeyPath)
    }

    func loadData(from source: [String: Any]) {
      id = Self.asString(data: source, key: "id")
      event_id = Self.asInt(data: source, key: "event_id")
      name = Self.asString(data: source, key: "name")
      channels = Self.asStringFromStringList(data: source, key: "channels")
      streams = Self.asStringFromNumberList(data: source, key: "tvchannels")
      timestamp = Self.asDate(data: source, key: "time")
      home_team = Self.asString(data: source, key: "home_team")
      away_team = Self.asString(data: source, key: "away_team")
      sport = Self.asString(data: source, key: "sport")
      country = Self.asString(data: source, key: "country")
      season = Self.asString(data: source, key: "season")
    }

    func update(from source: [String: Any], in transaction: BaseDataTransaction) throws {
      self.loadData(from: source)
    }

    func didInsert(from data: [String: Any], in transaction: BaseDataTransaction) throws {
      self.loadData(from: data)
    }

    class func doImport(
      json: [[String: Any]],
      completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
    ) async throws {
      dataStack.perform(
        asynchronous: { transaction -> Void in
          let _ = try transaction.importUniqueObjects(
            Into<Schedule>(),
            sourceArray: json
          )
        },
        completion: { r in
          Task.init {

            try await Self.clearData()
            completion(r)
          }
        }
      )
    }

    var Streams: [LazyStream] {
      do {
        let ids = streams.split(separator: ",")
        let predicate = NSPredicate(format: "ANY stream_id in %@", ids)
        return try Self.dataStack.fetchAll(From<Stream>(), Where<Stream>(predicate), Stream.orderBy)
      }
      catch {
        logger.error("\(error.localizedDescription)")
      }
      return []
    }

    var startTime: Date {
      timestamp
    }

    var title: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      return "\(formatter.string(from: timestamp)) - \(name)"
    }

    var hasExpired: Bool {
      let expireDate = self.startTime.addingTimeInterval(Self.expiresIn)
      return Date().timeIntervalSince(expireDate) < 0
    }

    class var orderBy: OrderBy<Schedule> {
      OrderBy([
        NSSortDescriptor(key: "timestamp", ascending: true),
        NSSortDescriptor(
          key: "name",
          ascending: true,
          selector: #selector(NSString.localizedStandardCompare)
        ),
      ])
    }

    static func needUpdate() -> Bool {
      !Date().isSameDay(Defaults[.scheduleUpdated])
    }
  }
}
