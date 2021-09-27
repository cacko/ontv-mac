//
//  Audio.swift
//  Audio
//
//  Created by Alex on 03/10/2021.
//

import AppKit
import Foundation
import SwiftUI

enum Audio {
  enum Command {
    case volume_offset, volume_set
  }

  struct Parameter {
    var command: Command
    var value: Float
  }

  struct Result {
    var command: Command
    var value: Float
  }

}

protocol AudioItemProtocol {

}

class AudioMenuItem: NoModifierItem, AudioItemProtocol {

  let player = Player.instance

  override var isEnabled: Bool {
    get { player.vendor.features.contains(.volume) }
    set {}
  }

}

class AudioItem: AudioMenuItem {
  var parameter: Audio.Parameter

  init(
    title: String,
    action: Selector?,
    keyEquivalent: String,
    parameter: Audio.Parameter
  ) {
    self.parameter = parameter
    super.init(title: title, action: action, keyEquivalent: keyEquivalent)
  }

  @available(*, unavailable)
  required init(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }
}

class AudioLabelItem: AudioMenuItem {

  let command: Audio.Command
  let prefix: String

  override var isEnabled: Bool {
    get { false }
    set {}
  }

  init(
    title: String,
    action: Selector?,
    keyEquivalent: String,
    audioCommand: Audio.Command
  ) {
    self.prefix = title
    self.command = audioCommand

    super.init(
      title: "\(title) \(Player.instance.volume)",
      action: action,
      keyEquivalent: keyEquivalent
    )
    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main

    center.addObserver(forName: .audioCommandResult, object: nil, queue: mainQueue) {
      (note) in

      guard let result = note.object as? Audio.Result else {
        return
      }

      guard result.command == self.command else {
        return
      }
      self.title = "\(self.prefix) \(result.value)"
      guard let parent = self.parent?.submenu! else {
        return
      }
      guard let idx = parent.items.firstIndex(of: self) else {
        return
      }
      parent.removeItem(at: idx)
      parent.insertItem(self, at: idx)
    }
  }
}

class AudioMenu: BaseMenu {
  override var actions: [NSMenuItem] {
    [
      AudioMenuItem(
        title: "Toggle sound",
        action: #selector(onAudioMute(sender:)),
        keyEquivalent: "m"
      ),
      AudioItem(
        title: "Gain down",
        action: #selector(onAudioCommand(sender:)),
        keyEquivalent: "[",
        parameter: Audio.Parameter(command: .volume_offset, value: -5)
      ),
      AudioItem(
        title: "Gain up",
        action: #selector(onAudioCommand(sender:)),
        keyEquivalent: "]",
        parameter: Audio.Parameter(command: .volume_offset, value: 5)
      ),
      AudioLabelItem(
        title: "Volume:",
        action: nil,
        keyEquivalent: "",
        audioCommand: .volume_set
      ),
    ]
  }

  override func observe() {
    center.addObserver(forName: .vendorChanged, object: nil, queue: mainQueue) { note in
      self.removeAllItems()
      self._init()
    }
  }
}
