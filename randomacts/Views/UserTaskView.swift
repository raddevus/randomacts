//
//  UserTaskView.swift
//  randomacts
//
//  Created by roger deutsch on 1/26/24.
//

import SwiftUI

struct UserTaskView: View {
    @Binding var userTask : UserTask?
        
    var body: some View {
        Text("Screw you, Xcode")
        Group{
            Text("ID: \(userTask?.id ?? 0 )")
            TextEditor(text: Binding(get: { userTask?.note ?? "" }) {
                userTask?.note = $0
                print("userTask.note: \(userTask?.note)")
            })
            .padding(.all, 7.0)
            .opacity(0.80)
            //.background(Color(red: 0.9, green: 0.9, blue: 0.2))
            .background(Color.yellow)
            
//            Text("This is another control")
        }
    }
}

//#Preview {
//    @State var noteThing: String? = "this is note"
//    @State var ut: UserTask? = UserTask()
//    //UserTaskView(userTask: $ut)//, noteData: $noteThing)
//    UserTaskView(userTask: $ut, noteData: $noteThing)
//}
