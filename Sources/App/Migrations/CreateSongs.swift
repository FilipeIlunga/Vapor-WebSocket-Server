//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 29/08/23.
//

import Fluent

struct CreateSongs: Migration {
    
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        //Tabela chamada "Song" que possui colunas chamada id e title
        return database.schema("songs")
            .id()
            .field("title", .string, .required)
            .create()
    }
    
    // Reverte as mudancas feitas no prepare
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("songs").delete()
    }
    
}
