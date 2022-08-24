//
//  String.swift
//  String
//
//  Created by Alex on 15/10/2021.
//

import CommonCrypto
import Foundation

extension String {
  func withoutHtmlTags() -> String {
    return components(separatedBy: "\"").first ?? self
  }
  
  var int64: Int64 {
    (self as NSString).longLongValue
  }

  var sha1: String {
    let data = Data(self.utf8)
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
    }
    let hexBytes = digest.map { String(format: "%02hhx", $0) }
    return hexBytes.joined()
  }
  
  static func ~= (lhs: String, rhs: String) -> Bool {
    guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
    let range = NSRange(location: 0, length: lhs.utf16.count)
    return regex.firstMatch(in: lhs, options: [], range: range) != nil
  }
  
  var b64: String {
    if let data = self.data(using: .utf8) {
      return data.base64EncodedString()
    }
    return ""
  }
  
  var videoCodec: String {
    
    let parts = self.components(separatedBy: " ")
    
    return parts[0].uppercased()
    
  }
  
  var audioCodec: String {
    
    let parts = self.components(separatedBy: ",")
    
    return parts[0].uppercased()
    
  }
  
  func decodeBase64() -> String {
    if let data = Data(base64Encoded: self) {
      return String(data: data, encoding: .utf8)!
    }
    return ""
  }
}
