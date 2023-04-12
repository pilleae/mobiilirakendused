import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var errorMessage = ""
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                Section {
                    Button("Log in") {
                        // Make a network call to verify credentials
                        guard let url = URL(string: "https://reqres.in/api/login") else {
                            return
                        }
                        let body = ["email": email, "password": password]
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let data = data {
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                                    if let dictionary = json as? [String: Any], let token = dictionary["token"] as? String {
                                        // Login successful, set isLoggedIn to true
                                        DispatchQueue.main.async {
                                            isLoggedIn = true
                                        }
                                    } else {
                                        // Login failed, show error message
                                        DispatchQueue.main.async {
                                            showAlert = true
                                            errorMessage = "Incorrect email or password"
                                        }
                                    }
                                } catch {
                                    // JSON deserialization failed, show error message
                                    DispatchQueue.main.async {
                                        showAlert = true
                                        errorMessage = "Error parsing response"
                                    }
                                }
                            } else {
                                // Network error, show error message
                                DispatchQueue.main.async {
                                    showAlert = true
                                    errorMessage = error?.localizedDescription ?? "Unknown error"
                                }
                            }
                        }.resume()
                    }
                }
            }
            .navigationTitle("Log in")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login failed"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

