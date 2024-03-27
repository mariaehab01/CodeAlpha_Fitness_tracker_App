//
//  ChartsView.swift
//  fitness_tracker_app
//
//  Created by Maria Ehab
//

import SwiftUI
import Charts

struct DailyStepView: Identifiable{
    let id = UUID()
    let date: Date
    let stepCount: Double
}

enum ChartOptions {
    case oneWeek
    case oneMonth
    case threeMonth
    case yearToDate
    case oneYear
}
struct ChartsView : View {
    @EnvironmentObject var manager: HealthManager
    @State var selectedChart: ChartOptions = .oneMonth
    
    var body: some View {
        VStack(spacing: 15) {
            Chart {
                ForEach(manager.oneMonthChartData){ daily in
                    BarMark(x: .value(daily.date.formatted(), daily.date, unit: .day), y:
                            .value("steps", daily.stepCount))
                }
            }
            .foregroundColor(.green)
            .frame(height: 350)
            .padding(.horizontal)
            
            HStack{
                Button("1W"){
                    withAnimation {
                        selectedChart = .oneWeek
                    }
                }
                .padding(.all)
                .foregroundColor(selectedChart == .oneWeek ? .white : .blue)
                .background(selectedChart == .oneWeek ? .blue : .clear)
                .cornerRadius(10)
                
                Button("1M"){
                    withAnimation {
                        selectedChart = .oneMonth
                    }
                }
                .padding(.all)
                .foregroundColor(selectedChart == .oneMonth ? .white : .blue)
                .background(selectedChart == .oneMonth ? .blue : .clear)
                .cornerRadius(10)
                
                Button("3M"){
                    withAnimation {
                        selectedChart = .threeMonth
                    }
                }
                .padding(.all)
                .foregroundColor(selectedChart == .threeMonth ? .white : .blue)
                .background(selectedChart == .threeMonth ? .blue : .clear)
                .cornerRadius(10)
                
                Button("YTD"){
                    withAnimation {
                        selectedChart = .yearToDate
                    }
                }
                .padding(.all)
                .foregroundColor(selectedChart == .yearToDate ? .white : .blue)
                .background(selectedChart == .yearToDate ? .blue : .clear)
                .cornerRadius(10)
                
                Button("1Y"){
                    withAnimation {
                        selectedChart = .oneYear
                    }
                }
                .padding(.all)
                .foregroundColor(selectedChart == .oneYear ? .white : .blue)
                .background(selectedChart == .oneYear ? .blue : .clear)
                .cornerRadius(10)
            }
        }
        .onAppear{
            print(manager.oneMonthChartData)
        }
    }
    struct ChartsView_Previews : PreviewProvider{
        static var previews: some View{
            ChartsView()
                .environmentObject(HealthManager())
        }
    }
}
