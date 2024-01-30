//
//  UserTaskView.swift
//  randomacts
//
//  Created by roger deutsch on 1/26/24.
//

import SwiftUI

struct UserTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userTask : UserTask?
    @Binding var didUpdate: Bool
        
    var body: some View {
        VStack
        {
            Text(userTask?.category ?? "")
                .foregroundStyle(Color.blue)
                .font(.subheadline)
            Spacer()
            Text(userTask?.subcategory ?? "")
                .foregroundStyle(Color.blue)
                .font(.subheadline)
            
            Text("\(userTask?.description ?? "" )")
                .foregroundStyle(Color.gray)
            Divider()
            
            TextEditor(text: Binding(get: { userTask?.note ?? "" }) {
                            userTask?.note = $0
                        })
                        .padding(.all, 7.0)
                        .opacity(0.80)
                        //.background(Color(red: 0.9, green: 0.9, blue: 0.2))
                        .background(Color.yellow)
            HStack{
                Button("Save"){
                    if (userTask?.note != ""){
                        updateUserTask(updateComplete, userTaskId: userTask!.id, note: userTask!.note!)
                    }
                    didUpdate = true
                    dismiss()
                }.buttonStyle(.bordered)
                Button("Cancel"){
                    didUpdate = false
                    dismiss()
                }.buttonStyle(.bordered)
            }
        }
        
    }
    
    func updateComplete(result: String){
        print("update completed: \(result)")
    }
}
                    
                    

struct PreviewHelper{
    @State static var ut1: UserTask? = UserTask() // this is used for the preview
    @State static var isUpdated: Bool = false
}

#Preview {
    UserTaskView(userTask: PreviewHelper.$ut1, didUpdate: PreviewHelper.$isUpdated)
}
