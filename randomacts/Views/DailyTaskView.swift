//
//  DailyTaskView.swift
//  randomacts
//
//  Created by roger deutsch on 1/28/24.
//

import SwiftUI

struct DailyTaskView: View {
    
    let parentView : ContentView
    init(_ parentView: ContentView){
        self.parentView = parentView
    }
    
    var body: some View {
        Form{
            Section{
                Button("Get New Task"){
                    loadAllKTasks(parentView.updateCurrentTask)
                }.buttonStyle(.bordered)
            }
            Section{
                Text(parentView.currentTaskText).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            }
            
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Daily Task")
                    .font(.system(size: 22, weight: .bold))
            }
            
        }.onAppear(){
            print("doing the thing!")
            print ("currentTaskText: \(parentView.currentTaskText)")
            if (parentView.currentTaskText == ""){
                loadAllKTasks( parentView.updateCurrentTask)
                print("globalTask is set!: \(parentView.currentTaskText)")
                print("### getRandomTask() ####")
                
            }
        }
    }
}

#Preview {
    DailyTaskView(ContentView())
}
