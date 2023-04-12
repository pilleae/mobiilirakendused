//
//  PersonalDataView.swift
//  mobiilirakendused
//
//  Created by Pille Allvee on 12.04.2023.
//

import Foundation
import SwiftUI


struct PersonalDataView: View {
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var wakingHours: String = ""
    @State private var selectedTimePeriod: String = "AM"
    
    @AppStorage("name") var savedName: String = ""
    @AppStorage("age") var savedAge: String = ""
    @AppStorage("wakingHours") var savedWakingHours: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Name")
                .font(.headline)
            
            TextField("", text: $name)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)

            Text("Age")
                .font(.headline)
                .padding(.top)
            
            TextField("", text: $age)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            Text("Normal waking hours")
                .font(.headline)
                .padding(.top)

            HStack {
                TextField("", text: $wakingHours)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)

                Picker("Time period", selection: $selectedTimePeriod) {
                    Text("AM").tag("AM")
                    Text("PM").tag("PM")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 80)
                .padding(.trailing)
            }
            .padding(.bottom)

            Spacer()

            Button(action: savePersonalData) {
                HStack {
                    Spacer()
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            .padding(.bottom)
        }
        .padding()
        .navigationTitle("Personal Data")
        .onAppear {
            loadPersonalData()
        }
        
        
    }
    
    private func savePersonalData() {
        savedName = name
        savedAge = age
        savedWakingHours = wakingHours + " " + selectedTimePeriod
    }
    
    private func loadPersonalData() {
        name = savedName
        age = savedAge
        let parts = savedWakingHours.split(separator: " ")
        if parts.count == 2 {
            wakingHours = String(parts[0])
            selectedTimePeriod = String(parts[1])
        }
    }
    
    
}

