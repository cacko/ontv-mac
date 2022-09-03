//
//  Importable.swift
//  Importable
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation


struct ImportError: Error, Identifiable, Equatable {
  var id: Errors
  
  enum Errors {
    case unknown
    case date
  }
  
  //    let kind: Errors
  let msg: String
}


protocol ImportableModel {

  associatedtype EntityType: CoreStoreObject

  static func fetch(
    url: URL,
    completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
  ) async throws

  static func doImport(
    json: [[String: Any]],
    onComplete: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
  ) async throws

  static func asInt64(data: [String: Any], key: String) -> Int64
  static func asString(data: [String: Any], key: String) -> String
  static func asDate(data: [String: Any], key: String) -> Date
  static func asStringFromNumberList(data: [String: Any], key: String) -> String
  static func asStringFromStringList(data: [String: Any], key: String) -> String
  static func asInt(data: [String: Any], key: String) -> Int
  static func asBool(data: [String: Any], key: String) -> Bool


}

extension ImportableModel {

  typealias UniqueIDType = String

  static var uniqueIDKeyPath: String {
    "id"
  }

  static func fetch(
    url: URL,
    completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
  ) async throws {
    do {
      let json = try await API.Adapter.fetchData(url: url)
      try await doImport(json: json, onComplete: completion)
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

  static func asDouble(data: [String: Any], key: String) -> Double {
    if let n = data[key] as? Double {
      return n
    }
    return (data[key] as? NSString ?? "").doubleValue
  }

  static func asString(data: [String: Any], key: String) -> String {
    data[key] as? String ?? ""
  }
  
  static func numberAsString(data: [String: Any], key: String) -> String {
    String(describing: data[key])
  }

  static func asDate(data: [String: Any], key: String) -> Date {
    do {
      let calc = try Date(data[key] as! String, strategy: .iso8601)
      guard let res = calc as Date? else {
        throw ImportError(id:.date, msg: "kura mi yanko")
      }
      return res
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
}
