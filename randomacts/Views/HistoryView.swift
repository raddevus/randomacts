//
//  HistoryView.swift
//  randomacts
//
//  Created by roger deutsch on 1/23/24.
//

import SwiftUI

struct HistoryView: View {
    let parentView : ContentView
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isUserTaskViewShown = false
    @State var userTaskItem: UserTask?
    @State var didUpdate: Bool = false
    @State var currentSelectedItemId : Int64 = -1
    @State var textColor: Color = Color.black
    
    init(_ parentView: ContentView){
        self.parentView = parentView
    }
    
    var body: some View {
        
        NavigationStack{
            Form{
                Section{
                    VStack{

                        if parentView.isRetrievingData{
                            ProgressView("Retrieving UserTasks...")
                            Spacer()
                        }
                        
                        if parentView.currentUserTasks?.count ?? 0 > 0 {
                                List(parentView.currentUserTasks ?? [], id:\ .description){ item in
                                    VStack(alignment: .leading){
                                        Group{
                                            VStack{
                                                HStack{
                                                    Text("\(String(item.created?.prefix(10) ?? ""))")
                                                        .fontWeight(.bold)
                                                    Spacer()
                                                    Text("\(String(item.completed?.prefix(10) ?? ""))").fontWeight(.bold)
                                                }
                                                Text("\(item.description ?? "")")
                                                    .foregroundStyle(textColor)
                                                    .onAppear(){
                                                        setColorMode()
                                                    }
                                                Spacer()
                                                
                                                
                                            }
                                            if item.note == ""{
                                                Label("\(item.note ?? "")", systemImage: "note")
                                           }
                                            else{
                                                Label("\(item.note ?? "")", systemImage: "note.text")
                                            }
                                        }
                                        .foregroundStyle(getCompletedTaskStatus(userTask:item))
                                        Spacer()
                                        Divider()
                                    }.onTapGesture {
                                        print("item: \(item.id)")
                                        isUserTaskViewShown = true
                                        userTaskItem = item
                                    }.padding()
                                    .border(getCompletedTaskStatus(userTask: item))
                                    .onLongPressGesture{
                                        // Added this code for later user
                                        // with rating tasks.
                                        print("item.description: \(item.description) - \(item.id)")
                                    }
                                    
                                    
                                    .sheet(isPresented: $isUserTaskViewShown, onDismiss: didDismiss,
                                           content: {
                                        UserTaskView(userTask: $userTaskItem, didUpdate: $didUpdate )
                                    })
                                }
                                
                            }
                        else{
                            Text("No task history available")
                        }
                    }
                }
            }
            .navigationTitle("Task History")
            .toolbar{
                Button("Load Updates"){
                    print("do a thing")
                    loadUserTaskFromWebApi(pView: parentView,forceLoad: true)
                }
            }
        }.onAppear(perform: {
            loadUserTaskFromWebApi(pView: parentView,forceLoad: false)
            print("### ONAPPEAR HISTORYVIEW  ####")
            
        })
    }
    
    func setColorMode(){
        self.textColor = { if (colorScheme == .dark){ return Color.white}
            else{ return Color.black}
        }()
    }
    
    func getCompletedTaskStatus(userTask: UserTask) -> Color{
        if userTask.completed != nil && userTask.completed != ""{
            return Color.blue
        }
        else{
            return Color.green
        }
    }
    
    func didDismiss(){
        
        print("userTaskItem : \(userTaskItem?.note ?? "")")
        print ("## !!!COMPLETED!!! ## \(userTaskItem?.completed)")
        if didUpdate{
            if (userTaskItem?.id != nil){
                let removeId : Int = removeItemFromCurrentTasks(idToRemove: userTaskItem?.id ?? -1)
                
                if (removeId > -1){
                    parentView.currentUserTasks?.insert(userTaskItem!, at:removeId)
                }
            }
            loadUserTaskFromWebApi(pView: parentView, forceLoad: false)
        }
    }
    
    func removeItemFromCurrentTasks(idToRemove: Int64) -> Int{
        for x:Int in 0...(parentView.currentUserTasks?.count ?? 0){
            if (parentView.currentUserTasks?[x].id == idToRemove){
                parentView.currentUserTasks?.remove(at:x)
                return x
            }
        }
        return -1
    }
}

func loadUserTaskFromWebApi(pView: ContentView, forceLoad: Bool){
    if (!forceLoad){
        // check currentUserTasks
        // if they're already loaded then return
        if pView.currentUserTasks != nil{
            print("No need to load userTasks from WebAPI")
            return
        }
    }
    print("### LOADING userTasks from WebAPI!")
    pView.isRetrievingData = true
    let ut = LocalUserTask(pView.localUser?.user.id ?? 0)
    // only called if there is a valid userId
    if ut.userId != 0{
        ut.GetAll(pView: pView, saveUserTasks: saveUserTasks)
    }
}

func saveUserTasks(pView: ContentView, userTasks: [UserTask]){
    print("I'm in SAVEUSERTASKS!")
    pView.currentUserTasks = userTasks
    // Since we've saved all the UserTasks we now need to
    // load all the KTasks so we can remove the ones (UserTasks)
    // which the user has already selected.
    loadAllKTasks(pView.updateCurrentTask)
    print("globalTask is set!: \(pView.currentTaskText)")
    print("### getRandomTask() ####")
    pView.isRetrievingData = false
}

#Preview {
    HistoryView(ContentView())
        .previewDevice("iPhone 13")
        .previewDisplayName("iPhone 13")
}
