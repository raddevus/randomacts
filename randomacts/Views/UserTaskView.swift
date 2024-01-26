//
//  UserTaskView.swift
//  randomacts
//
//  Created by roger deutsch on 1/26/24.
//

import SwiftUI

struct UserTaskView: View {
    @State var userTask : UserTask
        
    var body: some View {
        Group{
            Text("ID: \(userTask.id)")
            TextEditor(text: Binding(get: { userTask.note ?? "" }) {
                userTask.note = $0
            })
            .padding(.all)
            .opacity(0.80)
            //.background(Color(red: 0.9, green: 0.9, blue: 0.2))
            .background(Color.yellow)
            
            Text("This is another control")
        }
    }
}

#Preview {
    UserTaskView(userTask: UserTask())
}
