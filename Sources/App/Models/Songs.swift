//
//  Songs.swift
//  
//
//  Created by Filipe Ilunga on 29/08/23.
//

import Fluent
import Vapor

//Classe que representa a tabela de "Songs"
final class Songs: Model, Content {
    static let schema: String = "songs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    init() {}
    
    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
