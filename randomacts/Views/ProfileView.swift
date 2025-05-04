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
                    Image(systemName: "barcode.viewfinder")
                        .onTapGesture {
                            currentGroupGuid = "\(pv.localUser?.user.guid ?? "")"
                            guidPopupMessage = "Scan QR Code to share your UserId with another device."
                            showUserIdBarcode.toggle()
                            
                        }.sheet(isPresented: $showUserIdBarcode) {
                            BarcodePopupView(qrCodeText: $currentGroupGuid ,message: $guidPopupMessage)
                            
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
                                    return
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
                                            guidPopupMessage = "Scan this QR Code to join your friend's RAOK group."
                                            
                                           
                                            showBarcode.toggle()
                                        }
                                        .sheet(isPresented: $showBarcode) {
                                           
                                            BarcodePopupView(qrCodeText: $currentGroupGuid, message: $guidPopupMessage)
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
}
import CoreImage.CIFilterBuiltins
struct BarcodePopupView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var qrCodeText: String
    @Binding var message: String
    
    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    var body: some View {

        VStack {
            Section{
                if let qrCodeImage = generateQRCode(from: qrCodeText) {
                    Image(uiImage: qrCodeImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                } else {
                    Text("Failed to generate QR code \nPlease close & try again.")
                }
            }
            VStack{
                HStack{
                    Text(message)
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal).padding(50)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Button("Close") {
                    dismiss()
                }
                .foregroundStyle(.blue)
                .padding()
            }
        }
    }
}

#Preview {
    ProfileView(ContentView())
}
