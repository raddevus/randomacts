//
//  LocalGroup.swift
//  randomacts
//
//  Created by roger deutsch on 2/21/24.
//

import Foundation

struct KGroup: Codable{
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
        private let uuid: UUID
        
        init(){
            uuid = UUID()
            group = KGroup(uuid.uuidString.lowercased())
        }
        
        func CreateGroup(displayUserStats: @escaping (_ userStats: [Int]) ->(), userId: Int64, groupName: String, pwd: String) -> Bool{
            let destinationUrl : String = "https://newlibre.com/kind/api/Stats/GetUserStats"
            
            guard let url = URL(string: destinationUrl ) else {
                print("Invalid URL")
                return false
            }
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            
            let finalData = "{\"ownerId\":\(userId),\"memberId\":\(userId),\"guid\":\"\(uuid.uuidString.lowercased())\",\"name\":\"\(groupName)\",\"pwdHash\":\"\(pwd)\",\"created\":null,\"updated\":null,\"active\":true}"
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

//                                    displayUserStats(self.group. ?? [])
                                    
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
