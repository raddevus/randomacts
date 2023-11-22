//
//  ContentView.swift
//  randomacts
//
//  Created by roger deutsch on 11/17/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingDetailView = false
    @State private var currentTaskText = ""
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    Text("Random Acts of Kindness helps create the opportunity to be more intentional about completing small, positive tasks that benefit others.")
                }
                Text("While each individual task might only take a few moments or cost a few dollars, the cumulative impact of your efforts, and the efforts of others using this app, will undoubtedly make the world a more positive place! In addition, research suggests completing tasks like these is likely to strength your connections with others, improve your mood, and possibly your health. If you are ready, then let's get started!")
                Text(Date.now.formatted())
                Button("Load KTasks"){
                    isShowingDetailView.toggle()
                    
                }
                .sheet(isPresented: $isShowingDetailView, content: {
                    RaokItemView( )
                })
                Section{
                    Button("Show Current Task"){
                        getRandomTask()
                    }
                    Text("Test -> \(currentTaskText)")
                    
                }
                    
                
            }.toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Random Acts of Kindness")
                        .font(.system(size: 22, weight: .bold))
                }
            }.font(.system(size:20))
                
        }
        
    }
    
    func getRandomTask(){
        if allDescriptions.count <= 0{
            currentTaskText = "No items loaded! Please run Load KTasks"
            return
        }
        var idx = Int.random(in: 0...allDescriptions.count-1)
        currentTaskText = Array(allDescriptions)[idx]
        
    }
}

#Preview {
    ContentView()
}
