//
//  Epg.swift
//  Epg
//
//  Created by Alex on 05/10/2021.
//

import CoreStore
import Defaults
import Foundation
import SwiftUI

extension V1 {
  class EPG: CoreStoreObject, AbstractEntity, ImportableObject, ImportableModel {
    
    class var primaryKey: String {
      "category_id"
    }

    @Field.Stored("channel")
    var channel: String = ""

    @Field.Stored("title")
    var title: String = ""

    @Field.Stored("start")
    var start = Date()

    @Field.Stored("stop")
    var stop = Date()

    @Field.Stored("desc")
    var desc: String = ""

    @Field.Relationship("activity")
    var activity: Activity?
    
    var id: Int {
      var hasher = Hasher()
      hasher.combine(self.channel)
      hasher.combine("\(self.title).\(self.start).\(self.stop)")
      return hasher.finalize()
    }
    
    func didInsert(from data: [String: Any], in transaction: BaseDataTransaction) throws {
      do {
        self.channel = (data["channel"] as? String ?? "")
        self.title = (data["title"] as? String ?? "")
        self.desc = (data["desc"] as? String ?? "")
        self.start = try Date(data["start"] as? String ?? "", strategy: .iso8601)
        self.stop = try Date(data["stop"] as? String ?? "", strategy: .iso8601)
      }
      catch let error {
        logger.error("\(error.localizedDescription)")
        throw error
      }
    }



    private static var activities: [Activity]!
    private static var activityChannels: [String]!

    private func getActivity(tr: BaseDataTransaction, channel: String) -> Activity? {
      if Self.activities == nil {
        do {
          Self.activities = try tr.fetchAll(From<Activity>())
          Self.activityChannels = Self.activities.map { $0.stream?.epg_channel_id ?? "" }
        }
        catch {
          Self.activities = []
        }

      }
      guard Self.activityChannels.contains(channel) else {
        return nil
      }
      return Self.activities.first { $0.stream?.epg_channel_id == channel }
    }

    class func _import(
      json: Data,
      completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
    ) async throws {
      let data =
        try
        (JSONSerialization.jsonObject(with: json, options: [.mutableContainers])
        as! [[String: Any]])
      return dataStack.perform(
        asynchronous: { transaction -> Void in
          self.activities = nil
          let _ = try! transaction.importObjects(
            Into<EPG>(),
            sourceArray: data
          )
          let now = Date()
          let stop = now.addingTimeInterval((60 * 60 * 25 * 2) * -1)
          try transaction.fetchAll(
            From<Activity>(),
            Where<Activity>("last_visit > %s", stop)
          ).forEach({ activity in
            if let obj = transaction.edit(activity) {
              if let stream_channel = obj.stream?.epg_channel_id {
                let predicates: [NSPredicate] = [
                  NSPredicate(format: "stop > %@", now as NSDate),
                  NSPredicate(format: "channel = %@", stream_channel),
                ]
                let query = Where<EPG>(
                  NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                )
                let order = OrderBy<EPG>(
                  .ascending("channel"),
                  .ascending("start"),
                  .ascending("title")
                )
                let epgs = try transaction.fetchAll(
                  From<EPG>().where(query).orderBy(order)
                )
                obj.epgs = Set(epgs)
              }
            }
          })
        },
        completion: { r in completion(r) }
      )
    }

    static func needUpdate() -> Bool {
      !isSameDay(date1: Date(), date2: Defaults[.epgUpdated])
    }

    var isLive: Bool {
      let now = Date()
      return start.compare(now) == .orderedAscending && stop.compare(now) == .orderedDescending
    }

    var isPlaying: Bool {
      Player.instance.stream == self.stream
    }

    class var orderBy: OrderBy<EPG> {
      OrderBy([
        NSSortDescriptor(key: "start", ascending: true),
        NSSortDescriptor(
          key: "title",
          ascending: true,
          selector: #selector(NSString.localizedStandardCompare)
        ),
      ])
    }

    private var _stream: Stream?

    var stream: Stream? {
      guard self._stream != nil else {
        if let obj = Stream.findOne(Where<Stream>("epg_channel_id = %s", self.channel)) {
          self._stream = obj
        }
        return self._stream
      }
      return self._stream
    }

    var showTime: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      return "\(formatter.string(from: start))\n\(formatter.string(from: stop))"
    }

    var startTime: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      return formatter.string(from: start)
    }
  }
}
