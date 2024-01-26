//
//  UserTaskView.swift
//  randomacts
//
//  Created by roger deutsch on 1/26/24.
//

import SwiftUI

struct UserTaskView: View {
    var userTask : UserTask
    
    var body: some View {
        Text("ID: \(userTask.id)")
        Text(userTask.note ?? "")
        
    }
}

#Preview {
    UserTaskView(userTask: UserTask())
}
