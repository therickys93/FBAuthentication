//
//  SignInWithEmailView.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-19.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import SwiftUI

private enum FocusableField: Hashable {
    case email
    case password
}

struct SignInWithEmailView: View {
    @EnvironmentObject var userInfo: UserInfo
    @State var user: UserViewModel = UserViewModel()
    @Binding var showSheet: Bool
    @Binding var action: LoginView.Action?
    @State private var showAlert = false
    @State private var authError: EmailAuthError?
    var primaryColor: UIColor
    var secondaryColor: UIColor
    @FocusState private var focus: FocusableField?
    var body: some View {
        //        VStack {
        //            TextField("Email Address",
        //                      text: self.$user.email)
        //                .autocapitalization(.none)
        //                .keyboardType(.emailAddress)
        //            SecureField("Password", text: $user.password)
        //            HStack {
        //                Spacer()
        //                Button {
        //                    action = .resetPW
        //                    showSheet = true
        //                } label: {
        //                    Text("Forgot Password")
        //                }
        //                .foregroundColor(Color(primaryColor))
        //            }
        //            .padding(.bottom)
        //            VStack(spacing: 10) {
        //                Button {
        //                    FBAuth.authenticate(withEmail: self.user.email,
        //                                        password: self.user.password) { (result) in
        //                                            switch result {
        //                                            case .failure(let error):
        //                                                self.authError = error
        //                                                self.showAlert = true
        //                                            case .success:
        //                                                print("Signed in")
        //                                            }
        //                    }
        //                } label: {
        //                    Text("Login")
        //                        .padding(.vertical, 15)
        //                        .frame(width: 200)
        //                        .background(Color(primaryColor))
        //                        .cornerRadius(8)
        //                        .foregroundColor(.white)
        //                        .opacity(user.isLogInComplete ? 1 : 0.75)
        //                }.disabled(!user.isLogInComplete)
        //                Button {
        //                    action = .signUp
        //                   showSheet = true
        //                } label: {
        //                    Text("Sign Up")
        //                        .padding(.vertical, 15)
        //                        .frame(width: 200)
        //                        .background(Color(secondaryColor))
        //                        .cornerRadius(8)
        //                        .foregroundColor(.white)
        //                }
        //            }
        //            .alert(isPresented: $showAlert) {
        //                Alert(title: Text("Login Error"),
        //                      message: Text(self.authError?.localizedDescription ?? "Unknown error"),
        //                      dismissButton: .default(Text("OK")) {
        //                    if self.authError == .incorrectPassword {
        //                        self.user.password = ""
        //                    } else {
        //                        self.user.password = ""
        //                        self.user.email = ""
        //                    }
        //                    })
        //            }
        //        }
        //        .padding(.top)
        //        .frame(width: 300)
        //        .textFieldStyle(RoundedBorderTextFieldStyle())
        //    }
        VStack {
            Image("Login", bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 300, minHeight: 400)
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "at")
                TextField("Email", text: self.$user.email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .focused($focus, equals: .email)
                    .keyboardType(.emailAddress)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)
            
            HStack {
                Image(systemName: "lock")
                SecureField("Password", text: $user.password)
                    .focused($focus, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        FBAuth.authenticate(withEmail: self.user.email,
                                            password: self.user.password) { (result) in
                                                switch result {
                                                case .failure(let error):
                                                    self.authError = error
                                                    self.showAlert = true
                                                case .success:
                                                    print("Signed in")
                                                }
                        }
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)
            
            Button {
                FBAuth.authenticate(withEmail: self.user.email,
                                    password: self.user.password) { (result) in
                                        switch result {
                                        case .failure(let error):
                                            self.authError = error
                                            self.showAlert = true
                                        case .success:
                                            print("Signed in")
                                        }
                }
            } label: {
                Text("Login")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            .background(Color(primaryColor))
            
            
            HStack {
                Text("Don't have an account yet?")
                Button {
                    // show singup view.
                    action = .signUp
                    showSheet = true
                } label: {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundColor(Color(secondaryColor))
                }
            }
            .padding([.top, .bottom], 50)
        }
        .listStyle(.plain)
        .padding()
    }
}

struct SignInWithEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithEmailView(showSheet: .constant(false),
                            action: .constant(.signUp),
                            primaryColor: .systemGreen,
                            secondaryColor: .systemBlue)
    }
}
