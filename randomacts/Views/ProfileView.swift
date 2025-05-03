//
//  ProfileView.swift
//  randomacts
//
//  Created by roger deutsch on 4/24/25.
//

import SwiftUI

struct ProfileView: View {
    
    let pv : ContentView
    @State var currentGroups = [KGroup]()
    @State var groupGuid : String = ""
    @State private var hiddenGroupGuid: [String] = []
    @State private var showGuidCopyToast = false
    @State private var toastMessage = ""
    @State private var bgColor : Color
    @State private var fgColor : Color
    
    init(_ parentView: ContentView){
        self.pv = parentView
        bgColor = Color.blue
        fgColor = Color.white
        print("\(bgColor) : \(fgColor) ")
    }
    
    var body: some View {
        Form{
            Section{
                HStack{
                    Label("Screen Name", systemImage: "person.crop.circle")
                    TextField(
                        "screenName",
                        text: pv.$screenName)
                }
                HStack{
                    Label("UserId:", systemImage: "person.text.rectangle")
                    Text("\(pv.localUser?.user.guid ?? "")")
                }
                HStack{
                    Label("Email:", systemImage: "mail")
                    TextField("email", text:pv.$email)
                }
                HStack{
                    Label("Password:", systemImage:"lock.shield")
                    TextField("password", text: pv.$password)
                }
                
                Button("Save User Data"){
                    pv.localUser!.user.screenName=pv.screenName
                    pv.localUser!.Save(saveUser: pv.updateUserScreenName, pwd: pv.password, email: pv.email)
                }.buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, alignment: .center)
                
            }
            Section{
                DisclosureGroup("Group Membership"){
                    Text("Add A Group")
                    VStack{
                        TextField("Name", text: pv.$groupName)
                        TextField("Password", text:pv.$groupPwd)
                        TextField("Group Guid", text:$groupGuid);
                        HStack{
                            Button("Create"){
                                if pv.groupName == "" || pv.groupPwd == ""{
                                    pv.isGroupCreateError = true
                                }
                                var group = LocalGroup()
                                group.CreateGroup(GroupCreated: pv.GroupCreated, userId: pv.localUser?.user.id ?? 0, groupName: pv.groupName, pwd: pv.groupPwd)
                            }.buttonStyle(.bordered)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                            Button("Join"){
                                print("Join group ...")
                            }.buttonStyle(.bordered)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .alert("Name or Password Not Set!", isPresented: pv.$isGroupCreateError){
                            Button("OK"){
                                //add extra functionality when user clicks OK
                            }
                                                               } message:{
                            Text("Please make sure you provide a group name and password.  Try again.")
                        }

                    }
                    DisclosureGroup("Member Groups (* Owner)"){
                        VStack{
                            List( currentGroups.indices,id: \.self){ index in
                                let item = currentGroups[index]
                                Text("\(item.name)\(item.ownerId == (pv.localUser?.user.id ?? 0) ? " *" : "")").onAppear{
                                    print("counting : \(hiddenGroupGuid.count)")
                                    hiddenGroupGuid.insert("\(item.guid):\(item.name)",at:0)
                                }.onTapGesture {
                                    setGroupValues(hiddenGroupGuid, index)
                                }
                                
                            }
                            
                        }.onAppear(perform:{
                            var group = LocalGroup()
                            var allGroups: [KGroup] = []
                            group.GetMemberGroups(RetrievedGroups:RetrievedGroups, userGuid: pv.localUser?.user.guid ?? "")
                        }
                                   
                        )
                        
                    }

                }
            }
            TextField("GUID", text: pv.$guidForLoadUser)
                .textInputAutocapitalization(.never)
                .onSubmit{
                    pv.processGuidEntry()
                }
            Button("Load User From GUID"){
                pv.processGuidEntry()
            }.buttonStyle(.bordered)
                .alert("GUID Is Invalid!", isPresented: pv.$isShowingGuidError){
                    Button("OK"){
                        pv.guidForLoadUser = ""
                    }
                } message:{
                    Text("Please enter a valid GUID & try again. (A valid GUID will be exactly 36 characters long & contain numbers, dashes & only lowercase characters.)")
                }
            Toggle(isOn: pv.$isDarkMode){
                Text("Dark Mode")
            }.onChange(of: pv.isDarkMode){
                if (pv.isDarkMode){
                    pv.colorTheme = .dark
                }
                else{
                    pv.colorTheme = .light
                }
                UserDefaults.standard.setValue(pv.isDarkMode, forKey: "isDarkMode")
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Profile")
                    .font(.system(size: 22, weight: .bold))
            }
        }.overlay(
            Group {
                if showGuidCopyToast {
                    
                    Text(toastMessage)
                        .padding()
                        .background(self.bgColor)
                        .foregroundColor(self.fgColor)
                        .cornerRadius(8)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showGuidCopyToast)
                }
            }
        )
    }
    
    func setGroupValues(_ hiddenGroupGuid: [String], _ index: Int){
        print("index: \(index) : \(hiddenGroupGuid[index])")
        UIPasteboard.general.string = String(hiddenGroupGuid[index].split(separator: ":")[0])
        showToastWithMessage("Copied Group GUID for  \(hiddenGroupGuid[index].split(separator: ":")[1]) to clipboard.")
    }
    
    func getColorsForToast(){
        print("pv.colorTheme: \(pv.colorTheme)")
        if pv.colorTheme == .dark {
            print("it's dark - setting white")
            self.bgColor = Color.white.opacity(0.8)
            self.fgColor = Color.black
        }
        else{
            self.bgColor = Color.black.opacity(0.8)
            self.fgColor = Color.white
        }
    }
    func showToastWithMessage(_ message: String) {
        toastMessage = message
        showGuidCopyToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showGuidCopyToast = false
        }
    }
    
    func RetrievedGroups(allGroups: [KGroup]){
        if allGroups.count > 0 {
            print("allGroups: \(allGroups.count) : \(allGroups[0].name)")
        }
        currentGroups = allGroups

    }
}

#Preview {
    ProfileView(ContentView())
}
