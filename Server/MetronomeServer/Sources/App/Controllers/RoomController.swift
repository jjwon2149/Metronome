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
        roomsRoute.get(":id", use: getRooms)  // 방 조회
        roomsRoute.put(":id", use: updateRoom)  // 방 BPM 업데이트
        roomsRoute.delete(":id", use: deleteRoom)  // 방 삭제
    }

    // 방 생성
    @Sendable
    func createRoom(req: Request) throws -> EventLoopFuture<Room> {
        let room = try req.content.decode(Room.self)
        return room.save(on: req.db).map { room }
    }

    // 방 조회
    @Sendable
    func getRooms(req: Request) throws -> EventLoopFuture<Room> {
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
}
