//
//  LazyStream.swift
//  LazyStream
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

protocol LazyStream {
    var stream_id: Int64 { get set }

    var category_id: Int64 { get set }

    var epg_channel_id: String { get set }

    var stream_icon: String { get set }
}

protocol LazyStreams {
    func fetchStreams() async -> [LazyStream]

    var title: String { get }

    var expiresIn: TimeInterval { get }

    var startTime: Date { get }

    var hasExpired: Bool { get }
}
