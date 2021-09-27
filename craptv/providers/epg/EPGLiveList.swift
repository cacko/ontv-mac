//
//  EPGLiveList.swift
//  EPGLiveList
//
//  Created by Alex on 12/10/2021.
//

import CoreStore
import Foundation

extension Notification.Name {
  static let toggleEPGList = Notification.Name("toggle_epg_list")
}

class EPGLiveList: EPGStorageAbstract {

  override func update() {
    let now = Date()
    let stop = now.addingTimeInterval(60 * 60 * 5)
    let predicates: [NSPredicate] =
      [NSPredicate(format: "stop > %@ AND stop < %@", now as NSDate, stop as NSDate)]
    query = Where<EPG>(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    super.update()
  }

  override func fetch() {
    do {
      try list.refetch(
        From<EPG>()
          .sectionBy("channel")
          .where(query)
          .orderBy(order),
        sourceIdentifier: nil
      )
      state = .loaded
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }

  override func postInit() {
    timer = DispatchSource.makeTimerSource()
    timer.schedule(deadline: .now(), repeating: .seconds(60))
    timer.setEventHandler {
      if self.player.contentToggle == .epglist {
        DispatchQueue.main.async {
          self.update()
        }
      }
    }
    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main

    center.addObserver(forName: .updaterecent, object: nil, queue: mainQueue) {
      _ in self.update()
    }
    super.postInit()
  }

  override func onChangeStream(stream: Stream) {
    self.update()
  }
}
