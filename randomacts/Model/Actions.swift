//
//  Actions.swift
//  randomacts
//
//  Created by roger deutsch on 11/20/23.
//

import Foundation

struct Action: Codable{
    let screenName: String?
    let category: String?
    let subCategory: String?
    let description: String?
    let status: String?
    let created: String?
    let updated: String?
    let active: Bool?
}

struct Task: Codable{
    //let success: Bool
    let tasks: [Action]
    
}

var allCategories = Set<String>()
var allDescriptions = Set<String>()

var results = [Action]()

var prodBaseUrl = "https://newlibre.com/kind/api/";
var macminiIp = "155";
var maclaptopIp = "110";
var devBaseUrl = "http://192.168.5.\(maclaptopIp):7103/";
var baseUrl = devBaseUrl;

func  loadData(_ updateTaskText: @escaping (String)->() ) -> [Action] {
    
    var taskText = ""
    print("loadData()...")
        guard let url = URL(string: "\(baseUrl)KTask/GetAll" ) else {
            print("Invalid URL")
            return []
        }
        let request = URLRequest(url: url)
        // if we've already loaded the data from the webApi then just use that data
        if (allDescriptions.count > 0){
            print("### TASKS ARE ALREADY LOADED ######")
            
                taskText = getRandomTaskText()
                updateTaskText(taskText)
            
            return []
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                print("data: \(data) \(Date())")
                            do {
                                let response = try JSONDecoder().decode(Task.self, from: data)
                                print("is this called?")
                                
                                DispatchQueue.main.async {
                                    
                                    results = response.tasks
                                    
                                    addCat()
                                    taskText = getRandomTaskText()
                                    
                                    updateTaskText(taskText)
                                    
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
    
    return results
}

func addCat(){
    print("addCat()...")
    if results.count == 0 {return}
    for i in 0...results.count-1{
        allDescriptions.insert(results[i].description ?? "")
        if results[i].category == ""{continue}
        allCategories.insert(results[i].category ?? "")
        //print("\(i) : \(results[i].category ?? "")")
    }
    print("there are \(allCategories.count) Cats!")
//    for item in allCategories {
//        print ("Category : \(item)")
//    }
    print("leaving addCat()...")

}

func getRandomTaskText() -> String{
    print("in getRandomTask()...")
    var currentTaskText = ""
    if allDescriptions.count <= 0{
        currentTaskText = "No items loaded! Please run Load KTasks"
        return currentTaskText
    }
    var idx = Int.random(in: 0...allDescriptions.count-1)
    currentTaskText = Array(allDescriptions)[idx]
    return currentTaskText
}

func acceptUserTask(_ reportResult: @escaping (String)->(),userId: Int64, taskId: Int64) -> Bool{
    let destinationUrl = "\(baseUrl)UserTask/Save"
    
    guard let url = URL(string: destinationUrl ) else {
        print("Invalid URL")
        return false
    }
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    let finalData = "userId=\(userId)&taskId=\(taskId)"
    request.httpBody = finalData.data(using: String.Encoding.utf8)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
            
            print("data: \(data) \(Date())")
                        do {
                            let response = try JSONDecoder().decode(UserTaskResult.self, from: data)
                            print("Decoded UserTasks properly.")
                            
                            print("Success retrieve! \(String(decoding: data, as: UTF8.self))")
                            print("Saved remote UserTask!!")

                            reportResult("Successfully saved UserTask")
                            
                            DispatchQueue.main.async {
                                print ("response: \(data)")
                                print("SUCCESS: \(String(decoding: data, as: UTF8.self))")
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

func updateUserTask(_ reportResult: @escaping (String)->(),userTaskId: Int64, note: String, completed: String="") -> Bool{
    let destinationUrl = "\(baseUrl)UserTask/Update"
    
    guard let url = URL(string: destinationUrl ) else {
        print("Invalid URL")
        return false
    }
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    let finalData = "userTaskId=\(userTaskId)&note=\(note)&completed=\(completed)"
    request.httpBody = finalData.data(using: String.Encoding.utf8)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
            
            print("data: \(data) \(Date())")
                        do {
                            let response = try JSONDecoder().decode(UserTaskResult.self, from: data)
                            print("Decoded UserTasks properly.")
                            
                            print("Successfully UPDATED! \(String(decoding: data, as: UTF8.self))")

                            reportResult("Successfully updated UserTask")
                            
                            DispatchQueue.main.async {
                                print ("response: \(data)")
                                print("SUCCESS: \(String(decoding: data, as: UTF8.self))")
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
