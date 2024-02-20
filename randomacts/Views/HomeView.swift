//
//  HomeView.swift
//  randomacts
//
//  Created by roger deutsch on 1/23/24.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @State private var currentQuote = ""
    @State private var lastQuoteDate = ""
    @State private var quoteAuthor = ""
    @State private var lastGotQuoteDate: String? = nil
    @State private var Days7 = 0
    @State private var Days30 = 0
    @State private var Days90 = 0
    
    
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
            
            DisclosureGroup("Quote of the Day", isExpanded: parentView.$isQuoteDisplayed){
                Text(currentQuote).font(.title)
                Text(quoteAuthor).font(.title2)
            }
            .onAppear(){
                    setQuote()
                }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    print("i'm active!")
                    setQuote()
                }
            }
            DisclosureGroup("Usage Statistics"){
                Text("Your Completed Task Counts")
                Grid {
                    GridRow {
                        Image(systemName: "checkmark.square")
                        Text("7 Days")
                        Text("     \(Days7)")
                    }
                    GridRow {
                        Image(systemName: "checkmark.square")
                        Text("30 Days")
                        Text("     \(Days30)")
                    }
                    GridRow{
                        Image(systemName: "checkmark.square")
                        Text("90 Days")
                        Text("     \(Days90)")
                    }
                }.onAppear{
                    let stats = Statitiscs()
                    stats.GetUserStats(displayUserStats: displayUserStats, userId: parentView.localUser?.user.id ?? 0)
                }
                Text("Group Stats")
                Text("User ZZZ has completed X Tasks in the last 7 days.")
            }
            .onTapGesture {
                print("you been tapped!")
                
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
    
    func setQuote(){
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let currentDate = formatter.string(from: Date.now)
        print("currentDate: \(currentDate)")
        if !HasDailyQuoteBeenRetrieved(currentDate:currentDate){
            print("Retrieving quote for \(currentDate)")
            let q = QuoteX()
            q.GetQuote(setQuote: setQuoteText, iso8601Date: currentDate)
        }
        else{
            currentQuote = UserDefaults.standard.string(forKey: "currentQuote") ?? ""
            quoteAuthor = UserDefaults.standard.string(forKey: "quoteAuthor") ?? ""
            // handle situation if the user defaults are set wrong
            if currentQuote == "" && quoteAuthor == ""{
                let q = QuoteX()
                q.GetQuote(setQuote: setQuoteText, iso8601Date: currentDate)
            }
        }
    }
    
    func HasDailyQuoteBeenRetrieved(currentDate: String) -> Bool{
        lastGotQuoteDate = UserDefaults.standard.string(forKey: "gotQuoteDate")
        if (lastGotQuoteDate == nil){
            UserDefaults.standard.setValue(currentDate, forKey: "gotQuoteDate")
            return false
        }
        print("last: \(lastGotQuoteDate ?? "") -- current: \(currentDate)")
        if lastGotQuoteDate == currentDate{
            return true
        }
        UserDefaults.standard.setValue(currentDate, forKey: "gotQuoteDate")
        return false
    }
    
    func setQuoteText(quote: String, author: String){
        currentQuote = quote
        quoteAuthor = "~ " + author
        UserDefaults.standard.setValue(currentQuote, forKey:"currentQuote")
        UserDefaults.standard.setValue(quoteAuthor, forKey:"quoteAuthor")
    }
    
    func displayUserStats(taskCounts: [Int]){
        print("taskCounts: \(taskCounts)")
        Days7 = taskCounts[0]
        Days30 = taskCounts[1]
        Days90 = taskCounts[2]
    }
}

#Preview {
    HomeView(ContentView())
}
