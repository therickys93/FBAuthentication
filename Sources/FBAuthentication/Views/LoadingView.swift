//
//  LoadingView.swift
//  LoadingView
//
//  Created by Stewart Lynch on 2021-09-14.
//

import SwiftUI
public struct LoadingView<StartView>: View where StartView: View {
    /// The view that is first presented while identifying the current authentication state
    @EnvironmentObject var userInfo: UserInfo
    var startView: StartView
    var primaryColor: UIColor
    var secondaryColor: UIColor
    /// Loading View parameters
    /// - Parameters:
    ///   - startView: The view that is presented once the user is authenticated
    ///   - title: A title displayed on the login screen, defaults to "Log in"
    ///   - primaryColor: the color used for the primary button defaults to systemOranage
    ///   - secondaryColor: color used for the secondary button defaults to systemBlue
    ///   - logoImage: An image to be used on the login screen.  If left as nil, will display a Firebase logo
    public init(startView: StartView,
                primaryColor: UIColor = .systemBlue,
                secondaryColor: UIColor = .systemOrange) {
        self.startView = startView
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
    /// The body of the view
    public var body: some View {
        Group {
            if userInfo.isUserAuthenticated == .undefined {
                Text("Loading...")
            } else if userInfo.isUserAuthenticated == .signedOut {
                VStack {
                    LoginView(primaryColor: primaryColor, secondaryColor: secondaryColor)
                    Spacer()
                }
            } else {
                startView
            }
        }
        .onAppear {
            self.userInfo.configureFirebaseStateDidChange()
        }
    }
}
