//
//  Providers.swift
//  craptv
//
//  Created by Alex on 22/10/2021.
//

import CoreStore
import Foundation
import SwiftUI

protocol StorageProviderProtocol: ObservableObject {

  associatedtype EntityType: CoreStoreObject

  var list: ListPublisher<EntityType> { get set }
  var selected: ObjectPublisher<EntityType>! { get set }
  var selectedId: Int { get set }
  var query: Where<EntityType> { get set }
  var order: OrderBy<EntityType> { get set }
  var search: String { get set }
  var timer: DispatchSourceTimer! { get set }

  func selectNext() throws
  func selectPrevious() throws
  func onChangeStream(stream: Stream)
  func onNavigate(_ notitication: Notification) -> Void
}

enum Provider {
  enum Stream {}
  enum Actiity {}
  enum EPG {}

  struct Error: CustomNSError, Identifiable, Equatable {
    var id: Errors

    enum Errors {
      case outOfBounds
      case unexpected
    }

    //    let kind: Errors
    let msg: String
  }
}
