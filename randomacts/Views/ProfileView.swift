//
//  ProfileView.swift
//  randomacts
//
//  Created by roger deutsch on 4/24/25.
//

import SwiftUI

struct ProfileView: View {
    
    let pv : ContentView
    init(_ parentView: ContentView){
        self.pv = parentView
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
                        Button("Create"){
                            if pv.groupName == "" || pv.groupPwd == ""{
                                pv.isGroupCreateError = true
                            }
                            var group = LocalGroup()
                            group.CreateGroup(GroupCreated: pv.GroupCreated, userId: pv.localUser?.user.id ?? 0, groupName: pv.groupName, pwd: pv.groupPwd)
                        }
                        .alert("Name or Password Not Set!", isPresented: pv.$isGroupCreateError){
                                        Button("OK"){
                                            //add extra functionality when user clicks OK
                                        }
                                                                           } message:{
                                        Text("Please make sure you provide a group anme and password.  Try again.")
                                    }

                    }
                    DisclosureGroup("Member Groups"){
                        VStack{
                            
                        }.onAppear(perform:{
                            print("test")
                            var group = LocalGroup()
                            var allGroups: [KGroup] = []
                            group.GetMemberGroups(RetrievedGroups:self.RetrievedGroups, userGuid: pv.localUser?.user.guid ?? "", pwd: "Allgood")
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
        }
    }
    
    func RetrievedGroups(allGroups: [KGroup]){
        print("I'm doone!")
    }
}

#Preview {
    ProfileView(ContentView())
}
