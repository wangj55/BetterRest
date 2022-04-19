//
//  ContentView.swift
//  BetterRest
//
//  Created by Ji Wang on 4/19/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    private var bedtimeText: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
        
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Error occurred"
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                }
                .labelsHidden()
                
                Section("Disired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake") {
                    Picker("Please select your coffee intake", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
                .labelsHidden()
                
                Section("Recommended Bedtime") {
                    Text(bedtimeText)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
