//
//  ProfileView.swift
//  Firebase Login
//
//  Created by Stewart Lynch on 2021-07-05.
//  Copyright © 2021 CreaTECH Solutions. All rights reserved.
//

import SwiftUI

private enum FocusableField: Hashable {
    case name
}

public struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userInfo: UserInfo
    @State private var providers: [FBAuth.ProviderType] = []
    @State private var canDelete = false
    @State private var fullname = ""
    @FocusState private var focus: FocusableField?
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
                                    Image(systemName: "at")
                                    TextInputView("Full Name", text: $fullname)
                                        .focused($focus, equals: .name)
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
                            presentationMode.wrappedValue.dismiss()
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
                .navigationBarTitleDisplayMode(.inline)
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
