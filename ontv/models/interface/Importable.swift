//
//  Importable.swift
//  Importable
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

protocol ImportableModel {

  associatedtype EntityType: CoreStoreObject

  static func fetch(
    url: URL,
    completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
  ) async throws

  static func doImport(
    json: [[String: Any]],
    completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
  ) async throws

  static var clearQuery: Where<EntityType> { get set }
  static var currentIds: [String] { get set }

  static func asInt64(data: [String: Any], key: String) -> Int64
  static func asString(data: [String: Any], key: String) -> String
  static func asDate(data: [String: Any], key: String) -> Date
  static func asStringFromNumberList(data: [String: Any], key: String) -> String
  static func asStringFromStringList(data: [String: Any], key: String) -> String
  static func asInt(data: [String: Any], key: String) -> Int
  static func asBool(data: [String: Any], key: String) -> Bool
  static func clearData() async throws -> Void
}

extension ImportableModel {

  typealias UniqueIDType = String

  static var uniqueIDKeyPath: String {
    "id"
  }

  static var clearQuery: Where<EntityType> {
    get {
      return Where<EntityType>(NSPredicate(format: "NONE id IN %@", currentIds))
    }
    set {}
  }

  static func fetch(
    url: URL,
    completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
  ) async throws {
    do {
      let json = try await API.Adapter.fetchData(url: url)
      self.currentIds = []
      try await doImport(json: json, completion: completion)
    }
    catch let error {
      DispatchQueue.main.async {
        API.Adapter.loading = .loaded
        API.Adapter.error = API.Exception.httpError("\(error.localizedDescription)")
      }
    }
  }

  static func asInt64(data: [String: Any], key: String) -> Int64 {
    if let n = data[key] as? Int64 {
      return n
    }
    return (data[key] as? NSString ?? "").longLongValue
  }

  static func asString(data: [String: Any], key: String) -> String {
    data[key] as? String ?? ""
  }

  static func asDate(data: [String: Any], key: String) -> Date {
    do {
      return try Date(data[key] as? String ?? "", strategy: .iso8601)
    }
    catch {
      return Date(timeIntervalSince1970: 0)
    }
  }

  static func asStringFromNumberList(data: [String: Any], key: String) -> String {
    (data[key] as! [NSNumber]).map { String(describing: $0) }.joined(
      separator: ","
    )
  }

  static func asStringFromStringList(data: [String: Any], key: String) -> String {
    (data[key] as! [String]).joined(separator: ",")
  }

  static func asInt(data: [String: Any], key: String) -> Int {
    if let n = data[key] as? Int {
      return n
    }
    return (data[key] as? NSString ?? "").integerValue
  }

  static func asBool(data: [String: Any], key: String) -> Bool {
    (data[key] as? String ?? "0") != "0"
  }

  static func clearData() async throws {
    CoreStoreDefaults.dataStack.perform(
      asynchronous: { transaction -> Void in
        try transaction.deleteAll(
          From<EntityType>(),
          clearQuery
        )
      },
      completion: { _ in }
    )

  }

  static func clear() {
    do {
      try CoreStoreDefaults.dataStack.perform(
        synchronous: { transaction -> Void in
          try transaction.deleteAll(
            From<EntityType>(),
            Where<EntityType>(NSPredicate(value: true))
          )
        }
      )
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }
}
