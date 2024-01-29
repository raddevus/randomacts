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
                
            }
            Section{
                Text(parentView.currentTaskText)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer()
                HStack{
                    Image(systemName: "rosette")
                    Button("Get New Task"){
                        loadAllKTasks(parentView.updateCurrentTask)
                    }.buttonStyle(.bordered)
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                    Button("Accept Task"){
                        if (parentView.localUser != nil){
                            let currentUserId = parentView.localUser?.user.id ?? 0
                            let currentTaskId = parentView.currentTask?.id ?? 0
                            if currentUserId > 0 && currentTaskId > 0{
                                acceptUserTask(ShowUserTaskResult, userId: currentUserId,
                                               taskId: currentTaskId)
                            }
                        }
                    }.buttonStyle(.bordered)
                }
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
    
    func ShowUserTaskResult(result: String){
        print("userTask Result: \(result)")
    }
}

#Preview {
    DailyTaskView(ContentView())
}
