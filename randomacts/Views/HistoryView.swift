//
//  HistoryView.swift
//  randomacts
//
//  Created by roger deutsch on 1/23/24.
//

import SwiftUI

struct HistoryView: View {
    let parentView : ContentView
    @State private var isUserTaskViewShown = false
    @State var userTaskItem: UserTask?

    init(_ parentView: ContentView){
        self.parentView = parentView
    }
    
    var body: some View {
        
        NavigationStack{
            Form{
                Section{
                    VStack{

                        if parentView.currentUserTasks?.count ?? 0 > 0 {
                                List(parentView.currentUserTasks ?? [], id:\ .description){ item in
                                    VStack(alignment: .leading){
                                        HStack{
                                            Text("\(String(item.created?.prefix(10) ?? "")) " ).foregroundStyle( Color.blue)
                                                .fontWeight(.bold)
                                            Text("\(item.description ?? "")")
                                            Spacer()
                                            
                                        }
                                        Divider()
                                    }.onTapGesture {
                                        print("item: \(item.id)")
                                        isUserTaskViewShown = true
                                        userTaskItem = item
                                    }
                                    
                                    .sheet(isPresented: $isUserTaskViewShown, onDismiss: didDismiss,
                                           content: {
                                        UserTaskView(userTask: $userTaskItem)
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
                    loadUserTaskFromWebApi(forceLoad: true)
                }
            }
        }.onAppear(perform: {
            loadUserTaskFromWebApi(forceLoad: false)
            print("### ONAPPEAR HISTORYVIEW  ####")
            
        })
    }
    
    func loadUserTaskFromWebApi(forceLoad: Bool){
        if (!forceLoad){
            // check currentUserTasks
            // if they're already loaded then return
            if parentView.currentUserTasks != nil{
                print("No need to load userTasks from WebAPI")
                return
            }
        }
        print("### LOADING userTasks from WebAPI!")
        let ut = LocalUserTask(parentView.localUser?.user.id ?? 0)
        // only called if there is a valid userId
        if ut.userId != 0{
            ut.GetAll(saveUserTasks: saveUserTasks)
        }
    }
    
    func didDismiss(){
        print("userTaskItem : \(userTaskItem?.note ?? "")")
    }
    
    func saveUserTasks(userTasks: [UserTask]){
        print("I'm in SAVEUSERTASKS!")
        parentView.currentUserTasks = userTasks
    }
}

#Preview {
    HistoryView(ContentView())
        .previewDevice("iPhone 13")
        .previewDisplayName("iPhone 13")
}
