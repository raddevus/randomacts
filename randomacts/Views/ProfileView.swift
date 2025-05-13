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
    @State private var showBarcode = false
    @State private var showUserIdBarcode = false
    @State public var currentGroupGuid: String = ""
    @State public var guidPopupMessage: String = ""
    @State public var groupErrorMsg: String = ""
    @State public var groupErrorAlertTitle = ""
    @State public var groupPopupTitle: String = ""
    @State public var userPassword: String = ""
    
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
                    Text("\(pv.localUser?.user.guid ?? "")").onTapGesture{
                        UIPasteboard.general.string = "\(pv.localUser?.user.guid ?? "")"
                        showToastWithMessage("Copied user GUID to the clipboard.")
                    }
                    
                    Image(systemName: "barcode.viewfinder")
                        .onTapGesture {
                            currentGroupGuid = "\(pv.localUser?.user.guid ?? "")"
                            guidPopupMessage = "Scan QR Code to share your UserId with another device."
                            groupPopupTitle = "UserId GUID"
                            showUserIdBarcode.toggle()
                            
                        }.sheet(isPresented: $showUserIdBarcode) {
                            BarcodePopupView(qrCodeText: $currentGroupGuid ,message: $guidPopupMessage,
                                title: $groupPopupTitle)
                            
                        }
                        .font(.system(size: 20))
                        .padding(2)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                HStack{
                    Label("Email:", systemImage: "mail")
                    TextField("email", text:pv.$email)
                }
                
                Button("Save User Data"){
                    pv.localUser!.user.screenName=pv.screenName
                    pv.localUser!.Save(saveUser: pv.updateUserScreenName, pwd: pv.password, email: pv.email)
                }.buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, alignment: .center)
                
            }
            Section{
                HStack{
                    Label("Password:", systemImage:"lock.shield")
                    TextField("password", text: pv.$password)
                    Button("Save"){
                        pv.localUser?.SetPassword(AfterPasswordSet: AfterPasswordSet, userGuid: pv.localUser!.user.guid, pwd: pv.password)
                    }
                }
            }
            Section{
                DisclosureGroup("Group Membership"){
                    Text("Add A Group")
                    VStack{
                        TextField("Name", text: pv.$groupName)
                        TextField("Password", text:pv.$groupPwd)
                        TextField("Group GUID", text:$groupGuid);
                        HStack{
                            Button("Create"){
                                if pv.groupName == "" || pv.groupPwd == ""{
                                    groupErrorAlertTitle = "Name or Password Not Set!"
                                    groupErrorMsg = "Please make sure you provide a group NAME and PASSWORD and try again. \nThe GUID will be generated for you."
                                    pv.isGroupCreateError = true
                                    return
                                }
                                var group = LocalGroup()
                                group.CreateGroup(GroupCreated: GroupCreated, userId: pv.localUser?.user.id ?? 0, groupName: pv.groupName, pwd: pv.groupPwd)
                            }.buttonStyle(.bordered)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                            Button("Join"){
                                if groupGuid == "" || pv.groupPwd == ""{
                                    groupErrorAlertTitle = "GUID or Password Not Set!"
                                    groupErrorMsg = "Please make sure you provide a group GUID and PASSWORD and try again."
                                    pv.isGroupCreateError = true
                                    return
                                    
                                }
                                JoinGroup()
                                
                            }.buttonStyle(.bordered)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .alert(groupErrorAlertTitle, isPresented: pv.$isGroupCreateError){
                            Button("OK"){
                                //add extra functionality when user clicks OK
                            }
                                                       } message:{
                            Text(groupErrorMsg)
                        }

                    }
                    DisclosureGroup("Member Groups (* Owner)"){
                        VStack{
                            List( currentGroups.indices,id: \.self){ index in
                                let item = currentGroups[index]
                                HStack{
                                    Text("\(item.name)\(item.ownerId == (pv.localUser?.user.id ?? 0) ? " *" : "")").onAppear{
                                        print("counting : \(hiddenGroupGuid.count)")
                                        hiddenGroupGuid.insert("\(item.guid):\(item.name)",at:0)
                                    }.onTapGesture {
                                        setGroupValues(hiddenGroupGuid, index)
                                    }
                                    Spacer()
                                    
                                    Image(systemName: "barcode.viewfinder")
                                        .onTapGesture {
                                            displayGroupGuidQRCode(hiddenGroupGuid,index)
                                            guidPopupMessage = "Have your friend scan this QR Code to join your RAOK group."
                                            
                                            groupPopupTitle = "Group GUID"
                                            showBarcode.toggle()
                                        }
                                        .sheet(isPresented: $showBarcode) {
                                            BarcodePopupView(qrCodeText: $currentGroupGuid, message: $guidPopupMessage,
                                            title: $groupPopupTitle)
                                        }
                                        .font(.system(size: 20))
                                        .padding(2)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            
                        }.onAppear(perform:{
                            var group = LocalGroup()
                            var allGroups: [KGroup] = []
                            group.GetMemberGroups(RetrievedGroups:RetrievedGroups, userGuid: pv.localUser?.user.guid ?? "")
                            
                        })
                    }
                }
            }
            Group{
                VStack{
                    TextField("GUID", text: pv.$guidForLoadUser)
                        .textInputAutocapitalization(.never)
                        .onSubmit{
                            pv.processGuidEntry()
                        }
                    TextField("Password", text: $userPassword)
//                        .textInputAutocapitalization(.never)
//                        .textInputSuggestions(.never)
                    
                    
                    Button("Load User From GUID"){
                        pv.password = userPassword
                        pv.processGuidEntry()
                        userPassword = ""
                    }.buttonStyle(.bordered)
                        .alert("GUID Is Invalid!", isPresented: pv.$isShowingGuidError){
                            Button("OK"){
                                pv.guidForLoadUser = ""
                            }
                        } message:{
                            Text("Please enter a valid GUID & try again. (A valid GUID will be exactly 36 characters long & contain numbers, dashes & only lowercase characters.)")
                        }
                }
                Section{
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
            }
            HStack {
               Text("Current App Version:")
               Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown")
           }.font(.caption)
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
    
    func AfterPasswordSet(isSuccess: Bool){
        if (isSuccess){
            showToastWithMessage("Password was successfully set.")
            pv.$password.wrappedValue = pv.localUser!.user.pwdHash ?? "***"
        }
        else{
            showToastWithMessage("Could not set the password, please try again.")
        }
    }
    
    func JoinGroup(){
        var group = LocalGroup()
        group.Join(JoinGroup: self.JoinGroup,userGuid: groupGuid, pwd: pv.groupPwd, userId: pv.localUser?.user.id ?? 0)
    }
    
    func setGroupValues(_ hiddenGroupGuid: [String], _ index: Int){
        print("setGroupValues - index: \(index) : \(hiddenGroupGuid[index])")
        UIPasteboard.general.string = String(hiddenGroupGuid[index].split(separator: ":")[0])
        showToastWithMessage("Copied Group GUID for  \(hiddenGroupGuid[index].split(separator: ":")[1]) to clipboard.")
    }
    
    func displayGroupGuidQRCode(_ hiddenGroupGuid: [String], _ index: Int){
        print("dgqrcode - index: \(index) : \(hiddenGroupGuid[index])")
       currentGroupGuid = String(hiddenGroupGuid[index].split(separator: ":")[0])
        
    }
    
    func SetAlert(){
        pv.isGroupCreateError = true
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
    
    func GroupCreated(group: KGroup){
        if (group.id == 0){
            // couldn't add the group
            showToastWithMessage( "Failed to Create Group\nPlease try again.")
            return
        }
        currentGroups.append(group)
        showToastWithMessage( "Group Created Successfully")
        ClearAllGroupTextEntry()
    }
    
    func JoinGroup(success: Bool){
        print("completed the join group: \(success)")
        if (success){
            showToastWithMessage( "Joined Group Successfully")
            ClearAllGroupTextEntry()
        }
        else{
            showToastWithMessage( "Failed to Join Group")
        }
    }
    
    func ClearAllGroupTextEntry(){
        pv.groupName = ""
        pv.groupPwd = ""
        groupGuid = ""
        
    }
}

#Preview {
    ProfileView(ContentView())
}
