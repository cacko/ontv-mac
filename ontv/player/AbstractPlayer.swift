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

  var volume: Float {
    get { fatalError() }
    set { fatalError() }
  }

  var isMuted: Bool {
    get { fatalError() }
    set { fatalError() }
  }

  required init(
    _ controller: Player
  ) {
    super.init()
    DispatchQueue.main.async {
      NotificationCenter.default.post(name: .playerLoaded, object: nil)

    }

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
  
  func reconnect() {
    fatalError("Not implemented")
  }

  func stop() {
    fatalError("Not implemented")
  }

}
