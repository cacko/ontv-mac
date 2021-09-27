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
  class Schedule: CoreStoreObject, AbstractEntity, LazyStreams, ImportableObject, ImportableModel {
    class var primaryKey: String {
      "name"
    }

    @Field.Stored("name")
    var name: String = ""

    @Field.Stored("timestamp")
    var timestamp = Date()

    @Field.Stored("channels")
    var channels: String = ""

    @Field.Stored("streams")
    var streams: String = ""

    var id: Int {
      var hasher = Hasher()
      hasher.combine(self.name)
      hasher.combine("\(self.channels).\(self.streams)")
      return hasher.finalize()
    }

    class func shouldInsert(
      from source: ImportSource,
      in transaction: BaseDataTransaction
    ) -> Bool {
      if let streams = source["tvchannels"] as? [NSNumber] {
        return streams.count > 0
      }
      return false
    }

    func didInsert(from data: [String: Any], in transaction: BaseDataTransaction) throws {
      name = (data["name"] as? String ?? "")
      channels = (data["channels"] as! [String]).joined(separator: ",")
      streams = (data["tvchannels"] as! [NSNumber]).map { String(describing: $0) }.joined(
        separator: ","
      )
      timestamp = try Date(data["time"] as? String ?? "", strategy: .iso8601)
    }

    class func _import(
      json: Data,
      completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
    ) async throws {
      let data =
        try
        (JSONSerialization.jsonObject(with: json, options: [.mutableContainers]) as! [[String: Any]])
      dataStack.perform(
        asynchronous: { transaction -> Void in
          let _ = try transaction.importObjects(
            Into<Schedule>(),
            sourceArray: data
          )
        },
        completion: { r in completion(r) }
      )
    }

    func fetchStreams() async -> [LazyStream] {
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

    var expiresIn = TimeInterval(60 * 60 * 2 + 60 * 15)

    var startTime: Date {
      timestamp
    }

    var title: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      return "\(formatter.string(from: timestamp)) - \(name)"
    }

    var hasExpired: Bool {
      return Date().timeIntervalSince(startTime) > expiresIn
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
      !isSameDay(date1: Date(), date2: Defaults[.scheduleUpdated])
    }
  }
}
