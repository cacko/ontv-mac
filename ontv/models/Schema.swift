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
            Entity<V1.Livescore>("Livescore")
          ],versionLock: [
            "Activity": [0x314af1a524494ef2, 0x5ea1c94456a75f65, 0x97145591fced717, 0x5b992d9fa3f6a108],
            "Category": [0x1e66e5c4734a20b3, 0xf33d9d0abab32af7, 0xb7027799b0814d2d, 0x3bcf75d0feb59842],
            "EPG": [0xb382dcb39c59663e, 0x334938e5d71a4ebb, 0xbb8594624f10d374, 0x16cb4120db9d551b],
            "Livescore": [0x436880428931496b, 0x848d76a05183ca72, 0x558c669bede3df6b, 0xbb2ae5610d6f22d5],
            "Schedule": [0x1be1e880d66c07f, 0x8a2bedac42cd65c0, 0x9021a5d23f014601, 0x3a54fa4c4cfd0874],
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
