//
//  AbstractPlayer.swift
//  craptv
//
//  Created by Alex on 23/10/2021.
//

import Defaults
import Foundation

class AbstractPlayer: NSObject, PlayerVendorProtocol {
  typealias PlayerType = AbstractPlayer
  
  class var icon: String {
    ""
  }
  
  class var hint: String {
    ""
  }
  
  class var id: PlayVendor {
    .unknown
  }
  
  var volume: Float {
    get {
      fatalError()
    }
    set {
      fatalError()
    }
  }

  var isMuted: Bool {
    get {
      fatalError()
    }
    set {
      fatalError()
    }
  }

  required init(
    _ controller: Player
  ) {
    controller.icon = Self.icon
    controller.hint = Self.hint
    super.init()
  }

  func initView(_ view: VideoView) {
    fatalError("Not implemented")
  }

  func deInitView() {
    fatalError()
  }

  func sizeView(_ newSize: NSSize) {
    
  }

  func play(_ stream: Stream) {
    fatalError("Not implemented")
  }

  func stop() {
    fatalError("Not implemented")
  }

}
