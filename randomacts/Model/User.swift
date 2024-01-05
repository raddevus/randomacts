//
//  User.swift
//  randomacts
//
//  Created by roger deutsch on 12/27/23.
//

import Foundation

struct RetVal : Decodable{
//    let success: Bool?
//    let message: String
    let user: User
}

struct User: Codable{
    let id: Int64
    let roleId: Int64
    let guid: String
    var screenName: String
    let pwdHash: String?
    let email: String?
    let created: String?
    let updated: Date?
    let active: Bool
    
    init(_ guid: String){
        id = 0
        roleId = 0
        self.guid = guid
        screenName = ""
        pwdHash = ""
        email = ""
        created = ""
        updated = nil
        active = true
    }
    
}

class LocalUser: ObservableObject, Codable, Identifiable{
    
    var user: User
    private let uuid: UUID
    
    init(){
        uuid = UUID()
        user = User(uuid.uuidString.lowercased())
    }
    
    init (uuid: String){
        self.uuid = UUID(uuidString: uuid)!
        print("self.uuid: \(self.uuid)")
        user = User(self.uuid.uuidString.lowercased())
    }
    
    func Save(isScreenName: Bool = false) -> Bool{
        let destinationUrl : String = {
            if isScreenName{
                "https://newlibre.com/kind/api/User/SetScreenName"
            }
            else{
                "https://newlibre.com/kind/api/User/Save"
            }
        }()
        
        guard var url = URL(string: destinationUrl ) else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: url)
        if isScreenName{
            request.httpMethod = "POST"
            
            var finalData = "guid=\(uuid.uuidString.lowercased())&screenName=\(user.screenName)"
            request.httpBody = finalData.data(using: String.Encoding.utf8)
        }
        else{
            request.httpMethod = "POST"
            let req = "guid=\(uuid.uuidString.lowercased())"
            request.httpBody =  Data(req.utf8)// req.data(using: String.Encoding.utf8)
        }
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                print("data: \(data) \(Date())")
                            do {
                                let response = try JSONDecoder().decode(RetVal.self, from: data)
                                print("calling user.Save()...")
                                
                                DispatchQueue.main.async {
                                    print ("response: \(data)")
                                    print("SUCCESS: \(String(decoding: data, as: UTF8.self))")
                                    
                                }
                                
                                return
                                
                            }catch {
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
