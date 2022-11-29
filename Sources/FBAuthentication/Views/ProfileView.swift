//
//  ProfileView.swift
//  Firebase Login
//
//  Created by Stewart Lynch on 2021-07-05.
//  Copyright © 2021 CreaTECH Solutions. All rights reserved.
//

import SwiftUI
import FirebaseAuth

private enum FullNameFocusableField: Hashable {
    case name
}

private enum PasswordFocusableField: Hashable {
    case password
    case confirmPassword
}

public struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userInfo: UserInfo
    @State var user: UserViewModel = UserViewModel()
    @State private var providers: [FBAuth.ProviderType] = []
    @State private var canDelete = false
    @State private var fullname = ""
    @FocusState private var fullNameFocus: FullNameFocusableField?
    @FocusState private var passwordFocus: PasswordFocusableField?
    var primaryColor: UIColor
    public init(primaryColor: UIColor = .systemBlue) {
        self.primaryColor = primaryColor
    }
    public var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    if !canDelete {
                        VStack {
                            VStack {
                                HStack {
                                    Image(systemName: "person")
                                    TextInputView("Full Name", text: $fullname)
                                        .focused($fullNameFocus, equals: .name)
                                        .submitLabel(.go)
                                        .onSubmit {
                                            updateUserName()
                                        }
                                }
                                Rectangle().fill(Color(.secondaryLabel))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 6)
                            
                            Button {
                                updateUserName()
                            } label: {
                                Text("Update")
                                    .padding(.vertical, 8)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                            .buttonStyle(.borderedProminent)
                            .background(Color(primaryColor))
                            .opacity(!fullname.isEmpty ? 1 : 0.75)
                        }
                        .padding()
                        
                        Spacer()
                        VStack {
                            VStack {
                                VStack {
                                    HStack {
                                        Image(systemName: "lock")
                                        TextInputView("New Password", text: $user.password, isSecure: true)
                                            .focused($passwordFocus, equals: .password)
                                            .submitLabel(.next)
                                            .onSubmit {
                                                self.passwordFocus = .confirmPassword
                                            }
                                    }
                                    if !user.validPasswordText.isEmpty {
                                        Text(user.validPasswordText).font(.caption).foregroundColor(.red)
                                    }
                                }
                                Rectangle().fill(Color(.secondaryLabel))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 6)
                            
                            VStack {
                                VStack {
                                    HStack {
                                        Image(systemName: "lock")
                                        TextInputView("Confirm New Password", text: $user.confirmPassword, isSecure: true)
                                            .focused($passwordFocus, equals: .confirmPassword)
                                    }
                                    if !user.passwordsMatch( user.confirmPassword) {
                                        Text(user.validConfirmPasswordText).font(.caption).foregroundColor(.red)
                                    }
                                }
                                Rectangle().fill(Color(.secondaryLabel))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 6)
                            
                            Button {
                                updatePassword()
                            } label: {
                                Text("Update")
                                    .padding(.vertical, 8)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                            .buttonStyle(.borderedProminent)
                            .background(Color(primaryColor))
                            .disabled(!user.passwordsMatch(user.confirmPassword) || user.password.isEmpty)
                        }
                        .padding()
                    }
                    Spacer()
                    Text(canDelete ?
                        "DO YOU REALLY WANT TO DELETE?" :
                        "Deleting your account will delete all content " +
                        "and remove your information from the database. " +
                        "You must first re-authenticate")
                    HStack {
                        Button("Cancel") {
                            canDelete = false
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .padding(.vertical, 15)
                        .frame(width: 100)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .foregroundColor(Color(.label))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        
                        Button(canDelete ? "DELETE ACCOUNT" : "Authenticate") {
                            if canDelete {
                                deleteUserAndUserData()
                            } else {
                                withAnimation {
                                    providers = FBAuth.getProviders()
                                }
                            }
                        }
                        .padding(.vertical, 15)
                        .frame(width: 179)
                        .background(Color.red)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.automatic)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(Color(primaryColor))
                        }
                    }
                }
            }
            if !providers.isEmpty {
                ReAuthenticateView(providers: $providers, canDelete: $canDelete)
            }
        }
        .onAppear {
            fullname = userInfo.user.name
        }
    }
}

extension ProfileView {
    func updateUserName() {
        FBFirestore.updateUserName(with: fullname, uid: userInfo.user.uid) { result in
            switch result {
            case .success:
                print("success")
                userInfo.user.name = fullname
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updatePassword() {
        FBAuth.changeUserPassword(user.password) { result in
            switch result {
            case .success(_):
                print("password changed")
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteUserAndUserData() {
        FBFirestore.deleteUserData(uid: userInfo.user.uid) { result in
            presentationMode.wrappedValue.dismiss()
            switch result {
            case .success:
                FBAuth.deleteUser { result in
                    if case let .failure(error) = result {
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(UserInfo())
    }
}
