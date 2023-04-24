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
                
                // section for the email and password text fields
                Section {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                
                // section for the login btn
                Section {
                    Button("Log in") {
                        //network call to verify the user's credentials
                        guard let url = URL(string: "https://reqres.in/api/login") else {
                            return // If the URL is invalid
                        }
                        
                        //dictionary with the user's email and password
                        let body = ["email": email, "password": password]
                        var request = URLRequest(url: url)
                        //POST request to send the user's login information
                        request.httpMethod = "POST"
                        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        // network request and handle the response
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let data = data {
                                
                                // If the response contains data, try to deserialize it as JSON
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                                    // If the JSON contains a "token" key, the login was successful
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

