//
//  HomeView.swift
//  randomacts
//
//  Created by roger deutsch on 1/23/24.
//

import SwiftUI

struct HomeView: View {
    @State private var currentQuote = ""
    @State private var lastQuoteDate = ""
    @State private var quoteAuthor = ""
    
    
    let parentView : ContentView
    init(_ parentView: ContentView){
        self.parentView = parentView
    }
    var body: some View {
        Form{
            DisclosureGroup("Random Acts Info"){
                Text("Random Acts of Kindness helps create the opportunity to be more intentional about completing small, positive tasks that benefit others.")
                
            }
            DisclosureGroup("Random Acts Tasks Explained"){
                Text("While each individual task might only take a few moments or cost a few dollars, the cumulative impact of your efforts, and the efforts of others using this app, will undoubtedly make the world a more positive place! In addition, research suggests completing tasks like these is likely to strength your connections with others, improve your mood, and possibly your health. If you are ready, then let's get started!")
            }
            Text(Date.now.formatted())
            DisclosureGroup("Quote of the Day", isExpanded: parentView.$isQuoteDisplayed){
                Text(currentQuote).font(.callout)
                Text(quoteAuthor).font(.title2)
            }.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .onAppear(){
                    //check for quote
                }
            Button("View Master List of KTasks"){
                parentView.isShowingDetailView.toggle()
                
            }.buttonStyle(.bordered)
                .sheet(isPresented: parentView.$isShowingDetailView, content: {
                    RaokItemView( )
                })
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Random Acts of Kindness")
                    .font(.system(size: 22, weight: .bold))
            }
        }.font(.system(size:20))
        
    }
}

#Preview {
    HomeView(ContentView())
}
