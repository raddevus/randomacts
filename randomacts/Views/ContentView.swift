//
//  ContentView.swift
//  randomacts
//
//  Created by roger deutsch on 11/17/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isShowingDetailView = false
    @State private var currentTaskText = ""
    @State private var currentTask: KTask? = nil
    @State private var customTaskDescription = ""
    @State private var isQuoteDisplayed = true
    @State private var friendsAreDisplayed = true
    @State private var isShowingAlert = false
    @State private var dayNumber = 0
    @State private var screenName = ""
    private var sn = ""
    
     private var localUser: LocalUser?
        
    init() {
        print("init() is RUNNING...")
        self.localUser = createLocalUser()
        print("getting localUser...")
        
        print("got localUser....")
        print("screenName INIT(): \(screenName )")
    }
    
    func updateCurrentTask(_ ktask: KTask?){
        currentTask = ktask
        print ("currentTask items: \(String(describing: currentTask?.id)) - \(String(describing: currentTask?.description))")
    currentTaskText = currentTask?.description ?? ""
    }
    
    func calcDayNumber() -> Int{
        // this code is from:
        // https://www.epochconverter.com/daynumbers
        // I used https://swiftify.com/converter/code
        // to conver the Objective-C code to Swift
        var currentDay: Int
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "D"
        let date = Date()
        currentDay = Int(dateFormatter.string(from: date)) ?? 0
        return currentDay
    }
    
    func createLocalUser() -> LocalUser{
        let userData = UserDefaults.standard.data(forKey: "localUser")
        var user: LocalUser? = nil
        if (userData != nil){
            print("userData: \(String(decoding: userData ?? Data(), as: UTF8.self))")
            user  = try? JSONDecoder().decode(LocalUser.self, from: userData! )
            print("localUser LOADED! -> \(user?.user.guid ?? "fail")")
        }
        
        if (user == nil){
            user = LocalUser()
            
            user?.Save(saveUser: saveUserToUserDefaults)
            
            print("localUser created -> \(user!.user.guid)")
        }
        
        return user!
    }
    
    func saveUserToUserDefaults(inUser: LocalUser){
        print (" ## saveUserToUserDefaults ##")
        let outdata = (try? JSONEncoder().encode(inUser)) ?? Data()
        print("saveUserToDefaults -> \(String(decoding: outdata, as: UTF8.self))")
        if let data = try? JSONEncoder().encode(inUser) {
            UserDefaults.standard.set(data, forKey: "localUser")
        }
    }
    
    func updateUserScreenName(inUser: LocalUser){
        print (" ## updateUserScreenName ##")
        var user: LocalUser? = nil
        let userData = UserDefaults.standard.data(forKey: "localUser")
        
        if (userData != nil){
            print("userData: \(String(decoding: userData ?? Data(), as: UTF8.self))")
            user  = try? JSONDecoder().decode(LocalUser.self, from: userData! )
            print("localUser LOADED! -> \(user?.user.guid ?? "fail")")
        } 
        
        user?.user.screenName = inUser.user.screenName
        saveUserToUserDefaults(inUser: user!)
    }
    
    func getUserInfo(){
        let userData = UserDefaults.standard.data(forKey: "localUser")
        
        if (userData != nil){
            print("userData: \(String(decoding: userData ?? Data(), as: UTF8.self))")
        }
    }
    
    var body: some View {
        
        TabView{
            NavigationStack{
                Form{
                    Button("Remove UserData"){
                        UserDefaults.standard
                            .removeObject(forKey: "localUser")
                        print("removed the localUser")
                    }
                    Button("Create User"){
                        createLocalUser()
                    }
                    Button("Get User Info"){
                        getUserInfo()
                        print("screenName 1: \(screenName)")
                    }
                    DisclosureGroup("Random Acts Info"){
                        Text("Random Acts of Kindness helps create the opportunity to be more intentional about completing small, positive tasks that benefit others.")
                        
                    }
                    DisclosureGroup("Random Acts Tasks Explained"){
                        Text("While each individual task might only take a few moments or cost a few dollars, the cumulative impact of your efforts, and the efforts of others using this app, will undoubtedly make the world a more positive place! In addition, research suggests completing tasks like these is likely to strength your connections with others, improve your mood, and possibly your health. If you are ready, then let's get started!")
                    }
                    Text(Date.now.formatted())
                    DisclosureGroup("Quote of the Day", isExpanded: $isQuoteDisplayed){
                        Text("The reasonable man adapts himself to the world: the unreasonable one persists in trying to adapt the world to himself. Therefore all progress depends on the unreasonable man.").font(.callout)
                        Text("~George Bernard Shaw").font(.title2)
                        Text("NOTE: a new quote will be retrieved from the WebAPI every day (12am local time) and displayed here.").font(.footnote)
                    }.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    Button("View Master List of KTasks"){
                        isShowingDetailView.toggle()
                        
                    }.buttonStyle(.bordered)
                        .sheet(isPresented: $isShowingDetailView, content: {
                            RaokItemView( )
                        })
                    Text("Allowing users to view the list of tasks will help them decide if they want to use the app. -- but they will also be")
//                    Section{
//                        Button("Show Current Task"){
//                            loadData(updateLocal)
//                        }.buttonStyle(.bordered)
//                        Text("Test -> \(currentTaskText)")
//                        
//                    }
                    
                    
                }.toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Random Acts of Kindness")
                            .font(.system(size: 22, weight: .bold))
                    }
                }.font(.system(size:20))
                
            }.tabItem{
                Label("Main", systemImage:"house")
            }
            
            // Begin 2nd Tab
            NavigationStack{
                Form{
                    Section{
                        Button("Get New Task"){
                            loadAllKTasks(updateCurrentTask)
                        }.buttonStyle(.bordered)
                    }
                    Section{
                        Text(currentTaskText).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    }
                    
                }.toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Daily Task")
                            .font(.system(size: 22, weight: .bold))
                    }
                    
                }.onAppear(){
                    print("doing the thing!")
                    print ("currentTaskText: \(currentTaskText)")
                    if (currentTaskText == ""){
                        
                         
//                        DispatchQueue.main.async {              loadData()
//                            
//                        }
                        loadAllKTasks( updateCurrentTask)
                        print("globalTask is set!: \(currentTaskText)")
                        print("### getRandomTask() ####")
                        //getRandomTask()
                        
                    }
                }
            }
                .tabItem{
                    Label("Daily Task", systemImage:"calendar")
                }
            // END 2nd TAB
            
            // Begin 3rd Tab
            NavigationStack{
                Form{
                    Text("Custom Tasks")
                    TextField("Task description", text: $customTaskDescription)
                    Text("we will add a form which will allow the user to add custom tasks that have arisen in her own life & she has completed")
                    Text("Those tasks will be added to her history list so she can mark them as completed to create a journal of her kindess")
                }.toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Custom Tasks")
                            .font(.system(size: 22, weight: .bold))
                    }
                }
            }.tabItem{
                Label("Custom Task", systemImage:"note.text.badge.plus")
            }
            // End 3rd Tab
            
            // Begin 4th tab
            NavigationStack{
                Form{
                    Text("Task History")
                    Section{
                        Text("This will include the list of tasks the user has chosen, associated date they took the task on and a [ ] completed check box to indicate if they completed it")
                        Text("Day Number: \(dayNumber)")
                        Button("Calc DayNumber"){
                            dayNumber = calcDayNumber()
                        }
                        Button("GetQuote"){
                            let q = QuoteX()
                            //q.GetQuote(iso8601Date: "2024-01-01")
                            q.Gen1()
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
            }.tabItem{
                Label("History", systemImage: "list.bullet")
            }
            // End 4th tab
            
            // Begin 5th tab
            NavigationStack{
                Form{
                    Text("Profile")
                    Text("ScreenName: \(screenName)")
                    
                    Text("userid: \(self.localUser!.user.guid)")
                    TextField(
                        "screenName",
                        text: $screenName)
                    Button("Save User Data"){
                        // localUser?.Save()
                        localUser!.user.screenName=screenName
                        //saveUserToUserDefaults(user: localUser!)
                        localUser!.Save(saveUser:updateUserScreenName, isScreenName: true)
                        screenName = localUser!.user.screenName
                    }.buttonStyle(.bordered)
                    Section{
                        Button("Add Friend"){
                            isShowingAlert = true
                        }.alert("TBD - Add Friend Code", isPresented: $isShowingAlert){
                            Button("OK"){
                                
                            }
                            Button("Delete", role:.destructive){}
                            Button("Cancel", role:.cancel){}
                        } message:{
                            Text("Click any button, just a test")
                        }
                        
                        DisclosureGroup("List of Friends", isExpanded: $friendsAreDisplayed){
                            DisclosureGroup("Billy-Bob Haskell"){
                                Text("Member since: 2023-05-11")
                                Text("Tasks completed: 0")
                                Text("Last task copleted: ")
                                
                            }
                            DisclosureGroup("John Johnason"){
                                Text("Member since: 2023-09-24")
                                Text("Tasks completed: 12")
                                Text("Last task completed: ")
                            }
                        }
                    }
                }
                .onAppear(){
                    print("displaying PROFILE!")
                    print ("PROFILE screenName: \(screenName)")
                    screenName = localUser!.user.screenName
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Profile")
                            .font(.system(size: 22, weight: .bold))
                    }
                }
            }.tabItem{
                Label("Profile", systemImage: "person")
            }
        }
        }
        

}

#Preview {
    ContentView()
}
