//
//  ApiResponse.swift
//  ApiResponse
//
//  Created by Alex on 10/10/2021.
//

import Defaults
import Foundation

extension API {
    struct UserInfo: Codable, Defaults.Serializable {
        var username: String
        var password: String
        var message: String?
        var auth: Int8?
        var status: String?
        var exp_date: String?
        var is_trial: String?
        var active_cons: String?
        var created_at: String?
        var max_connections: String?
        var allowed_output_formats: [String]?
    }

    struct ServerInfo: Codable, Defaults.Serializable {
        var url: String
        var port: String
        var https_port: String?
        var server_protocol: String
        var rtmp_port: String?
        var timezone: String?
        var timestamp_now: Int64?
        var time_now: String?
    }

    struct LoginResponse: Codable {
        var user_info: UserInfo
        var server_info: ServerInfo
    }

    enum Exception: Error {
        case invalidLogin(String)
        case noConnection(String)
        case httpError(String)
        case notJson
        case ignoreAndContinue
    }

}
