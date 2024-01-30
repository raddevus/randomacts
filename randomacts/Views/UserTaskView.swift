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
    @State var isCalendarVisible = false
    private var selectedDate: Date? {
        if userTask?.completed != nil && userTask?.completed != ""{
            let altTaskDate: String = (userTask?.completed!)! + "Z"
            var taskDate =  try! Date(altTaskDate, strategy: .iso8601)
            return Calendar.current.date(byAdding: .day, value: 1, to: taskDate)!
        }
        else{
            return nil
        }
    }
    
    private var selectedDateString: String{
        if selectedDate != nil{
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            return formatter.string(from: selectedDate!)
        }
        else{
            return ""
        }
    }
    @State public var dateHolder: Date = Date()
    
    var body: some View {
        VStack
        {
            HStack{
                Text(userTask?.category ?? "")
                    .foregroundStyle(Color.blue)
                    .font(.subheadline)
                Spacer()
                Text(userTask?.subcategory ?? "")
                    .foregroundStyle(Color.blue)
                    .font(.subheadline)
            }
            .padding()
            Text("\(userTask?.description ?? "" )")
                .foregroundStyle(Color.gray)
                .padding()
            Divider()
            if (selectedDateString != ""){
                HStack{
                    Label("Completed:", systemImage: "calendar")
                    Text("\(selectedDateString)")
                }.padding()
                Divider()
            }
            else{
                Group{
                    Toggle(isOn: $isCalendarVisible){
                        Text("Set Completed Date?")
                    }
                    if (isCalendarVisible){
                        DatePickerView()
                    }
                }.padding()
            }
            
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

struct DatePickerView: View {
    @State private var dateHolder: Date = Date()
    var body: some View{
        DatePicker(selection: $dateHolder, in: ...Date.now, displayedComponents: .date) {
            Text("Select a date")
        }
    }
}
                    
                    

struct PreviewHelper{
    @State static var ut1: UserTask? = UserTask() // this is used for the preview
    @State static var isUpdated: Bool = false
}

#Preview {
    UserTaskView(userTask: PreviewHelper.$ut1, didUpdate: PreviewHelper.$isUpdated)
}
