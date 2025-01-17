import Fluent
import Vapor

func routes(_ app: Application) throws {

    // 방 생성
    app.post("rooms") { req -> EventLoopFuture<Room> in
        let room = try req.content.decode(Room.self)
        room.startTime = nil
        return room.save(on: req.db).map { room }
    }

    // 방 입장
    app.get("rooms", ":id") { req -> EventLoopFuture<Room> in
        guard let roomId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid room ID")
        }
        return Room.find(roomId, on: req.db).unwrap(or: Abort(.notFound))
    }
    
    // 방 입장 (roomTitle로)
    app.get("rooms", "join", ":roomTitle") { req -> EventLoopFuture<Room> in
        guard let roomTitle = req.parameters.get("roomTitle") else {
            throw Abort(.badRequest, reason: "Invalid room title")
        }
        return Room.query(on: req.db)
            .filter(\.$roomTitle == roomTitle)
            .first()
            .unwrap(
                or: Abort(
                    .notFound,
                    reason: "Room with title '\(roomTitle)' not found"
                )
            )
            .map { room in
                Room(
                    id: room.id!,
                    roomTitle: room.roomTitle,
                    bpm: room.bpm,
                    startTime: room.startTime
                )
            }
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
            ws.close(promise: nil)
            return
        }
        
        WebSocketManager.shared.add(ws, to: roomId) // 웹소켓 연결 추가
        
        ws.onText { ws, text in
            guard let data = text.data(using: .utf8),
                  let message = try? JSONDecoder().decode(MetronomeMessage.self, from: data) else {
                ws.send("Invalid message format")
                return
            }
            
            switch message.action {
            case .start:
                // 메트로놈 시작 메시지 처리
                if let startTime = message.startTime {
                    Room.find(roomId, on: req.db)
                        .flatMap { (room: Room?) -> EventLoopFuture<Room> in
                            guard let room = room else {
                                return req.eventLoop
                                    .future(error: Abort(.notFound))
                            }
                            room.startTime = ISO8601DateFormatter()
                                .date(from: startTime)
                            return room.save(on: req.db).map { room }
                        }
                        .map { room in
                            // 모든 클라이언트에게 시작 시간 브로드캐스트
                            let broadcastMessage = MetronomeMessage(
                                action: .start,
                                bpm: room.bpm,
                                startTime: startTime
                            )
                            if let jsonData = try? JSONEncoder().encode(
                                broadcastMessage
                            ),
                               let jsonString = String(
                                data: jsonData,
                                encoding: .utf8
                               ) {
                                WebSocketManager.shared
                                    .broadcast(to: roomId, message: jsonString)
                            }
                        }
                        .whenFailure { error in
                            ws.send("Error: \(error.localizedDescription)")
                        }
                }
            case .updateBPM:
                if let newBPM = message.bpm {
                    Room.find(roomId, on: req.db)
                        .flatMap { (room: Room?) -> EventLoopFuture<Room> in
                            guard let room = room else {
                                return req.eventLoop
                                    .future(error: Abort(.notFound))
                            }
                            room.bpm = newBPM
                            return room.save(on: req.db).map { room }
                        }
                        .map { room in
                            // 모든 클라이언트에게 새로운 BPM 브로드캐스트
                            let broadcastMessage = MetronomeMessage(
                                action: .updateBPM,
                                bpm: newBPM,
                                startTime: nil
                            )
                            if let jsonData = try? JSONEncoder().encode(
                                broadcastMessage
                            ),
                               let jsonString = String(
                                data: jsonData,
                                encoding: .utf8
                               ) {
                                WebSocketManager.shared
                                    .broadcast(to: roomId, message: jsonString)
                            }
                        }
                        .whenFailure { error in
                            ws.send("Error: \(error.localizedDescription)")
                        }
                }
            }
        }
        
        ws.onClose.whenComplete { _ in
            WebSocketManager.shared.remove(ws, from: roomId)
        }
    }

    // RoomController 등록
    let roomController = RoomController()
    try app.register(collection: roomController)
}


class WebSocketManager {
    static let shared = WebSocketManager()
    private var connections: [UUID: [WebSocket]] = [:]
    
    func add(_ ws: WebSocket, to roomId: UUID) {
        if connections[roomId] == nil {
            connections[roomId] = []
        }
        connections[roomId]?.append(ws)
    }
    
    func remove(_ ws: WebSocket, from roomId: UUID) {
        connections[roomId]?.removeAll(where: { $0 === ws })
    }
    
    func broadcast(to roomId: UUID, message: String) {
        connections[roomId]?.forEach { ws in
            ws.send(message)
        }
    }
}

struct MetronomeMessage: Codable {
    enum Action: String, Codable {
        case start
        case updateBPM
    }
    
    let action: Action
    let bpm: Int?
    let startTime: String?
}
