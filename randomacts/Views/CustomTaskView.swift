//
//  CustomTaskView.swift
//  randomacts
//
//  Created by roger deutsch on 1/23/24.
//

import SwiftUI

struct CustomTaskView: View {
    let parentView : ContentView
    init(_ parentView: ContentView){
        self.parentView = parentView
    }
    var body: some View {
        Form{
            Text("Custom Tasks")
            TextField("Task description", text: parentView.$customTaskDescription)
            Text("we will add a form which will allow the user to add custom tasks that have arisen in her own life & she has completed")
            Text("Those tasks will be added to her history list so she can mark them as completed to create a journal of her kindess")
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Custom Tasks")
                    .font(.system(size: 22, weight: .bold))
            }
        }
    }
}

#Preview {
    CustomTaskView(ContentView())
}
