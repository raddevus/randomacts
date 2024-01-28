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
    @State public var userTasks: [UserTask]?
    @State var userTaskItem: UserTask?

    init(_ parentView: ContentView){
        self.parentView = parentView
    }
    
    var body: some View {
        
        NavigationStack{
            Form{
                Section{
                    VStack{

                            if userTasks?.count ?? 0 > 0 {
                                List(userTasks ?? [], id:\ .description){ item in
                                    VStack(alignment: .leading){
                                        HStack{
                                            Text("\(item.category ?? "") " ).foregroundStyle( Color.red)
                                                .fontWeight(.bold)
                                            Text("\(item.subcategory ?? "")").foregroundStyle(Color.blue)
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
            }.onAppear(perform: {
                let ut = LocalUserTask(parentView.localUser?.user.id ?? 0)
                // only called if there is a valid userId
                if ut.userId != 0{
                    ut.GetAll(saveUserTasks: saveUserTasks)
                }
                print("### ONAPPEAR HISTORYVIEW  ####")
                
            })
            //.navigationTitle("Task History")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Task History")
                        .font(.system(size: 22, weight: .bold))
                }
            }
        }
    }
    
    func didDismiss(){
        print("userTaskItem : \(userTaskItem?.note ?? "")")
    }
    
    func saveUserTasks(userTasks: [UserTask]){
        print("I'm in SAVEUSERTASKS!")
        self.userTasks = userTasks
    }
}

#Preview {
    HistoryView(ContentView())
        .previewDevice("iPhone 13")
        .previewDisplayName("iPhone 13")
}
