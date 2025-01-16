//
//  File.swift
//  MetronomeServer
//
//  Created by 정종원 on 1/15/25.
//

import Fluent
import Vapor

struct RoomDTO: Content {
    var id: UUID?
    var roomTitle: String
    var bpm: Int
}
// Json 형식으로 데이터를 주고받음
