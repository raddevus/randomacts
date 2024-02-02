//
//  DailyTaskView.swift
//  randomacts
//
//  Created by roger deutsch on 1/28/24.
//

import SwiftUI

struct DailyTaskView: View {
    
    let parentView : ContentView
    @State var isSavePresented = false
    @State private var userSelectedTask = false
    @State private var dailyTasksAvailable: Int = 0
    
    init(_ parentView: ContentView){
        self.parentView = parentView
    }
    
    var body: some View {
        Form{
            Section{
                
            }
            Section{
                HStack{
                    
                    Button("New Task", systemImage:"rosette"){
                        loadAllKTasks(parentView.updateCurrentTask)
                        userSelectedTask = false
                    }.buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Accept Task", systemImage:"square.and.arrow.up"){
                        if (parentView.localUser != nil){
                            let currentUserId = parentView.localUser?.user.id ?? 0
                            let currentTaskId = parentView.currentTask?.id ?? 0
                            if currentUserId > 0 && currentTaskId > 0{
                                acceptUserTask(ShowUserTaskResult, userId: currentUserId,
                                               taskId: currentTaskId)
                                userSelectedTask = true
                                parentView.availTaskCount = removeUserTaskById(taskId: currentTaskId)
                            }
                            
                        }
                    }.buttonStyle(.bordered)
                        .alert("Daily Task Saved", isPresented: $isSavePresented){
                            Button("OK"){
                                // set the currentUserTasks to nil
                                // so they will be loaded again
                                // with new one
                                // history tab is clicked by user again.
                                parentView.currentUserTasks = nil
                            }
                        } message:{
                            Text("DailyTask was saved to your UserTask History")
                        }
                }
                Text(parentView.currentTaskText)
                    .font(.title )
                    .fontWeight(userSelectedTask ? .ultraLight : .regular)
                    .foregroundStyle(userSelectedTask ? Color.gray : .primary )
                if userSelectedTask {
                    Text(Image(systemName:"checkmark.circle"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                if (parentView.availTaskCount > -1){
                    Text(Image(systemName:"tray.full"))
                    + Text("  There are \(allKTasks.count) tasks available for selection.")
                        .font(.footnote)
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
                if (parentView.currentUserTasks == nil){
                    print(" ##### CURRENTUSERTASKS is NIL!!!!!! ######")
                    loadUserTaskFromWebApi(pView: parentView, forceLoad: false)
                }
                loadAllKTasks( parentView.updateCurrentTask)
                print("globalTask is set!: \(parentView.currentTaskText)")
                print("### getRandomTask() ####")
                
            }
        }
    }
    
    func ShowUserTaskResult(result: String){
        print("userTask Result: \(result)")
        isSavePresented = true
    }
}

#Preview {
    DailyTaskView(ContentView())
}
