//
//  EPGLiveList.swift
//  EPGLiveList
//
//  Created by Alex on 12/10/2021.
//

import CoreStore
import Foundation

class ActivityEPGList: ActivityStorageAbstract {

  override func update() {
    let now = Date()
    let stop = now.addingTimeInterval(60 * 60 * 24 * 2 * -1)
    let predicates: [NSPredicate] = [
      NSPredicate(format: "last_visit > %@", stop as NSDate)
    ]
    query = Where<Activity>(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    super.update()
  }

  override func fetch() {
    do {
      try list.refetch(
        From<Activity>()
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
      if self.player.contentToggle == .activityepg {
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
