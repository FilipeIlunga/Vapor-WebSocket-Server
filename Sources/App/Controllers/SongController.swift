//
//  SongController.swift
//  
//
//  Created by Filipe Ilunga on 29/08/23.
//

import Fluent
import Vapor

struct SongController: RouteCollection {
    
    //Primeira funcao que irá rodar
    func boot(routes: RoutesBuilder) throws {
        let songs = routes.grouped("songs")
        songs.get(use: index)
        songs.post(use: create)
    }
    
    //songs route
    func index(req: Request) throws -> EventLoopFuture<[Songs]> {
        return Songs.query(on: req.db).all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let song = try req.content.decode(Songs.self)
        return song.save(on: req.db).transform(to: .ok)
    }
    
}
