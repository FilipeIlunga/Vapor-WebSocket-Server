//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 03/09/23.
//

import Foundation

protocol WSCodable: Codable {
    
}

extension WSCodable {
    
    func encode() throws -> String {
        let encoder = JSONEncoder()
        let jsonEncodeData = try encoder.encode(self)
        
        guard let wsEncode = String(data: jsonEncodeData, encoding: .utf8) else {
            throw NSError(domain: "Erro ao converte json para string", code: 0)
        }
        
        return wsEncode
    }
    
    func decode<T: WSCodable>(wsString: String,type: T.Type) throws -> T {
        
        guard let jsonData = wsString.data(using: .utf8) else {
            throw NSError(domain: "Error ao converter string para jason", code: 0)
        }
        
        let decoder = JSONDecoder()
        let wsObject = try decoder.decode(T.self, from: jsonData)
        
        return wsObject
    }
}
