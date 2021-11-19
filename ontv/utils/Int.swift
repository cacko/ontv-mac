//
//  Int.swift
//  ontv
//
//  Created by Alex on 13/11/2021.
//

import Foundation
import CommonCrypto


extension Int {
  
  var int64: Int64 {
    Int64(self.toNative())
  }
  
  var bool: Bool {
    self.toNative() != 0
  }
  
  var string: String {
    String(format: "%d", self.toNative())
  }
  
  var score: String {
    let val = self.toNative()
    return val > -1 ? String(format: "%d", val) : ""
  }
  
  var sha1: String {
    let hs = String(self.toNative())
    let data = Data(hs.utf8)
    var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
    }
    let hexBytes = digest.map { String(format: "%02hhx", $0) }
    return hexBytes.joined()
  }
  
}


extension Int64 {
  func isEqual(_ other: Int) -> Bool {
    self.toNative() == other.int64
  }
  
  var string: String {
    String(format: "%d", self.toNative())
  }
  
  var sha1: String {
    let hs = String(self.toNative())
    let data = Data(hs.utf8)
    var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
    }
    let hexBytes = digest.map { String(format: "%02hhx", $0) }
    return hexBytes.joined()
  }
}

extension Double {
  
  var string: String {
    String(format: "%f", self.toNative())
  }
}
