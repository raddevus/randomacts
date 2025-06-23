//
//  HomeView.swift
//  randomacts
//
//  Created by roger deutsch on 1/23/24.
//

import SwiftUI

struct HomeView: View {
    
   
    
    @State private var Days7 = 0
    @State private var Days30 = 0
    @State private var Days90 = 0
    @State private var groupStats: [KGroupStats] = []
    @State var isSavePresented = false
    @State private var userHasSelectedTask = false
    @State private var dailyTasksAvailable: Int = 0
    
    let instructions = [
            "Select a task from the list below.",
            "Complete the task In Real Life (IRL).",
            "Open the History tab & select the task",
            "Add notes about your experience.",
            "Set the task as Completed."
        ]
    
    let parentView : ContentView
    init(_ parentView: ContentView){
        self.parentView = parentView
        userHasSelectedTask = false
    }
    var body: some View {
        Form{
            DisclosureGroup("Random Acts Info"){
                Text("Random Acts of Kindness helps create the opportunity to be more intentional about completing small, positive tasks that benefit others.")
                
            }
            DisclosureGroup("Random Acts Tasks Explained"){
                Text("While each individual task might only take a few moments or cost a few dollars, the cumulative impact of your efforts, and the efforts of others using this app, will undoubtedly make the world a more positive place! In addition, research suggests completing tasks like these is likely to strength your connections with others, improve your mood, and possibly your health. If you are ready, let's get started!")
            }
            
            DisclosureGroup("Instructions") {
                VStack(alignment: .leading, spacing: 8) {
                 ForEach(Array(instructions.enumerated()), id: \.offset) { index, item in
                 Text("\(index + 1). \(item)")
                 .multilineTextAlignment(.leading)
                 .lineLimit(nil)
                 .fixedSize(horizontal: false, vertical: true)
                 .frame(maxWidth: .infinity, alignment: .leading)
                 //.padding(.leading, 30) // Indentation for wrapped lines
                 .textSelection(.enabled)
                 }
                 }
            }
            Section{
                Text("Daily Tasks")
                    if parentView.isRetrievingData{
                        ProgressView("Retrieving Tasks...")
                        Spacer()
                    }


                HStack{

                    Button("New Task", systemImage:"rosette"){
                        loadAllKTasks(parentView.updateCurrentTask)
                        userHasSelectedTask = false
                    }.buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Accept Task", systemImage:"square.and.arrow.up"){
                        if (parentView.localUser != nil){
                            let currentUserId = parentView.localUser?.user.id ?? 0
                            print ("#*#*#*#*  \(currentUserId) #*#*#*#*")
                            let currentTaskId = parentView.currentTask?.id ?? 0
    
                            if currentUserId > 0 && currentTaskId > 0{
                                acceptUserTask(ShowUserTaskResult, userId: currentUserId,
                                               taskId: currentTaskId)
                                userHasSelectedTask = true
                                removeUserTaskById(taskId: currentTaskId)
                            }
                            
                        }
                        else{
                            print ("#*#*#*#*  it was freaking NULL #*#*#*#*")
                        }
                    }.buttonStyle(.bordered)
                        .alert("Daily Task Saved", isPresented: $isSavePresented){
                            Button("OK"){
                                // set the currentUserTasks to nil
                                // so they will be loaded again
                                // with new one
                                // history tab is clicked by user again.
                                parentView.currentUserTasks = nil
                                userHasSelectedTask = false
                            }
                        } message:{
                            Text("DailyTask was saved to your UserTask History")
                        }
                }
                Text(parentView.currentTaskText)
                    .font(.title )
                    .fontWeight(userHasSelectedTask ? .ultraLight : .regular)
                    .foregroundStyle(userHasSelectedTask ? Color.gray : .primary )
                if userHasSelectedTask {
                    Text(Image(systemName:"checkmark.circle"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Text(Image(systemName:"tray.full"))
                + Text("  There are \(allKTasks.count) tasks available for selection.")
                    .font(.footnote)
            
            }.onAppear(){
                let currentUserId = parentView.localUser?.user.id ?? 0
                if currentUserId == 0{
                    parentView.localUser?.setNewAccount()
                    parentView.localUser?.Save(saveUser: parentView.saveUserToUserDefaults,
                                    isScreenName: false)
                }
                print("doing the thing!")
                print ("currentTaskText: \(parentView.currentTaskText)")
                if (parentView.currentTaskText == ""){
                    if (parentView.currentUserTasks == nil){
                        print(" ##### CURRENTUSERTASKS is NIL!!!!!! ######")
                        loadUserTaskFromWebApi(pView: parentView, forceLoad: false)
                    }
                }
                let ctt = parentView.currentTaskText
                parentView.currentTaskText = ""
                parentView.currentTaskText = ctt
            }
            
            DisclosureGroup("Usage Statistics"){
                Text("Your Completed Task Counts")
                Grid {
                    GridRow {
                        Image(systemName: "checkmark.square")
                        Text("7 Days")
                        Text("     \(Days7)")
                    }
                    GridRow {
                        Image(systemName: "checkmark.square")
                        Text("30 Days")
                        Text("     \(Days30)")
                    }
                    GridRow{
                        Image(systemName: "checkmark.square")
                        Text("90 Days")
                        Text("     \(Days90)")
                    }
                }.onAppear{
                    let stats = Statitiscs()
                    stats.GetUserStats(displayUserStats: displayUserStats, userId: parentView.localUser?.user.id ?? 0)
                    let group = LocalGroup()
                    group.GetMemberGroupsForStats(GroupStatsCompleted: displayUserGroupStats, ownerId: parentView.localUser?.user.id ?? 0)
                }
                if groupStats.count > 0{
                    VStack{
                        Text("Group Stats").bold()
                        HStack {
                            Text("User")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            HStack {
                                Spacer()
                                Text("7D")
                                Spacer()
                                Text("30D")
                                Spacer()
                                Text("90D")
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(Color.green)
                        .bold()
                        List(groupStats){ item in
                            
                            HStack{
                                Text("\(item.screenName)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack{
                                    Spacer()
                                    Text("\(item.counts[0])")
                                    Spacer()
                                    Text("\(item.counts[1])")
                                    Spacer()
                                    Text("\(item.counts[2])")
                                }.frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            
                            
                        }
                        
                    }
                }
            }
            Button("View Master List of KTasks"){
                parentView.isShowingDetailView.toggle()
                
            }.buttonStyle(.bordered)
                .sheet(isPresented: parentView.$isShowingDetailView, content: {
                    RaokItemView( )
                })
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Random Acts of Kindness")
                    .font(.system(size: 22, weight: .bold))
            }
        }.font(.system(size:20))
    }
    
    func ShowUserTaskResult(result: String){
        print("userTask Result: \(result)")
        isSavePresented = true
    }
    
    func displayUserStats(taskCounts: [Int]){
        print("taskCounts: \(taskCounts)")
        Days7 = taskCounts[0]
        Days30 = taskCounts[1]
        Days90 = taskCounts[2]
    }
    
    func displayUserGroupStats(groupStats: [KGroupStats]){
        self.groupStats = groupStats
        for groupStat in groupStats{
            print("groupStat: \(groupStat)")
        }
    }
}

#Preview {
    HomeView(ContentView())
}
