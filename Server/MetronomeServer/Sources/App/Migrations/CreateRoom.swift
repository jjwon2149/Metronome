//
//  File.swift
//  MetronomeServer
//
//  Created by 정종원 on 1/15/25.
//

import Fluent

struct CreateRoom: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("rooms")
            .id()
            .field("name", .string, .required)
            .field("bpm", .int, .required)
            .field("creator", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("rooms").delete()
    }
}
