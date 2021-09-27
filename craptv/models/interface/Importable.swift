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

  static func _import(
    json: Data,
    completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
  ) async throws

  static func clearData()

}

extension ImportableModel {
  static func fetch(
    url: URL,
    completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
  ) async throws {
    do {
      let json = try await API.Adapter.fetchData(url: url)
      Self.clearData()
      try await _import(json: json, completion: completion)
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }

  static func clearData() {
    do {
      try CoreStoreDefaults.dataStack.perform(
        synchronous: { transaction -> Void in
          try transaction.deleteAll(
            From<EntityType>()
          )
        }
      )
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }

}
