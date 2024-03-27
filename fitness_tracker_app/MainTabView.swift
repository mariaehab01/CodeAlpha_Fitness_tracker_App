//
//  TabView.swift
//  fitness_tracker_app
//
//  Created by Maria Ehab 
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var manager: HealthManager
    @State var selectedTab = "Home"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(manager)
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                }
            
            ChartsView()
                .environmentObject(manager)
                .tag("Charts")
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                }
        }
    }
}
struct MainTabView_Previews: PreviewProvider{
    static var previews: some View{
        MainTabView()
            .environmentObject(HealthManager())
    }
}

