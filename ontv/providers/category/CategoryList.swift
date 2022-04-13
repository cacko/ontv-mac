//
//  StreamSearch.swift
//  craptv
//
//  Created by Alex on 29/10/2021.
//

import CoreStore
import Foundation
import SwiftDate
import SwiftUI
import Defaults

extension CategoryStorage {
  
  class List: NSObject, ObservableObject, StorageProvider
  {
    var state: ProviderState = .notavail
    
    var selected: ObjectPublisher<EntityType>!
    
    var active: Bool = false
    
    typealias EntityType = Category
    
    var list: ListPublisher<EntityType>
    
    var selectedId: String = ""
    
    var query: Where<EntityType>
    
    var order: OrderBy<EntityType> = EntityType.orderBy
    
    var search: String = ""
    
    
    func selectNext() throws {}
    
    func selectPrevious() throws {}
    
    func onNavigate(_ notitication: Notification) {}
    
    override init() {
      self.query =  Where<EntityType>(NSPredicate(value: true))
      self.list = Self.dataStack.publishList(
        From<EntityType>()
          .where(self.query)
          .orderBy(self.order)
      )
      super.init()
    }
  }
  
}
