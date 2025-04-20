//
//  RaokItemView.swift
//  randomacts
//
//  Created by roger deutsch on 11/20/23.
//

import SwiftUI

struct RaokItemView: View {
    @State var results = [Action]()
//    init(results: [Action]){
//        addCat()
//        print("there are : \(allCategories.count)")
//    }
    var body: some View {
        NavigationStack{
            Form{
                
                Section{
                    VStack{
                        List(results, id:\ .description){ item in
                            VStack(alignment: .leading){
                                Group{
                                    VStack{
                                        Text("\(item.category ?? "") " ).foregroundStyle( Color.red)
                                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                        Text("\(item.subCategory ?? "")").foregroundStyle(Color.blue)
                                        Text("\(item.description ?? "")")
                                    }
                                }
                                .padding()
                            }.border(Color.black)
                            Divider()
                        }
                    }
                }
            }.onAppear(perform: {
                
                loadData()
                
            })
                .navigationTitle("KTasks")
        }
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
        for item in allCategories {
            print ("Category : \(item)")
        }
    }
    
    func loadData() ->[Action] {
        print("loadData()...")
            guard let url = URL(string: "\(baseUrl)KTask/GetAll" ) else {
                print("Invalid URL")
                return []
            }
            let request = URLRequest(url: url)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    
                    print("data: \(data) \(Date())")
                                do {
                                    let response = try JSONDecoder().decode(Task.self, from: data)
                                    print("is this called?")
                                    DispatchQueue.main.async {
                                        
                                        self.results = response.tasks
                                        
                                        addCat()
                                    }
                                    // print("response: \(response)")
                                    
                                    return
                                    
                                }catch {
                                    print ("\(error)")
                                }
//                    print("data: \(data) \(Date())")
//                    if let response = try?  JSONDecoder().decode(Task.self, from: data) {
//                        print("is this called?")
//                        DispatchQueue.main.async {
//                            self.results = response.tasks
//                            print("in here")
//                        }
//                        print("response: \(response)")
//                        return
//                    }
                }
                else{
                    print("I failed")
                }
            }.resume()
        
        return results
    }
}

#Preview {
    RaokItemView()
}
