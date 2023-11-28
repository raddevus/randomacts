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

var globalTask = ""

func  loadData(_ updateTaskText: @escaping (String)->() ) -> [Action] {
    print("loadData()...")
        guard let url = URL(string: "https://newlibre.com/kind/api/KTask/GetAll" ) else {
            print("Invalid URL")
            return []
        }
        let request = URLRequest(url: url)
        // if we've already loaded the data from the webApi then just use that data
        if (allDescriptions.count > 0){
            print("### TASKS ARE ALREADY LOADED ######")
            
                globalTask = getRandomTask()
                updateTaskText(globalTask)
            
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
                                    globalTask = getRandomTask()
                                    
                                    updateTaskText(globalTask)
                                    
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

func getRandomTask() -> String{
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
