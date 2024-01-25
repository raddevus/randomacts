//
//  HistoryView.swift
//  randomacts
//
//  Created by roger deutsch on 1/23/24.
//

import SwiftUI

struct HistoryView: View {
    let parentView : ContentView
    init(_ parentView: ContentView){
        self.parentView = parentView
    }
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
    }
}

func saveUserTasks(userTasks: [UserTask]){
    print("I'm in SAVEUSERTASKS!")
}

#Preview {
    HistoryView(ContentView())
}
