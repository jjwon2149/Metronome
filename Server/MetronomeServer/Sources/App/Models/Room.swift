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

    @Field(key: "name")
    var name: String

    @Field(key: "bpm")
    var bpm: Int // 방에서 공유할 BPM 값

    @Field(key: "creator")
    var creator: String // 방장 정보

    init() {}

    init(id: UUID? = nil, name: String, bpm: Int, creator: String) {
        self.id = id
        self.name = name
        self.bpm = bpm
        self.creator = creator
    }
}
