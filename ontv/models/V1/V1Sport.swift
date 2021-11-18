//
//  History.swift
//  History
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

extension V1 {
  class Sport: CoreStoreObject, AbstractEntity, ImportableUniqueObject, ImportableModel {

    typealias EntityType = Sport

    class var primaryKey: String {
      "id"
    }

    static var currentIds: [String] = [""]

    @Field.Stored("id")
    var id: String = ""

    @Field.Stored("sport")
    var sport: String = ""

    @Field.Stored("format")
    var format: String = ""

    @Field.Stored("sport_thumb")
    var sport_thumb: String = ""

    @Field.Stored("sport_icon")
    var sport_icon: String = ""

    @Field.Stored("sport_description")
    var sport_description: String = ""

    static func uniqueID(
      from source: [String: Any],
      in transaction: BaseDataTransaction
    ) throws -> String? {
      Self.asString(data: source, key: primaryKey)
    }

    func loadData(from source: [String: Any]) {
      id = Self.asString(data: source, key: "idSport")
      sport = Self.asString(data: source, key: "strSport")
      format = Self.asString(data: source, key: "strFormat")
      sport_thumb = Self.asString(data: source, key: "strSportThumb")
      sport_icon = Self.asString(data: source, key: "strSportIconGreen")
      sport_description = Self.asString(data: source, key: "strSportDescription")
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
          let _ = try! transaction.importUniqueObjects(
            Into<Sport>(),
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

    var icon: URL {
      API.Endpoint.SportIcon(id: id)
    }

    class var orderBy: OrderBy<Sport> {
      OrderBy(
        .ascending("id")
      )
    }
  }
}
