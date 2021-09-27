//
//  Stream.swift
//  Stream
//
//  Created by Alex on 26/09/2021.
//

import CoreStore
import Defaults
import SwiftUI

extension V1 {
  class Stream: CoreStoreObject, AbstractEntity, Reorderable, ImportableObject, ImportableModel,
    LazyStream, Streamable
  {
        
    typealias EntityType = Stream

    @Field.Stored("stream_id")
    var stream_id: Int64 = 0

    @Field.Stored("category_id")
    var category_id: Int64 = 0

    @Field.Stored("num")
    var num: Int64 = 0

    @Field.Stored("name")
    var name: String = ""

    @Field.Stored("stream_type")
    var stream_type: String = ""

    @Field.Stored("epg_channel_id")
    var epg_channel_id: String = ""

    @Field.Stored("stream_icon")
    var stream_icon: String = ""
    
    @Field.Stored("is_adult")
    var is_adult: Bool = false

    @Field.Relationship("activity", inverse: \.$stream)
    var activity: Activity?

    typealias ImportSource = [String: Any]

    class var primaryKey: String {
      "stream_id"
    }

    class var orderBy: OrderBy<Stream> {
      OrderBy([
        NSSortDescriptor(
          key: "name",
          ascending: true,
          selector: #selector(NSString.localizedStandardCompare)
        )
      ])
    }

    func didInsert(
      from data: [String: Any],
      in transaction: BaseDataTransaction
    )
      throws
    {
      num = data["num"] as? Int64 ?? 0
      stream_id = data["stream_id"] as? Int64 ?? 0
      name = (data["name"] as? String ?? "")
      category_id = (data["category_id"] as? NSString ?? "").longLongValue
      stream_type = (data["stream_type"] as? String ?? "")
      epg_channel_id = (data["epg_channel_id"] as? String ?? "")
      stream_icon = (data["stream_icon"] as? String ?? "")
      is_adult = (data["is_adult"] as? String ?? "0") != "0"
      if let stream_activity = try transaction.fetchOne(
        From<Activity>(),
        Where<Activity>("stream_id = %d", stream_id)
      ) {
        activity = stream_activity
      }
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
          let _ = try! transaction.importObjects(
            Into<Stream>(),
            sourceArray: data
          )
        },
        completion: { r in completion(r) }
      )
    }

    var orderElement: Int64 {
      stream_id
    }

    typealias OrderElement = Int64

    var id: Int {
      var hasher = Hasher()
      hasher.combine(self.stream_id)
      hasher.combine(self.stream_type)
      return hasher.finalize()
    }

    var title: String {
      name.withoutHtmlTags()
    }

    var url: URL {
      API.Endpoint.Stream(stream_id)
    }

    var icon: URL {
      API.Endpoint.Icon(id: stream_id, epg: epg_channel_id)
    }
    
    var isPlaying: Bool {
      Player.instance.stream.id == self.id
    }

    static func needUpdate() -> Bool {
      !isSameDay(date1: Date(), date2: Defaults[.scheduleUpdated])
    }

  }
}
