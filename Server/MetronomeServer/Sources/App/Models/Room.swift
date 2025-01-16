//
//  File.swift
//  MetronomeServer
//
//  Created by 정종원 on 1/15/25.
//

import Fluent
import Vapor

final class Room: Model, Content {
    static let schema = "rooms" // 테이블 이름

    @ID(key: .id)
    var id: UUID?

    @Field(key: "roomTitle")
    var roomTitle: String // 방 이름

    @Field(key: "bpm")
    var bpm: Int // 방에서 공유할 BPM 값

    init() {}

    init(id: UUID? = nil, roomTitle: String, bpm: Int) {
        self.id = id
        self.roomTitle = roomTitle
        self.bpm = bpm
    }
}
