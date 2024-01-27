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
    @State private var currentSelectedItem: UserTask = UserTask()
    
    init(_ parentView: ContentView){
        self.parentView = parentView
        //self.currentSelectedItem = UserTask()
    }
    @State public var userTasks: [UserTask]?
    
    static var utItem: UserTask?
    
    @State var userTaskItem: UserTask?
    
    @State var noteHolder: String?
    
    var body: some View {
        Form{
            Text("Task History")
            Section{
                Text("This will include the list of tasks the user has chosen, associated date they took the task on and a [ ] completed check box to indicate if they completed it")
                Button("Get Tasks"){
                    let ut = LocalUserTask(parentView.localUser?.user.id ?? 0)
                    ut.GetAll(saveUserTasks: saveUserTasks)
                    //let q = QuoteX()
                    //q.GetQuote(iso8601Date: "2024-01-01")
                    //q.Gen1()
                    print("#########")
                    //q.Gen2()
                    // q.Gen3()
                    //q.GetQuote(iso8601Date: "2023-01-01")
                }.buttonStyle(.bordered)
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Task History")
                    .font(.system(size: 22, weight: .bold))
            }
        }
        
        NavigationStack{
            Form{
                
                Section{
                    VStack{
                        List(userTasks ?? [], id:\ .description){ item in
                            VStack(alignment: .leading){
                                HStack{
                                    Text("\(item.category ?? "") " ).foregroundStyle( Color.red)
                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                    Text("\(item.subcategory ?? "")").foregroundStyle(Color.blue)
                                    Text("\(item.description ?? "")")
                                    Spacer()
                                    
                                }
                                Divider()
                            }.onTapGesture {
                                print("item: \(item.id)")
                                isUserTaskViewShown = true
                                self.currentSelectedItem = item
                                HistoryView.utItem = item
                                noteHolder = item.note
                                userTaskItem = item
                            }
                            
                            .sheet(isPresented: $isUserTaskViewShown, onDismiss: didDismiss,
                                   content: {
                                // UserTaskView(userTask: HistoryView.utItem ?? UserTask(), noteData: $noteHolder)
                                UserTaskView(userTask: $userTaskItem, noteData: $noteHolder)
                           })
                            
                            
                            
                            
                        }
                    }
                }
            }.onAppear(perform: {
                                
                
            })
                .navigationTitle("KTasks")
        }
    }
    
    func didDismiss(){
        print("note is now: \(HistoryView.utItem?.note)")
        print("#### NOTEHOLDER ##### \(noteHolder)")
    }
    
    func saveUserTasks(userTasks: [UserTask]){
        print("I'm in SAVEUSERTASKS!")
        self.userTasks = userTasks
        if (self.userTasks!.count > 0){
            HistoryView.utItem = self.userTasks![0]
        }
        
    }

}


#Preview {
    HistoryView(ContentView())
}
