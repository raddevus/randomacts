//
//  LocalGroup.swift
//  randomacts
//
//  Created by roger deutsch on 2/21/24.
//

import Foundation

struct KGroupResponse : Decodable{
    let success: Bool?
    public let allGroups: [KGroup]
}

struct KGroup: Codable, Identifiable{
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
        var group: KGroup
        var groups: [KGroup] = []
        private let uuid: UUID
        
        init(){
            uuid = UUID()
            group = KGroup(uuid.uuidString.lowercased())
        }
        
        func CreateGroup(GroupCreated: @escaping (_ group: KGroup) ->(), userId: Int64, groupName: String, pwd: String) -> Bool{
            let destinationUrl : String = "\(baseUrl)Group/Create"
            
            guard let url = URL(string: destinationUrl ) else {
                print("Invalid URL")
                return false
            }
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            
            let finalData = "{\"id\":0,\"OwnerId\":\(userId),\"MemberId\":\(userId),\"Guid\":\"\(uuid.uuidString.lowercased())\",\"Name\":\"\(groupName)\",\"PwdHash\":\"\(pwd)\",\"Created\":null,\"Updated\":null,\"Active\":true}"
            request.httpBody = finalData.data(using: String.Encoding.utf8)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    // print("data: \(data) \(Date())")
                                do {
                                    let response = try JSONDecoder().decode(KGroup.self, from: data)
                                    print("Decoded UserStats properly.")
                                    self.group = response
                                    //print("Success retrieve! \(String(decoding: data, as: UTF8.self))")
                                    print("SAVING SELF!!")

                                    GroupCreated(self.group)
                                    
                                    DispatchQueue.main.async {
                                        // print ("response: \(data)")
                                        // print("SUCCESS: \(String(decoding: data, as: UTF8.self))")
                                        
                                    }
                                    
                                    return
                                    
                                }catch {
                                    print("\(error)")
                                    print("CATCH: \(String(decoding: data, as: UTF8.self))")
                                }
                }
                else{
                    print("I failed")
                    
                }
            }.resume()
            
            return true
        }
        
        func GetMemberGroups(RetrievedGroups: @escaping (_ groups: [KGroup]) ->(), userGuid: String, pwd: String) -> Bool{
            let destinationUrl : String = "\(baseUrl)Group/GetMemberGroups?guid=\(userGuid.lowercased())&pwd=\(pwd)"
            
            guard let url = URL(string: destinationUrl ) else {
                print("Invalid URL")
                return false
            }
            var request = URLRequest(url: url)
            
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    // print("data: \(data) \(Date())")
                                do {
                                    let response = try JSONDecoder().decode(KGroupResponse.self, from: data)
                                    print("Decoded Groups properly.")
                                    self.groups = response.allGroups
                                    //print("Success retrieve! \(String(decoding: data, as: UTF8.self))")
                                    print("SAVING SELF!!")

                                    RetrievedGroups(self.groups)
                                    
                                    DispatchQueue.main.async {
                                        // print ("response: \(data)")
                                        // print("SUCCESS: \(String(decoding: data, as: UTF8.self))")
                                        
                                    }
                                    
                                    return
                                    
                                }catch {
                                    print("\(error)")
                                    print("CATCH: \(String(decoding: data, as: UTF8.self))")
                                }
                }
                else{
                    print("I failed")
                    
                }
            }.resume()
            
            return true
        }
        
    }
