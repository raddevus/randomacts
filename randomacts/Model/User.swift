//
//  User.swift
//  randomacts
//
//  Created by roger deutsch on 12/27/23.
//

import Foundation

struct RetVal : Decodable{
    let success: Bool?
    let user: User
}

struct User: Codable{
    public var id: Int64
    var roleId: Int64
    var guid: String
    var screenName: String?
    var pwdHash: String?
    var email: String?
    var created: String?
    var updated: String?
    var active: Bool
    
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
    private var isNewAccount: Bool = false
    
    func setNewAccount(){
        isNewAccount = true
    }
    
    init(){
        uuid = UUID()
        user = User(uuid.uuidString.lowercased())
    }
    
    init (uuid: String){
        self.uuid = UUID(uuidString: uuid)!
        print("self.uuid: \(self.uuid)")
        user = User(self.uuid.uuidString.lowercased())
    }
    
    func Save(saveUser: @escaping (_ user: LocalUser, _ isNewUserId: Bool ) ->(), isScreenName: Bool = false, password: String = "") -> Bool{
        let destinationUrl : String = {
            if isScreenName{
                "\(baseUrl)User/SetScreenName"
            }
            else{
                "\(baseUrl)User/Save"
            }
        }()
        
        guard let url = URL(string: destinationUrl ) else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: url)
        if isScreenName{
            request.httpMethod = "POST"
            
            let finalData = "guid=\(uuid.uuidString.lowercased())&screenName=\(user.screenName ?? "")"
            request.httpBody = finalData.data(using: String.Encoding.utf8)
        }
        else{
            request.httpMethod = "POST"
            var pwdData : String = ""
            if (password != ""){
                pwdData = "&pwd=\(password)"
                print("pwdData: \(pwdData)")
            }
            let req = "guid=\(uuid.uuidString.lowercased())\(pwdData)"
            print("req: \(req)")
            request.httpBody =  Data(req.utf8)// req.data(using: String.Encoding.utf8)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                print("data: \(data) \(Date())")
                            do {
                                let response = try JSONDecoder().decode(RetVal.self, from: data)
                                print("calling user.Save()...")
                                self.user.id = response.user.id
                                print("got userId = \(self.user.id)")
                                // print("self.user.id ====> \(self.user.id)")
                                self.user.roleId = response.user.roleId
                                self.user.screenName = response.user.screenName
                                self.user.pwdHash = response.user.pwdHash
                                self.user.email = response.user.email
                                self.user.created = response.user.created
                                self.user.updated = response.user.updated
                                print("SAVING SELF!!")
                                
                                if self.isNewAccount {
                                    saveUser(self, true)
                                }else{
                                    saveUser(self, false)
                                }
                                
                                DispatchQueue.main.async {
                                    print ("response: \(data)")
                                    //print("SUCCESS: \(String(decoding: data, as: UTF8.self))")
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
    
    func Save(saveUser: @escaping (_ user: LocalUser) ->(), pwd: String, email: String) -> Bool{
        let destinationUrl : String = "\(baseUrl)User/SetUser"
        
        guard let url = URL(string: destinationUrl ) else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        user.email = email
        let finalData = try? JSONEncoder().encode(user)
        // Finally cleaned all this up - the real issue is that the WebAPI method must not be marked [FromBody]
        // or [FromForm] !! It has to be be just a normal method with none of these decorators
        // Example: SetUser(User user) -- works great. 
        request.httpBody = finalData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                print("data: \(data) \(Date())")
                            do {
                                let response = try JSONDecoder().decode(RetVal.self, from: data)
                                print("calling user.Save()...")
                                self.user.id = response.user.id
                                print("got userId = \(self.user.id)")
                                // print("self.user.id ====> \(self.user.id)")
                                self.user.roleId = response.user.roleId
                                self.user.screenName = response.user.screenName
                                self.user.pwdHash = response.user.pwdHash
                                self.user.email = response.user.email
                                self.user.created = response.user.created
                                self.user.updated = response.user.updated
                                print("SAVING SELF!!")

                                saveUser(self)
                                
                                DispatchQueue.main.async {
                                    print ("response: \(data)")
                                    //print("SUCCESS: \(String(decoding: data, as: UTF8.self))")
                                    
                                }
                                
                                return
                                
                            }catch {
                                print("\(error) \(response ?? URLResponse())")
                                print("CATCH: \(String(decoding: data, as: UTF8.self))")
                            }
            }
            else{
                print("I failed")
                
            }
        }.resume()
        
        return true
    }
    
    func SetPassword(AfterPasswordSet: @escaping (_ isSaved: Bool) ->(), userGuid: String, pwd: String) -> Bool{
        let destinationUrl : String = "\(baseUrl)User/SetPassword?guid=\(userGuid.lowercased())&pwd=\(pwd)"
        
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
                                let response = try JSONDecoder().decode(RetVal.self, from: data)
                                print("Decoded Groups properly.")
                                self.user = response.user
                                //print("Success retrieve! \(String(decoding: data, as: UTF8.self))")
                                print("SAVING SELF!!")

                                AfterPasswordSet(response.success ?? false)
                                
                                DispatchQueue.main.async {
                                    // print ("response: \(data)")
                                    // print("SUCCESS: \(String(decoding: data, as: UTF8.self))")
                                    
                                }
                                
                                return
                                
                            }catch {
                                print("\(error)")
                                print("CATCH: \(String(decoding: data, as: UTF8.self))")
                                AfterPasswordSet(false)
                            }
            }
            else{
                print("I failed")
                
            }
        }.resume()
        
        return true
    }
}
