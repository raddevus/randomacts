//
//  RaokItemView.swift
//  randomacts
//
//  Created by roger deutsch on 11/20/23.
//

import SwiftUI

struct RaokItemView: View {
    @State var results = [Action]()
    var body: some View {
        NavigationStack{
            Form{
                
                Section{
                    VStack{
                        List(results, id:\ .description){ item in
                            VStack(alignment: .leading){
                                HStack{
                                    Text("\(item.category ?? "") " ).foregroundStyle( Color.red)
                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                    Text("\(item.subCategory ?? "")").foregroundStyle(Color.blue)
                                    Text("\(item.description ?? "")")
                                    Spacer()
                                    
                                }
                                Divider()
                            }
                            
                        }
                    }
                }
            }.onAppear(perform:loadData)
                .navigationTitle("KTasks")
        }
    }
    
    func loadData() {
        print("loadData()...")
            guard let url = URL(string: "https://newlibre.com/kind/api/KTask/GetAll" ) else {
                print("Invalid URL")
                return
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
                                        //                            print("in here")
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
        }
}

#Preview {
    RaokItemView(results:[Action]())
}
