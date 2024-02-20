//
//  Stats.swift
//  randomacts
//
//  Created by roger deutsch on 2/19/24.
//

import Foundation

struct UserStats: Codable{
    let success: Bool
    let counts: [Int]
    
    init(){
        success = false
        counts = []
    }
}

class Statitiscs {
    var userStats: UserStats? = nil
        
    func GetUserStats(displayUserStats: @escaping (_ userStats: [Int]) ->(), userId: Int64) -> Bool{
        let destinationUrl : String = "https://newlibre.com/kind/api/Stats/GetUserStats"
        
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
                                let response = try JSONDecoder().decode(UserStats.self, from: data)
                                print("Decoded UserStats properly.")
                                self.userStats = response
                                //print("Success retrieve! \(String(decoding: data, as: UTF8.self))")
                                print("SAVING SELF!!")

                                displayUserStats(self.userStats?.counts ?? [])
                                
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


