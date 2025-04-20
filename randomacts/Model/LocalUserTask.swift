//
//  LocalUserTask.swift
//  randomacts
//
//  Created by roger deutsch on 1/23/24.
//

import Foundation
struct UserTasks : Decodable{
    let success: Bool?
    let allUserTasks: [UserTask]
}

struct UserTaskResult: Decodable{
    let success: Bool?
    let ut: UserTask
}

struct UserTask: Codable{
    let id: Int64
    let userId: Int64
    let taskId: Int64
    var note: String?
    let category: String?
    let subcategory: String?
    let description: String?
    let created: String?
    var completed: String?
    let active: Bool
    
    init(){
        id = 0
        userId = 0
        taskId = 0
        note = nil
        category = nil
        subcategory = nil
        description = nil
        created = nil
        completed = nil
        active = false
    }
}

class LocalUserTask : ObservableObject, Codable, Identifiable{
    
    var userTasks: [UserTask]
    let userId: Int64
    
    init(_ userId: Int64){
        self.userId = userId
        self.userTasks = [UserTask]()
    }
    
    func GetAll(pView: ContentView, saveUserTasks: @escaping (_ pView: ContentView, _ userTasks: [UserTask]) ->(), isScreenName: Bool = false) -> Bool{
        let destinationUrl : String = "\(baseUrl)UserTask/GetAll"
        
        guard let url = URL(string: destinationUrl ) else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        let finalData = "userId=\(userId)"
        request.httpBody = finalData.data(using: String.Encoding.utf8)
    
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                // print("data: \(data) \(Date())")
                            do {
                                let response = try JSONDecoder().decode(UserTasks.self, from: data)
                                print("Decoded UserTasks properly.")
                                self.userTasks = response.allUserTasks
                                //print("Success retrieve! \(String(decoding: data, as: UTF8.self))")
                                print("SAVING SELF!!")

                                saveUserTasks(pView, self.userTasks)
                                
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

