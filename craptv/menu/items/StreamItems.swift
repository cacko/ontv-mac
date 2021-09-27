//
//  Stream.swift
//  Stream
//
//  Created by Alex on 03/10/2021.
//

import Foundation

class StreamItem: NoModifierItem, Streamable {
  var stream_id: Int64

  required init(
    action: Selector?,
    keyEquivalent: String,
    stream: Stream
  ) {
    self.stream_id = stream.stream_id
    super.init(title: stream.title, action: action, keyEquivalent: keyEquivalent)
    self.isHidden = false
  }

  @available(*, unavailable)
  required init(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }
}

class QuickItem: NoModifierItem, Streamable {
  var stream_id: Int64

  required init(
    action: Selector?,
    keyEquivalent: String,
    quick: QuickStream
  ) throws {
    guard let stream = quick.stream else {
      throw PlayerError(id: .unexpected, msg: "u rekata")
    }
    self.stream_id = stream.stream_id
    super.init(title: stream.title, action: action, keyEquivalent: keyEquivalent)
    self.isHidden = !quick.isValid
  }

  @available(*, unavailable)
  required init(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }
}
