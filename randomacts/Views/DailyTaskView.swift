//
//  DailyTaskView.swift
//  randomacts
//
//  Created by roger deutsch on 1/28/24.
//

import SwiftUI

struct DailyTaskView: View {
    @Environment(\.scenePhase) var scenePhase
    let parentView : ContentView
    
    @State private var currentQuote = ""
    @State private var lastQuoteDate = ""
    @State private var quoteAuthor = ""
    @State private var lastGotQuoteDate: String? = nil
    
    init(_ parentView: ContentView){
        self.parentView = parentView
        if (parentView.currentUserTasks == nil){
            loadAllKTasks(parentView.updateCurrentTask)
        }
        
        loadUserTaskFromWebApi(pView: parentView,forceLoad: false)
        
        if parentView.currentUserTasks != nil{
            removeUserSelectedTasks(allUserTasks: parentView.currentUserTasks!)
            print("KTask count: \(allKTasks.count)")
        }
        
    }
    
    var body: some View {
        Form{
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
        }
        
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
}

#Preview {
    DailyTaskView(ContentView())
}
