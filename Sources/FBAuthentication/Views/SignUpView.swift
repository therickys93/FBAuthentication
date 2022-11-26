//
//  SignUpView.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-19.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import SwiftUI

private enum FocusableField: Hashable {
    case name
    case email
    case password
    case confirmPassword
}

struct SignUpView: View {
    @EnvironmentObject var userInfo: UserInfo
    @State var user: UserViewModel = UserViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showError = false
    @State private var errorString = ""
    var primaryColor: UIColor
    var secondaryColor: UIColor
    @FocusState private var focus: FocusableField?
    var body: some View {
        NavigationView {
            VStack {
                Image("SignUp", bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 300, maxHeight: 400)
                
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Image(systemName: "person")
                    VStack(alignment: .leading) {
                        TextInputView("Full Name", text: $user.fullname)
                            .focused($focus, equals: .name)
                            .submitLabel(.next)
                            .onSubmit {
                                self.focus = .email
                            }
                        Rectangle().fill(Color(.secondaryLabel))
                            .frame(height: 1)
                    }
                }
                .padding(.vertical, 6)
                
                HStack {
                    Image(systemName: "at")
                    VStack(alignment: .leading) {
                        TextInputView("Email Address", text: $user.email)
                            .keyboardType(.emailAddress)
                            .focused($focus, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                self.focus = .password
                            }
                        if !user.validEmailAddressText.isEmpty || user.email.isEmpty {
                            Text(user.validEmailAddressText).font(.caption).foregroundColor(.red)
                        }
                        Rectangle().fill(Color(.secondaryLabel))
                            .frame(height: 1)
                    }
                }
                .padding(.vertical, 6)
                
                HStack {
                    Image(systemName: "lock")
                    VStack(alignment: .leading) {
                        TextInputView("Password", text: $user.password, isSecure: true)
                            .focused($focus, equals: .password)
                            .submitLabel(.next)
                            .onSubmit {
                                self.focus = .confirmPassword
                            }
                        if !user.validPasswordText.isEmpty {
                            Text(user.validPasswordText).font(.caption).foregroundColor(.red)
                        }
                        Rectangle().fill(Color(.secondaryLabel))
                            .frame(height: 1)
                    }
                }
                .padding(.vertical, 6)
                
                HStack {
                    Image(systemName: "lock")
                    VStack(alignment: .leading) {
                        TextInputView("Confirm Password", text: $user.confirmPassword, isSecure: true)
                            .focused($focus, equals: .confirmPassword)
                            .submitLabel(.go)
                            .onSubmit {
                                signUpUser()
                            }
                        if !user.passwordsMatch( user.confirmPassword) {
                            Text(user.validConfirmPasswordText).font(.caption).foregroundColor(.red)
                        }
                        Rectangle().fill(Color(.secondaryLabel))
                            .frame(height: 1)
                    }
                }
                .padding(.vertical, 6)
                
                Button {
                    signUpUser()
                } label: {
                    Text("Sign Up")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .disabled(!user.isSignInComplete)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .background(Color(primaryColor))
                .opacity(user.isSignInComplete ? 1 : 0.75)
                
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Error creating accout"),
                      message: Text(self.errorString),
                      dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(Color(secondaryColor))
                    }
                }
            }
            .listStyle(.plain)
            .padding()
        }
    }
}

extension SignUpView {
    func signUpUser() {
        FBAuth.createUser(withEmail: self.user.email,
                          name: self.user.fullname,
                          password: self.user.password) { (restult) in
            switch restult {
            case .failure(let error):
                self.errorString = error.localizedDescription
                self.showError = true
            case .success:
                print("Account creation successful")
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(primaryColor: UIColor.systemBlue, secondaryColor: .systemOrange)
    }
}

struct TextInputView: View {
    var title: String
    init(_ title: String, text: Binding<String>, isSecure: Bool = false) {
        self.title = title
        self._text = text
        self.isSecure = isSecure
    }
    @Binding var text: String
    var isSecure = false
    var body: some View {
        //        VStack {
        ZStack(alignment: .leading) {
            Text(title)
                .foregroundColor(text.tfProperties.phColor)
                .offset(y: text.tfProperties.offset)
                .scaleEffect(text.tfProperties.scale, anchor: .leading)
            if isSecure {
                SecureField("", text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textContentType(.none)
            } else {
                TextField("", text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
        .padding(.bottom, text.isEmpty ? 0 : 15)
        .animation(.default, value: text)
        //        }
    }
}

extension String {
    struct TFProperties: Equatable {
        var offset: Double = 0
        var phColor = Color(.placeholderText)
        var scale: Double = 1
    }
    var tfProperties: TFProperties {
        if isEmpty {
            return TFProperties(offset: 0, phColor: Color(.placeholderText), scale: 1)
        } else {
            return TFProperties(offset: 25, phColor: Color(.secondaryLabel), scale: 0.8)
        }
    }
}
