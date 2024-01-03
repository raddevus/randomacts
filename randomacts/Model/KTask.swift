//
//  KTask.swift
//  randomacts
//
//  Created by roger deutsch on 1/2/24.
//

import Foundation
// KTask is the main Kindness task from the complete kindness catalog

struct KTask: Decodable{
    let id: Int64
    let screenName: String
    let category: String
    let subCategory: String
    let description: String
    let status: String
    let created: String
    let updated: String?
    let active: Bool
}

struct KTasks: Decodable{
    let tasks: [KTask]
}

var allKTasks = [KTask]()

func  loadAllKTasks(_ updateTask: @escaping (KTask?)->() ) -> [KTask] {
    
    var task: KTask? = nil
    print("loadData()...")
        guard let url = URL(string: "https://newlibre.com/kind/api/KTask/GetAll" ) else {
            print("Invalid URL")
            return []
        }
        let request = URLRequest(url: url)
        // if we've already loaded the data from the webApi then just use that data
    if (allKTasks.count > 0){
            print("### KTASKS ARE ALREADY LOADED ######")
            
                task = getRandomTask()
                updateTask(task)
            
            return []
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                print("data: \(data) \(Date())")
                            do {
                                let response = try JSONDecoder().decode(KTasks.self, from: data)
                                print("is this called?")
                                
                                DispatchQueue.main.async {
                                    
                                    allKTasks = response.tasks
                                    
                                    addCat()
                                    task = getRandomTask()
                                    
                                    updateTask(task)
                                    
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
    
    return allKTasks
}

func getRandomTask() -> KTask?{
    print("in getRandomTask()...")
    var currentTask: KTask? = nil
    if allKTasks.count <= 0{
        print("No items loaded! Please run Load KTasks")
        return nil
    }
    var idx = Int.random(in: 0...allKTasks.count-1)
    currentTask = Array(allKTasks)[idx]
    print ("KTask: \(String(describing: currentTask))")
    return currentTask
}
