//
//  LocalGroup.swift
//  randomacts
//
//  Created by roger deutsch on 2/21/24.
//

import Foundation

struct Group: Codable{
    var id: Int64
    var ownerId: Int64
    var memberId: Int64
    var name: String
    var guid: String
    var pwdHash: String
    var created: String?
    var updated: String?
    var active: Bool
    
    init(_ guid: String){
        id = 0
        ownerId = 0
        memberId = 0
        self.guid = guid
        name = ""
        pwdHash = ""
        created = ""
        updated = nil
        active = true
    }
}

    class LocalGroup{
        var group: Group
        private let uuid: UUID
        
        init(){
            uuid = UUID()
            group = Group(uuid.uuidString.lowercased())
        }
    }
