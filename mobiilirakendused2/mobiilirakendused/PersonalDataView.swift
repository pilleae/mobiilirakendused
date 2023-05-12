//
//  PersonalDataView.swift
//  mobiilirakendused
//
//  Created by Pille Allvee on 12.04.2023.
//

import Foundation
import SwiftUI

import UserNotifications


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
        
        let calendar = Calendar.current
        
        // Parse waking hours from input
        let parts = wakingHours.split(separator: ":")
        guard parts.count == 2, let hour = Int(parts[0]), let minute = Int(parts[1]) else {
            return
        }
        
        // Determine the date of the next waking time
        var dateComponents = DateComponents()
        dateComponents.hour = selectedTimePeriod == "AM" ? hour : hour + 12
        dateComponents.minute = minute
        let today = Date()
        let nextWakingTime = calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTime)!
        
        // Determine bedtime based on average waking hours of 14 hours
        let bedtime = calendar.date(byAdding: .hour, value: 14, to: nextWakingTime)!
        
        // Schedule notifications for waking hours until bedtime
        let content = UNMutableNotificationContent()
        content.title = "How are you feeling?"
        content.body = "Don't forget to add your mood to the app."
        content.sound = .default
        
        let dateInterval = DateInterval(start: nextWakingTime, end: bedtime)
        _ = dateInterval // Ignoring the warning
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1 * 60, repeats: true)//600 is for 10 minutes
        let request = UNNotificationRequest(identifier: "moodReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        // Cancel all notifications at bedtime
        let bedtimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: bedtime)
        let bedtimeTrigger = UNCalendarNotificationTrigger(dateMatching: bedtimeComponents, repeats: false)
        let bedtimeRequest = UNNotificationRequest(identifier: "bedtimeReminder", content: content, trigger: bedtimeTrigger)
        UNUserNotificationCenter.current().add(bedtimeRequest, withCompletionHandler: nil)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["moodReminder"])
    }


    //load data
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

