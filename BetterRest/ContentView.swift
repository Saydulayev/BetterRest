//
//  ContentView.swift
//  BetterRest
//
//  Created by Akhmed on 28.08.23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.blue, Color.blue, Color.black]), startPoint: .top, endPoint: .trailing)
                    .ignoresSafeArea()
                VStack {
                    Text("When do you want to wake up?")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    HStack {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                    }
                    Text("Desired amount of sleep")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    HStack {
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    Text("Daily coffee intake")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    HStack {
                        Picker("\(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups")", selection: $coffeeAmount) {
                            ForEach(1...20, id: \.self) { cup in
                                Text(cup == 1 ? "\(cup) cup" : "\(cup) cups")
                            }
                        }
                        
                        .accentColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 5)
                    }
                    
                    Text("RECOMMENDED BEDTIME")
                        .font(.headline)
                        .bold()
                        .padding(.top, 30)
                        .foregroundStyle(.white)
                        
                    ZStack {
                        AnimationView()
                        
                        VStack {
                            Text(calculateBedtime())
                                
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                                .bold()
                                .padding(.vertical)
                            
                            
                        }
                    }
                }
                .padding()
                .navigationBarTitle("Sleep Time", displayMode: .inline)
            }
        }
    }
    
    
    func calculateBedtime() -> String {
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
            return "Error calculating bedtime"
        }
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
