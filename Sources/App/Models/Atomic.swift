//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 06/09/23.
//

import Foundation

@propertyWrapper
struct Atomic<Value> {
    private let queue = DispatchQueue(label: "com.protected.atomic")
    private var value: Value

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.sync { value = newValue }
        }
    }
}
