//
//  HealthManager.swift
//  fitness_tracker_app
//
//  Created by Maria Ehab 
//


import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        
        return calendar.date(from: components)!
    }
    
    static var oneMonthAgo: Date{
        let calendar = Calendar.current
        let oneMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        return calendar.startOfDay(for: oneMonth!)
    }
}

extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}


class HealthManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var activities: [String: Activity] = [:]
    
    @Published var oneMonthChartData = [DailyStepView]()
    
    @Published var mockActivities: [String: Activity] = [
        "todaySteps" : Activity.test,
        "todayCalories" : Activity(id: 1, title: "Today calories", subtitle: "Goal 900", image: "flame", tintColor: .red, amount: "1,234")
        ]
    
    init() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let workout = HKObjectType.workoutType()
        
        let healthTypes: Set = [steps, calories, workout]
        
        Task {
            do {
                //try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
                fetchCurrentWeekWorkoutStats()
                fetchPastMonthStepData()
            } catch {
                print("error fetching health data")
            }
        }
    }
    
    func fetchDailySteps(startDate: Date, completion: @escaping([DailyStepView]) -> Void){
        let steps = HKQuantityType(.stepCount)
        let interval = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(quantityType: steps, quantitySamplePredicate: nil, anchorDate:startDate, intervalComponents: interval)
        
        query.initialResultsHandler = { query, result, error in
            guard let result = result else {
                completion([])
                return
            }
            
            var dailySteps = [DailyStepView]()
            
            result.enumerateStatistics(from: startDate, to: Date()) { statistics, stop in
                dailySteps.append(DailyStepView(date: statistics.startDate, stepCount: statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0.00))
            }
            completion(dailySteps)
        }
        healthStore.execute(query)
    }
    
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching todays step data")
                return
            }
            let stepCount = quantity.doubleValue(for: .count())
            let activity = Activity(id: 0, title: "Today steps", subtitle: "Goal 10,000", image: "figure.walk", tintColor: .green, amount: stepCount.formattedString())
            DispatchQueue.main.async {
                self.activities["todaySteps"] = activity
            }
        }
        healthStore.execute(query)
    }
    
    
    
    func fetchTodayCalories() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching todays calories data")
                return
            }
            let caloriesBurned = quantity.doubleValue(for: .kilocalorie())
            let activity = Activity(id: 1, title: "Today calories", subtitle: "Goal 900", image: "flame", tintColor: .red, amount: caloriesBurned.formattedString())
            DispatchQueue.main.async {
                self.activities["todayCalories"] = activity
            }
        }
        healthStore.execute(query)
    }
    

    
    func fetchCurrentWeekWorkoutStats() {
        let workout = HKSampleType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let query = HKSampleQuery(sampleType: workout, predicate: timePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, sample, error in
            guard let workouts = sample as? [HKWorkout], error == nil else {
                print("error fetching week running data")
                return
            }
            
            var runningCount: Int = 0
            var strengthCount: Int = 0
            var soccerCount: Int = 0
            var basketballCount: Int = 0
            var stairsCount: Int = 0
            var kickboxingCount: Int = 0
            
            for workout in workouts {
                if workout.workoutActivityType == .running {
                    let duration = Int(workout.duration)/60
                    runningCount += duration
                } else if workout.workoutActivityType == .traditionalStrengthTraining {
                    let duration = Int(workout.duration)/60
                    strengthCount += duration
                } else if workout.workoutActivityType == .soccer {
                    let duration = Int(workout.duration)/60
                    soccerCount += duration
                } else if workout.workoutActivityType == .basketball {
                    let duration = Int(workout.duration)/60
                    basketballCount += duration
                } else if workout.workoutActivityType == .stairClimbing {
                    let duration = Int(workout.duration)/60
                    stairsCount += duration
                } else if workout.workoutActivityType == .kickboxing {
                    let duration = Int(workout.duration)/60
                    kickboxingCount += duration
                }
            }
            let runningActivity = Activity(id: 2, title: "Running", subtitle: "This week", image: "figure.run", tintColor: .green, amount: "\(runningCount) minutes")
            let strengthActivity = Activity(id: 3, title: "Weight Lifting", subtitle: "This week", image: "dumbbell", tintColor: .cyan, amount: "\(strengthCount) minutes")
            let soccerActivity = Activity(id: 4, title: "Soccer", subtitle: "This week", image: "soccerball", tintColor: .blue, amount: "\(soccerCount) minutes")
            let basketballActivity = Activity(id: 5, title: "Basketball", subtitle: "This week", image: "basketball", tintColor: .orange, amount: "\(basketballCount) minutes")
            let stairActivity = Activity(id: 6, title: "Stair Stepper", subtitle: "This week", image: "figure.stair.stepper", tintColor: .green, amount: "\(stairsCount) minutes")
            let kickboxActivity = Activity(id: 7, title: "Kickboxing", subtitle: "This week", image: "figure.kickboxing", tintColor: .green, amount: "\(kickboxingCount) minutes")
            DispatchQueue.main.async {
                self.activities["weekRunning"] = runningActivity
                self.activities["weekStrength"] = strengthActivity
                self.activities["weekSoccer"] = soccerActivity
                self.activities["weekBasketball"] = basketballActivity
                self.activities["weekStairs"] = stairActivity
                self.activities["weekKickboxing"] = kickboxActivity
            }
        }
        healthStore.execute(query)
    }
    
}

extension HealthManager {
    func fetchPastMonthStepData(){
        fetchDailySteps(startDate: .oneMonthAgo){ dailySteps in
            DispatchQueue.main.async {
                self.oneMonthChartData = dailySteps
            }
        }
    }
}
