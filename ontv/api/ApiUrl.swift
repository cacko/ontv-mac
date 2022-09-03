//
//  ApiUrl.swift
//  craptv
//
//  Created by Alex on 23/10/2021.
//

import Foundation
import Defaults

extension API {

  static func toProxyUrl(url: URL) -> URL {
    
    var useProxy = Defaults[.useProxy]
    
    _ = Defaults.observe(.useProxy) { change in
      useProxy = change.newValue
    }
        
    if useProxy {
      let res = URL(string: "https://preslav.cacko.net/\(url.absoluteString.b64)") ?? url
      return res
    }
    
    return url

  }

  enum Endpoint {

    static var endpoint: String {
      "\(API.Adapter.server_info.server_protocol)://\(API.Adapter.server_info.url):\(API.Adapter.server_info.port)"
    }

    static var BaseAction: String {
      "\(endpoint)/player_api.php?username=\(API.Adapter.username)&password=\(API.Adapter.password)"
    }

    static var BaseResource: String {
      "\(endpoint)/live/\(API.Adapter.username)/\(API.Adapter.password)"
    }

    static var Login: URL {
      API.toProxyUrl(
        url:
          URL(
            string: BaseAction
          )!
      )
    }

    static var Streams: URL {
      API.toProxyUrl(
        url:
          URL(
            string:
              "\(BaseAction)&action=get_live_streams"
          )!
      )
    }

    static var Categories: URL {
      API.toProxyUrl(
        url:
          URL(
            string:
              "\(BaseAction)&action=get_live_categories"
          )!
      )

    }

    static var Schedule: URL {
      URL(string: "https://ontv.cacko.net/api/data/schedule.json") ?? URL(fileURLWithPath: "")
    }

    static var EPG: URL {
      URL(string: "https://ontv.cacko.net/api/data/xmltv.json") ?? URL(fileURLWithPath: "")
    }

    static func Stream(_ id: Int64) -> URL {
      API.toProxyUrl(
        url:
          URL(string: "\(BaseResource)/\(id).ts")!
      )
    }

    static func Icon(id: Int64, epg: String = "") -> URL {
      guard
        var urlBuilder = URLComponents(
          string:
            "https://ontv.cacko.net"
        )
      else {
        fatalError("")
      }
      urlBuilder.path =
        "/api/assets/channel/logo/\(String(id))/\(epg.count == 0 ? "default" : epg).png"
      return urlBuilder.url!
    }

    static func TeamBadge(team: String) -> URL {
      guard
        var urlBuilder = URLComponents(
          string: "https://ontv.cacko.net"
        )
      else {
        fatalError("")
      }
      urlBuilder.path = "/api/assets/team/badge/\(team).png"
      return urlBuilder.url!
    }

    static func EventThumb(event: String) -> URL {
      guard
        var urlBuilder = URLComponents(
          string: "https://ontv.cacko.net"
        )
      else {
        fatalError("")
      }
      urlBuilder.path = "/api/assets/event/thumb/\(event).png"
      return urlBuilder.url!
    }

    static var Sports: URL {
      URL(string: "https://ontv.cacko.net/api/data/sports.json") ?? URL(fileURLWithPath: "")
    }

    static func SportIcon(id: String) -> URL {
      guard
        var urlBuilder = URLComponents(
          string: "https://ontv.cacko.net"
        )
      else {
        fatalError("")
      }
      urlBuilder.path = "/api/assets/sport/icon/\(id).png"
      return urlBuilder.url!
    }

    static var Livescores: URL {
      URL(string: "https://ontv.cacko.net/api/data/livescores.json") ?? URL(fileURLWithPath: "")
    }

    static var Leagues: URL {
      URL(string: "https://ontv.cacko.net/api/data/leagues.json") ?? URL(fileURLWithPath: "")
    }
  }

}
