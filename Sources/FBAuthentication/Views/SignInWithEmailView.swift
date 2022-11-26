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
    @FocusState private var focus: FocusableField?
    var primaryColor: UIColor
    var secondaryColor: UIColor
    var body: some View {
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
                TextField("Email Address", text: self.$user.email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .focused($focus, equals: .email)
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
                        signInUser()
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)
                        
            Button {
                signInUser()
            } label: {
                Text("Login")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
            }
            .disabled(!user.isLogInComplete)
            .background(Color(primaryColor))
            .frame(maxWidth: .infinity)
            .cornerRadius(8)
            .buttonStyle(.borderedProminent)
            .opacity(user.isLogInComplete ? 1 : 0.75)
            
            HStack {
                Spacer()
                Button {
                    action = .resetPW
                    showSheet = true
                } label: {
                    Text("Forgot Password")
                }
                .foregroundColor(Color(secondaryColor))
            }
            .padding(.vertical, 10)
            
            HStack {
                Text("Don't have an account yet?")
                Button {
                    action = .signUp
                    showSheet = true
                } label: {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundColor(Color(secondaryColor))
                }
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Error"),
                  message: Text(self.authError?.localizedDescription ?? "Unknown error"),
                  dismissButton: .default(Text("OK")) {
                if self.authError == .incorrectPassword {
                    self.user.password = ""
                } else {
                    self.user.password = ""
                    self.user.email = ""
                }
            })
        }
        .listStyle(.plain)
        .padding()
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

extension SignInWithEmailView {
    func signInUser() {
        FBAuth.authenticate(withEmail: self.user.email, password: self.user.password) { (result) in
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

struct SignInWithEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithEmailView(showSheet: .constant(false),
                            action: .constant(.signUp),
                            primaryColor: .systemBlue,
                            secondaryColor: .systemOrange)
    }
}
