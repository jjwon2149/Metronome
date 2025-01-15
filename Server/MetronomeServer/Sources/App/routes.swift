import Fluent
import Vapor

func routes(_ app: Application) throws {

    // 방 생성
    app.post("rooms") { req -> EventLoopFuture<Room> in
        let room = try req.content.decode(Room.self)
        return room.save(on: req.db).map { room }
    }

    // 방 입장
    app.get("rooms", ":id") { req -> EventLoopFuture<Room> in
        guard let roomId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid room ID")
        }
        return Room.find(roomId, on: req.db).unwrap(or: Abort(.notFound))
    }

    // bpm 변경시
    app.put("rooms", ":id") { req -> EventLoopFuture<Room> in
        guard let roomId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid room ID")
        }
        let room = try req.content.decode(Room.self)
        return Room.find(roomId, on: req.db).flatMap { existingRoom in
            guard let existingRoom = existingRoom else {
                return req.eventLoop.future(error: Abort(.notFound, reason: "Room not found"))
            }
            existingRoom.bpm = room.bpm
            return existingRoom.save(on: req.db).map { existingRoom }
        }
    }

    // WebSocket 라우팅: 방 ID를 기반으로 연결
    app.webSocket("rooms", ":id", "metronome") { req, ws in
        guard let roomId = req.parameters.get("id", as: UUID.self) else {
            ws.send("Invalid room ID")
            ws.close()
            return
        }
        
        ws.onText { ws, text in
            // 클라이언트로부터 받은 BPM 값 처리
            let bpmValue = text
            // 이 부분에서 모든 클라이언트에게 BPM을 브로드캐스트 할 수 있음
            ws.send("BPM for room \(roomId): \(bpmValue)")
        }
        
        // WebSocket 연결 종료 처리
        ws.onClose.whenComplete { _ in
            // 방에서 클라이언트 연결 종료 시 처리 로직을 추가할 수 있습니다.
        }
    }

    // RoomController 등록
    let roomController = RoomController()
    try app.register(collection: roomController)  
}
