//
//  QuoteX.swift
//  randomacts
//
//  Created by roger deutsch on 12/29/23.
//

import Foundation

struct thing : Decodable{
    //let success : Int
    let quote: quote
}

struct quote: Decodable{
    let id: Int64
    let fName: String
    let lName: String
    let category: String
    let content: String
    let dayNumber: Int
    let created: String
    let updated: String?
    let active: Bool
    
}

struct gen1Reply : Decodable{
    let success: Bool?
    let message: String
    let user: User
}

struct Extra: Decodable{
    let first: String
    let second: Float
    let third: Int
}

struct gen2Reply : Decodable{
    let success: Bool
    let message: String
    let extra : Extra
}

struct gen3Reply : Decodable{
    let extra : Extra
}

class QuoteX{
    func GetQuote(setQuote: @escaping (_ quoteText: String, _ author: String) ->(), iso8601Date: String) -> Bool{
        
        let destinationUrl : String = {
            "\(baseUrl)Quote/GetDailyQuote?iso8601Date=\(iso8601Date)"
        }()
        
        guard var url = URL(string: destinationUrl ) else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        //let req = "iso8601Date=\(iso8601Date)"
        //url.append(queryItems:  [URLQueryItem(name: "iso8601Date", value: "\(iso8601Date)")])
        //request.httpBody = req.data(using: String.Encoding.utf8)
        print ("quote URL: \(url)")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                print("data: \(data) \(Date())")
                            do {
                                print("\(data.debugDescription)")
                                let response = try JSONDecoder().decode(thing.self, from: data)
                                print("GetQuote!!")
                                
                                setQuote(response.quote.content, response.quote.fName)
                                
                                DispatchQueue.main.async {
                                    
                                    //var success = response.success
                                    //print("success: \(success)")
                                    print(response.quote.content)
                                    
                                }
                                // print("response: \(response)")
                                
                                return
                                
                            }catch {
                                print ("\(error)")
                                print("CATCH: \(String(decoding: data, as: UTF8.self))")
                            }
            }
            else{
                print("I failed")
            }
        }.resume()
        return true
    }
    
    func Gen1() -> Bool{
        
        let destinationUrl : String = {
            "\(baseUrl)Quote/Gen1"
        }()
        
        guard let url = URL(string: destinationUrl ) else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        // request.httpBody = req.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                print("data: \(data) \(Date())")
                            do {
                                let response = try JSONDecoder().decode(gen1Reply.self, from: data)
                                print("is this called?")
                                
                                DispatchQueue.main.async {
                                    
                                    let success = response.success
                                    print("\(String(describing: success))")
                                    print("user \(response.user)")
                                    
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
    
    func Gen2() -> Bool{
        
        let destinationUrl : String = {
            "\(baseUrl)Quote/Gen2"
        }()
        
        guard let url = URL(string: destinationUrl ) else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        // request.httpBody = req.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                print("data: \(data) \(Date())")
                            do {
                                let response = try JSONDecoder().decode(gen2Reply.self, from: data)
                                print("is this called?")
                                
                                DispatchQueue.main.async {
                                    
                                    let success = response.success
                                    print("response: \(response)")
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
    
    func Gen3() -> Bool{
        
        let destinationUrl : String = {
            "\(baseUrl)Quote/Gen3"
        }()
        
        guard let url = URL(string: destinationUrl ) else {
            print("Invalid URL")
            return false
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        // request.httpBody = req.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                print("data: \(data) \(Date())")
                            do {
                                let response = try JSONDecoder().decode(gen3Reply.self, from: data)
                                print("is this called?")
                                
                                DispatchQueue.main.async {
                                    
                                    //var success = response.sucess
                                    print("response: \(response)")
                                    //print("\(success)")
                                    
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

