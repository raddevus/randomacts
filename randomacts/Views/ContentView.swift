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
    
    @State public var colorTheme = ColorScheme.light
    @State public var isDarkMode = false
    @State public var guidForLoadUser = ""
    @State public var isShowingGuidError = false
    @State public var currentUserTasks: [UserTask]? = nil
    @State public var isRetrievingData = false
 
    @State public var screenName = ""
    @State public var email = ""
    @State public var password = ""
    @State public var groupName = ""
    @State public var groupPwd = ""
    @State public var isGroupCreateError = false
    @State public var toastMessage = ""
    @State public var displayToast = false
    
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
        self.screenName = inUser.user.screenName ?? ""
        self.email = inUser.user.email ?? ""
        self.password = inUser.user.pwdHash ?? ""
        print("[[[[ user id: \(inUser.user.id) ]]]]")
        if inUser.user.id == 0{
            showToastWithMessage("No valid user was loaded. Please try again with valid GUID & Password.")
        }
        else{
            showToastWithMessage("The account was successfully loaded.")
        }
    }
    
    func showToastWithMessage(_ message: String) {
        toastMessage = message
        displayToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            displayToast = false
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
        user?.user.email = inUser.user.email
        user?.user.pwdHash = inUser.user.pwdHash
        self.screenName = user?.user.screenName ?? ""
        self.email = user?.user.email ?? ""
        self.password = user?.user.pwdHash ?? ""
        saveUserToUserDefaults(inUser: user!)
    }
    
    func getUserInfo() -> LocalUser?{
        let userData = UserDefaults.standard.data(forKey: "localUser")
        
        if (userData != nil){
            print("userData: \(String(decoding: userData ?? Data(), as: UTF8.self))")
        }

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
        if UUID(uuidString: self.guidForLoadUser) == nil{
            isShowingGuidError = true
            return
        }
        localUser = LocalUser(uuid:guidForLoadUser)
        guidForLoadUser = ""
        localUser?.Save(saveUser: saveUserToUserDefaults,
                        isScreenName: false,
                        password: password)
        
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
// ###################################################
// 2025-04-19 - REMOVING Tab 3 will add back in later
/*            NavigationStack{
                CustomTaskView(self)
            }.tabItem{
                Label("Custom Task", systemImage:"note.text.badge.plus")
            }
 */           // End 3rd Tab
// ########  END OF REMOVED TAB CODE ################            
            // HISTORY VIEW - tab 4
            NavigationStack{
                HistoryView(self)
            }.tabItem{
                Label("History", systemImage: "list.bullet")
            }
            // End 4th tab
            
            // Begin 5th tab
            NavigationStack{
                ProfileView(self)
            }.tabItem{
                Label("Profile", systemImage: "person")
            }
        }.overlay(
            Group {
                if displayToast {
                    
                    Text(toastMessage)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.opacity)
                        .animation(.easeInOut, value: displayToast)
                }
            }
        )
        .onAppear{
            setColorTheme()
            print("displaying PROFILE!")
            if (localUser == nil){
                localUser = getUserInfo()
            }
            screenName = localUser?.user.screenName ?? ""
            password = localUser?.user.pwdHash ?? ""
            email = localUser?.user.email ?? ""
            print ("PROFILE screenName: \(screenName)")
        }
        .environment(\.colorScheme, $colorTheme.wrappedValue)
        }
}

#Preview {
    ContentView()
        
        //.environment(\.colorScheme, .dark)
        //.environment(\.colorScheme, .dark)
}
