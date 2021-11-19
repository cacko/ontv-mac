//
//  LivescoreTicker.swift
//  ontv
//
//  Created by Alex on 19/11/2021.
//

import Foundation

extension Livescore {
  
  
  func toggleTicker() async throws {
    Livescore.dataStack.perform(
      asynchronous: { (transaction) -> Void in
        
        guard let livescore = transaction.fetchExisting(self) else {
          return
        }
        
        livescore.in_ticker = (livescore.in_ticker - 1) * -1
        
      }, completion: { _ in }
    )
  }
  
}
