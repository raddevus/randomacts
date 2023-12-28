//
//  User.swift
//  randomacts
//
//  Created by roger deutsch on 12/27/23.
//

import Foundation

class User: ObservableObject, Codable, Identifiable{
    public let id: UUID
    var screenName: String = ""
    
    init(){
        id = UUID()
    }
    
    init (id: String){
        self.id = UUID(uuidString: id)!
        print("self.id: \(self.id)")
    }
}
