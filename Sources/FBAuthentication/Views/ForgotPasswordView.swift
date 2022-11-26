//
//  ForgotPasswordView.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-19.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import SwiftUI

private enum FocusableField: Hashable {
    case email
}

struct ForgotPasswordView: View {
    @State var user: UserViewModel = UserViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var errString: String?
    @FocusState private var focus: FocusableField?
    var primaryColor: UIColor
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "at")
                    TextField("Enter email address", text: $user.email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .focused($focus, equals: .email)
                        .submitLabel(.go)
                        .onSubmit {
                            resetPassword()
                        }
                }
                .padding(.vertical, 6)
                
                Button {
                    resetPassword()
                } label: {
                    Text("Reset")
                        .frame(width: 200)
                        .padding(.vertical, 15)
                        .background(Color(primaryColor))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .opacity(user.isEmailValid( user.email) ? 1 : 0.75)
                }
                .disabled(!user.isEmailValid( user.email))
                Spacer()
            }
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .navigationTitle("Request a password reset")
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Password Reset"),
                  message: Text(self.errString ?? "Success. Reset email sent successfully.  Check your email"),
                  dismissButton: .default(Text("OK")) {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
}

extension ForgotPasswordView {
    func resetPassword() {
        FBAuth.resetPassword(email: self.user.email) { (result) in
            switch result {
            case .failure(let error):
                self.errString = error.localizedDescription
            case .success:
                break
            }
            self.showAlert = true
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(primaryColor: .systemOrange)
    }
}
