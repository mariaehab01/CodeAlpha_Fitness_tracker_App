//
//  fitness_tracker_appApp.swift
//  fitness_tracker_app
//
//  Created by Maria Ehab 
//

import SwiftUI

@main
struct fitness_tracker_app : App {
    @StateObject var manager = HealthManager()
       var body: some Scene {
           WindowGroup {
               MainTabView()
                   .environmentObject(manager)
           }
       }
}
