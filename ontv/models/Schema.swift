//
//  Schema.swift
//  Schema
//
//  Created by Alex on 13/10/2021.
//

import CoreStore
import Foundation

typealias EPG = V1.EPG
typealias Stream = V1.Stream
typealias Category = V1.Category
typealias Schedule = V1.Schedule
typealias Activity = V1.Activity
typealias Livescore = V1.Livescore
typealias Sport = V1.Sport

enum V1 {
}

class Schema {
  class func addStorageAndWait() {
    do {
      CoreStoreDefaults.dataStack = DataStack(
        CoreStoreSchema(
          modelVersion: "V1",
          entities: [
            Entity<V1.Stream>("Stream"),
            Entity<V1.Category>("Category"),
            Entity<V1.Schedule>("Schedule"),
            Entity<V1.EPG>("EPG"),
            Entity<V1.Activity>("Activity"),
            Entity<V1.Livescore>("Livescore"),
            Entity<V1.Sport>("Sport"),
          ],
          versionLock: [
            "Activity": [0x314af1a524494ef2, 0x5ea1c94456a75f65, 0x97145591fced717, 0x5b992d9fa3f6a108],
            "Category": [0x1e66e5c4734a20b3, 0xf33d9d0abab32af7, 0xb7027799b0814d2d, 0x3bcf75d0feb59842],
            "EPG": [0xb382dcb39c59663e, 0x334938e5d71a4ebb, 0xbb8594624f10d374, 0x16cb4120db9d551b],
            "Livescore": [0xe73c624a0794804d, 0x2da3aeeed8c69313, 0xd240cd74d595e696, 0xe9a06697d20e59da],
            "Schedule": [0x1be1e880d66c07f, 0x8a2bedac42cd65c0, 0x9021a5d23f014601, 0x3a54fa4c4cfd0874],
            "Sport": [0x2bc0fbb0d027563a, 0xf3366d57c3126ddc, 0x2e0f20bb6fbc372c, 0x825631c86575a04e],
            "Stream": [0x9937e748575a81d, 0xecf724f737fbf606, 0xce7d2e1d7a2c1981, 0x5c2b7ed1daaa13ef]
          ]
        )
      )
      try CoreStoreDefaults.dataStack.addStorageAndWait()
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }
}
