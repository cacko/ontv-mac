//
//  Category.swift
//  Category
//
//  Created by Alex on 10/10/2021.
//

import CoreStore
import Foundation

extension V1 {
  class Category: CoreStoreObject, AbstractEntity, LazyStreams, ImportableObject, ImportableModel {

    typealias EntityType = Category

    @Field.Stored("category_id")
    var category_id: Int64 = 0

    @Field.Stored("parent_id")
    var parent_id: Int64 = 0

    @Field.Stored("category_name")
    var category_name: String = ""

    var id: Int {
      var hasher = Hasher()
      hasher.combine(self.category_id)
      hasher.combine("\(self.parent_id).\(self.category_name)")
      return hasher.finalize()
    }

    var title: String {
      self.category_name
    }

    var expiresIn: TimeInterval {
      TimeInterval(0)
    }

    var startTime: Date {
      Date()
    }

    var hasExpired: Bool {
      false
    }

    static var streamsCache: [String: [Stream]] = [:]

    class var primaryKey: String {
      "category_id"
    }

    func didInsert(from data: [String: Any], in transaction: BaseDataTransaction) throws {
      category_name = (data["category_name"] as? String ?? "")
      category_id = (data["category_id"] as! NSString).longLongValue
      parent_id = (data["parent_id"] as! NSString).longLongValue
    }

    class var orderBy: OrderBy<Category> {
      OrderBy([
        NSSortDescriptor(
          key: "category_name",
          ascending: true,
          selector: #selector(NSString.localizedStandardCompare)
        )
      ])
    }

    class func _import(
      json: Data,
      completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
    ) async throws {
      let data =
        try
        (JSONSerialization.jsonObject(with: json, options: [.mutableContainers])
        as! [[String: Any]])

      dataStack.perform(
        asynchronous: { transaction -> Void in
          let _ = try! transaction.importObjects(
            Into<Category>(),
            sourceArray: data
          )
        },
        completion: { r in completion(r) }
      )
    }

    func fetchStreams() async -> [LazyStream] {
      let key = String(category_id)

      if !Self.streamsCache.keys.contains(key) {
        let predicate = NSPredicate(format: "category_id = %@", key)
        Self.streamsCache[key] = Stream.find(Where<Stream>(predicate), Stream.orderBy)
      }
      return Self.streamsCache[key] ?? []
    }
  }
}
