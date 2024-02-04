//
//  ContentView.swift
//  randomacts
//
//  Created by roger deutsch on 11/17/23.
//

import SwiftUI

struct ContentView: View {
    
    @State public var isShowingDetailView = false
    @State public var currentTaskText = ""
    @State public var currentTask: KTask? = nil
    @State public var customTaskDescription = ""
    @State public var isQuoteDisplayed = true
    @State private var friendsAreDisplayed = true
    @State private var isShowingAlert = false
    @State private var dayNumber = 0
    @State public var screenName = ""
    @State public var email = ""
    @State public var password = ""
    @State private var colorTheme = ColorScheme.light
    @State private var isDarkMode = false
    @State private var guidForLoadUser = ""
    @State private var isShowingGuidError = false
    @State public var currentUserTasks: [UserTask]? = nil
    @State public var isRetrievingData = false
    
    @State public var localUser: LocalUser?
        
    init() {
        print("####### BEGIN ########")
        print("init() is RUNNING...")
        self.localUser = createLocalUser()
        print("getting localUser...")
        
        print("got localUser....")
        print("screenName INIT(): \(screenName )")
        
    }
    
    func setColorTheme(){
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        print("READ isDarkMode \(isDarkMode)")
        if (isDarkMode){
            colorTheme = .dark
        }
        else{
            colorTheme = .light
        }
    }
    
    func updateCurrentTask(_ ktask: KTask?, _ removeTasks: Bool=false){
        currentTask = ktask
        print ("currentTask items: \(String(describing: currentTask?.id)) - \(String(describing: currentTask?.description))")
        currentTaskText = currentTask?.description ?? ""
        
        if removeTasks && currentUserTasks != nil{
            removeUserSelectedTasks(allUserTasks: currentUserTasks!)
        }
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
        self.screenName = inUser.user.screenName
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
        self.screenName = user?.user.screenName ?? ""
        saveUserToUserDefaults(inUser: user!)
    }
    
    func getUserInfo() -> LocalUser?{
        let userData = UserDefaults.standard.data(forKey: "localUser")
        
        if (userData != nil){
            print("userData: \(String(decoding: userData ?? Data(), as: UTF8.self))")
        }
        let localDark = UserDefaults.standard.bool(forKey: "isDarkMode")
        print("localDark : \(localDark)")
        if (userData != nil){
            return try? JSONDecoder().decode(LocalUser.self, from: userData! )
        }
        return LocalUser()
    }
    
    func processGuidEntry(){
        if guidForLoadUser.count != 36{
            isShowingGuidError = true
            return
        }
        localUser = LocalUser(uuid:guidForLoadUser)
        guidForLoadUser = ""
        localUser?.Save(saveUser: saveUserToUserDefaults)
        
        // empty userTasks so they'll be loaded again.
        currentUserTasks = nil
        // empty the currentTaskText & KTasks so all will be reloaded
        currentTaskText = ""
        allKTasks.removeAll()
    }
    
    var body: some View {
        
        TabView{
            // HOME VIEW - tab 1
            NavigationStack{
                HomeView(self)
            }.tabItem{
                Label("Main", systemImage:"house")
            }
            
            // Begin 2nd Tab
            NavigationStack{
                DailyTaskView(self)
            }
                .tabItem{
                    Label("Daily Task", systemImage:"calendar")
                }
            // END 2nd TAB
            
            // ## CUSTOM TASK VIEW - tab 3
            NavigationStack{
                CustomTaskView(self)
            }.tabItem{
                Label("Custom Task", systemImage:"note.text.badge.plus")
            }
            // End 3rd Tab
            
            // HISTORY VIEW - tab 4
            NavigationStack{
                HistoryView(self)
            }.tabItem{
                Label("History", systemImage: "list.bullet")
            }
            // End 4th tab
            
            // Begin 5th tab
            NavigationStack{
                Form{
                    HStack{
                        Label("Screen Name", systemImage: "person.crop.circle")
                        TextField(
                            "screenName",
                            text: $screenName)
                    }
                    HStack{
                        Label("UserId:", systemImage: "person.text.rectangle")
                        Text("\(self.localUser?.user.guid ?? "")")
                    }
                    HStack{
                        Label("Email:", systemImage: "mail")
                        TextField("email", text:$email)
                    }
                    HStack{
                        Label("Password:", systemImage:"lock.shield")
                        TextField("password", text: $password)
                    }
                    
                    Button("Save User Data"){
                        // localUser?.Save()
                        localUser!.user.screenName=screenName
                        //saveUserToUserDefaults(user: localUser!)
                        localUser!.Save(saveUser:updateUserScreenName, isScreenName: true)
                        screenName = localUser?.user.screenName ?? ""
                    }.buttonStyle(.bordered)
                    TextField("GUID", text: $guidForLoadUser)
                        .textInputAutocapitalization(.never)
                        .onSubmit{
                            processGuidEntry()
                        }
                    Button("Load User From GUID"){
                        processGuidEntry()
                    }.buttonStyle(.bordered)
                        .alert("GUID Is Invalid!", isPresented: $isShowingGuidError){
                            Button("OK"){
                                guidForLoadUser = ""
                            }
                        } message:{
                            Text("Please enter a valid GUID & try again. (A valid GUID will be exactly 36 characters long & contain numbers, dashes & only lowercase characters.)")
                        }
                    Toggle(isOn: $isDarkMode){
                        Text("Dark Mode")
                    }.onChange(of: isDarkMode){
                        if (isDarkMode){
                            colorTheme = .dark
                        }
                        else{
                            colorTheme = .light
                        }
                        UserDefaults.standard.setValue(isDarkMode, forKey: "isDarkMode")
                    }
                    Section{
                        Button("Add Friend"){
                            isShowingAlert = true
                        }.alert("TBD - Add Friend Code", isPresented: $isShowingAlert){
                            Button("OK"){
                                
                            }
                            Button("Delete", role:.destructive){}
                            Button("Cancel", role:.cancel){}
                        } message:{
                            Spacer()
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
        .onAppear{
            setColorTheme()
            print("displaying PROFILE!")
            if (localUser == nil){
                localUser = getUserInfo()
            }
            screenName = localUser?.user.screenName ?? ""
            print ("PROFILE screenName: \(screenName)")
        }
        .environment(\.colorScheme, $colorTheme.wrappedValue)
        }
}

#Preview {
    ContentView()
        .previewDevice("iPhone 13")
        .previewDisplayName("iPhone 13")
        //.environment(\.colorScheme, .dark)
        //.environment(\.colorScheme, .dark)
}
