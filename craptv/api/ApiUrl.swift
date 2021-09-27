//
//  ApiUrl.swift
//  craptv
//
//  Created by Alex on 23/10/2021.
//

import Foundation

extension API {

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
            URL(
                string: BaseAction
            )
                ?? URL(fileURLWithPath: "")
        }

        static var Streams: URL {
            URL(
                string:
                    "\(BaseAction)&action=get_live_streams"
            ) ?? URL(fileURLWithPath: "")
        }

        static var Categories: URL {
            URL(
                string:
                    "\(BaseAction)&action=get_live_categories"
            ) ?? URL(fileURLWithPath: "")
        }

        static var Schedule: URL {
            URL(string: "https://ontv.cacko.net/thesportsdb") ?? URL(fileURLWithPath: "")
        }

        static var EPG: URL {
            URL(string: "https://ontv.cacko.net/xmltv") ?? URL(fileURLWithPath: "")
        }

        static func Stream(_ id: Int64) -> URL {
            URL(string: "\(BaseResource)/\(id).ts")
                ?? URL(fileURLWithPath: "")
        }

        static func Icon(id: Int64, epg: String?) -> URL {
            guard var urlBuilder = URLComponents(string: "https://ontv.cacko.net/craptv/url") else {
                fatalError("")
            }
            urlBuilder.queryItems = [
                URLQueryItem(name: "id", value: String(id)),
                URLQueryItem(name: "epg", value: epg),
            ]
            return urlBuilder.url!
        }
    }

}
