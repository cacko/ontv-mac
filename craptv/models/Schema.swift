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
          ],
          versionLock: [
            "Activity": [
              0x314a_f1a5_2449_4ef2, 0x5ea1_c944_56a7_5f65, 0x971_4559_1fce_d717,
              0x5b99_2d9f_a3f6_a108,
            ],
            "Category": [
              0xe0e8_88c8_8266_19a3, 0xe796_c835_6165_23df, 0x52e6_0106_0b42_878a,
              0xd375_99d5_c990_1bdf,
            ],
            "EPG": [
              0xa8a_f6e4_9620_d3e4, 0x8069_de20_e6dd_3ee3, 0x73e_42de_be6f_0d6a,
              0x1957_5a4d_1ddd_bc78,
            ],
            "Schedule": [
              0x6e56_4d0f_6b04_49eb, 0x225b_106e_ad16_0fa4, 0x29da_f577_d83b_fb4b,
              0xdd79_a35d_97f4_e509,
            ],
            "Stream": [
              0x36bd_8fe9_cdad_b420, 0x7eca_2081_02d8_0fbf, 0x5af0_a168_39f1_248a,
              0xabb3_42bd_024c_e518,
            ],
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
