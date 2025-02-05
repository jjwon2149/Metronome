//
//  File.swift
//  MetronomeServer
//
//  Created by 정종원 on 1/15/25.
//

import Fluent

struct CreateRoom: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("rooms")
            .id()
            .field("roomTitle", .string, .required)
            .field("bpm", .int, .required)
            .field("startTime", .datetime, .required)
            .create()
//            .update()
    }
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("rooms").delete()
    }
    
    //    func prepare(on database: Database) -> EventLoopFuture<Void> {
    //        database.schema("rooms")
    //            .id()
    //            .field("roomTitle", .string, .required)
    //            .field("bpm", .int, .required)
    //            .create()
    //    }
    //
    //    func revert(on database: Database)  -> EventLoopFuture<Void> {
    //        database.schema("rooms").delete()
    //    }
}
