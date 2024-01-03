//
//  User.swift
//  randomacts
//
//  Created by roger deutsch on 12/27/23.
//

import Foundation

struct RetVal : Decodable{
    let success: Bool
    let message: String
    let user: User
}

struct User: Decodable{
    let Id: Int64
    let RoleId: Int64
    let Guid: String
    let ScreenName: String
    let PwdHash: String
    let Email: String
    let Created: Date
    let Updated: Date
    let Active: Bool
}

class UserX: ObservableObject, Codable, Identifiable{
    public let id: UUID
    var screenName: String = ""
    
    init(){
        id = UUID()
    }
    
    init (id: String){
        self.id = UUID(uuidString: id)!
        print("self.id: \(self.id)")
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
            // url.append(queryItems:  [URLQueryItem(name: "guid", value: "\(id)"), URLQueryItem(name: "screenName", value: "\(screenName)")])
            let req = "guid=\(id.uuidString.lowercased()),screenName=\(screenName)"
            //print("url: \(url)")
            request.httpBody = req.data(using: String.Encoding.utf8)
        }
        else{
            request.httpMethod = "POST"
            let req = "guid=\(id.uuidString.lowercased())"
            request.httpBody = req.data(using: String.Encoding.utf8)
        }
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                print("data: \(data) \(Date())")
                            do {
                                let response = try JSONDecoder().decode(RetVal.self, from: data)
                                print("is this called?")
                                
                                DispatchQueue.main.async {
                                    
                                    var success = response.success
                                    print("\(success)")
                                    
                                }
                                // print("response: \(response)")
                                
                                return
                                
                            }catch {
                                print ("\(error)")
                            }
            }
            else{
                print("I failed")
            }
        }.resume()
        return true
    }
}
