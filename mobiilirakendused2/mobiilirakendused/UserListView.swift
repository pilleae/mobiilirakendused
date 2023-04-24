//
//  UserListView.swift
//  mobiilirakendused
//
//  Created by Pille Allvee on 12.04.2023.
//

import Foundation
import SwiftUI

struct UserListView: View {
    
    // state property to hold the list of users
    @State private var users: [User] = []

    // ForEach loop to display users
    var body: some View {
        List(users) { user in
            HStack(spacing: 10) {
                //AsyncImage view to fetch and display the user avatar
                AsyncImage(url: user.avatarUrl) { image in
                    image.resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
                VStack(alignment: .leading) {
                    Text(user.firstName + " " + user.lastName)
                        .font(.headline)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            loadUsers()
        }
    }

    // Fetches the list of users from the external API and updates the state with the response
    private func loadUsers() {
        guard let url = URL(string: "https://reqres.in/api/users?page=2") else {
            return
        }
        // data task to fetch the data
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                // decode the response using JSONDecoder
                if let decodedResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.users = decodedResponse.data
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct UserResponse: Codable {
    let data: [User]
}

struct User: Codable, Identifiable {
    let id: Int
    let email, firstName, lastName: String
    let avatar: String

    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
    }

    var avatarUrl: URL? {
        return URL(string: avatar)
    }
}

