//
//  File.swift
//  MetronomeServer
//
//  Created by 정종원 on 1/15/25.
//

import Vapor

final class RoomController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let roomsRoute = routes.grouped("rooms")
        roomsRoute.post(use: createRoom)  // 방 생성
        roomsRoute.get(":id", use: getRoom)  // 방 조회
        roomsRoute.put(":id", use: updateRoom)  // 방 BPM 업데이트
        roomsRoute.delete(":id", use: deleteRoom)  // 방 삭제
        roomsRoute.webSocket(":id", "metronome", onUpgrade: metronomeWebSocket)  // WebSocket 라우팅
    }

    // 방 생성
    @Sendable
    func createRoom(req: Request) throws -> EventLoopFuture<Room> {
        let room = try req.content.decode(Room.self)
        return room.save(on: req.db).map { room }
    }

    // 방 조회
    @Sendable
    func getRoom(req: Request) throws -> EventLoopFuture<Room> {
        guard let roomId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid room ID")
        }
        return Room.find(roomId, on: req.db).unwrap(or: Abort(.notFound))
    }

    // 방 BPM 업데이트
    @Sendable
    func updateRoom(req: Request) throws -> EventLoopFuture<Room> {
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

    // 방 삭제
    @Sendable
    func deleteRoom(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let roomId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid room ID")
        }
        
        return Room.find(roomId, on: req.db).flatMap { existingRoom in
            guard let existingRoom = existingRoom else {
                return req.eventLoop.future(error: Abort(.notFound, reason: "Room not found"))
            }
            return existingRoom.delete(on: req.db).transform(to: .noContent)
        }
    }

    // WebSocket을 통한 메트로놈 공유
    @Sendable
    func metronomeWebSocket(req: Request, ws: WebSocket) {
        guard let roomId = req.parameters.get("id", as: UUID.self) else {
            ws.send("Invalid room ID")
            ws.close()
            return
        }
        
        ws.onText { ws, text in
            let bpmValue = text
            ws.send("BPM for room \(roomId): \(bpmValue)")
        }

        // 연결 종료
        ws.onClose.whenComplete { _ in
            // 방에서 클라이언트가 연결을 종료할 때 처리할 로직을 추가하는 부분
        }
    }
}
