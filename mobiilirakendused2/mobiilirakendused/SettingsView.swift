//
//  SettingsView.swift
//  mobiilirakendused
//
//  Created by Caroly Vilo on 4/10/23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("darkMode") var darkMode = false
    @AppStorage("somethingElse") var somethingElse = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Dark mode", isOn: $darkMode)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    Toggle("Midagi veel", isOn: $somethingElse)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
