import SwiftUI

struct FrequencyPicker: View {
    @Binding var frequency: Medicine.Frequency
    @State private var selectedType = 0
    @State private var dailyTimes = 1
    @State private var weeklyDays: Set<Int> = []  // 改为空集合
    @State private var monthlyDays: Set<Int> = []  // 改为空集合
    @State private var customYears = ""
    @State private var customMonths = ""
    @State private var customDays = ""
    @State private var customHours = ""
    
    private let frequencyTypes = ["每天", "每周", "每月", "自定义"]  // 添加自定义选项
    private let weekDays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    
    var body: some View {
        VStack {
            Picker("频率类型", selection: $selectedType) {
                ForEach(0..<frequencyTypes.count, id: \.self) { index in
                    Text(frequencyTypes[index]).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedType) { _ in
                updateFrequency()
            }
            
            switch selectedType {
            case 0: // 每天
                Stepper("每天 \(dailyTimes) 次", value: $dailyTimes, in: 1...10)
                    .onChange(of: dailyTimes) { _ in
                        frequency = .daily(times: dailyTimes)
                    }
                
            case 1: // 每周
                VStack(alignment: .leading, spacing: 10) {
                    Text("选择重复的星期")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(0..<7) { index in
                            Toggle(isOn: Binding(
                                get: { weeklyDays.contains(index + 1) },
                                set: { isSelected in
                                    if isSelected {
                                        weeklyDays.insert(index + 1)
                                    } else {
                                        weeklyDays.remove(index + 1)
                                    }
                                    frequency = .weekly(days: Array(weeklyDays).sorted())
                                }
                            )) {
                                Text(weekDays[index])
                                    .font(.subheadline)
                            }
                            .toggleStyle(ButtonToggleStyle())
                            .tint(ThemeColors.forestGreen)
                        }
                    }
                }
                
            case 2: // 每月
                VStack(alignment: .leading, spacing: 10) {
                    Text("选择重复的日期")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                        ForEach(1...31, id: \.self) { day in
                            Toggle(isOn: Binding(
                                get: { monthlyDays.contains(day) },
                                set: { isSelected in
                                    if isSelected {
                                        monthlyDays.insert(day)
                                    } else {
                                        monthlyDays.remove(day)
                                    }
                                    frequency = .monthly(days: Array(monthlyDays).sorted())
                                }
                            )) {
                                Text(String(format: "%2d", day))
                                    .font(.subheadline)
                                    .monospacedDigit()
                                    .frame(minWidth: 30)
                            }
                            .toggleStyle(ButtonToggleStyle())
                            .tint(ThemeColors.forestGreen)
                        }
                    }
                }
                
            case 3: // 自定义
                CustomIntervalPicker(
                    years: $customYears,
                    months: $customMonths,
                    days: $customDays,
                    hours: $customHours
                )
                .onChange(of: customYears) { _ in updateCustomFrequency() }
                .onChange(of: customMonths) { _ in updateCustomFrequency() }
                .onChange(of: customDays) { _ in updateCustomFrequency() }
                .onChange(of: customHours) { _ in updateCustomFrequency() }
            
            default:
                EmptyView()
            }
        }
        .onAppear {
            initializeFromFrequency()
        }
    }
    
    private func initializeFromFrequency() {
        switch frequency {
        case .daily(let times):
            selectedType = 0
            dailyTimes = times
        case .weekly(let days):
            selectedType = 1
            weeklyDays = Set(days)
        case .monthly(let days):
            selectedType = 2
            monthlyDays = Set(days)
        case .custom(let years, let months, let days, let hours):
            selectedType = 3
            customYears = years > 0 ? String(years) : ""
            customMonths = months > 0 ? String(months) : ""
            customDays = days > 0 ? String(days) : ""
            customHours = hours > 0 ? String(hours) : ""
        }
    }
    
    private func updateFrequency() {
        switch selectedType {
        case 0:
            frequency = .daily(times: dailyTimes)
        case 1:
            frequency = .weekly(days: Array(weeklyDays).sorted())
        case 2:
            frequency = .monthly(days: Array(monthlyDays).sorted())
        case 3:
            updateCustomFrequency()
        default:
            break
        }
    }
    
    private func updateCustomFrequency() {
        let y = Int(customYears) ?? 0
        let m = Int(customMonths) ?? 0
        let d = Int(customDays) ?? 0
        let h = Int(customHours) ?? 0
        
        if y > 0 || m > 0 || d > 0 || h > 0 {
            frequency = .custom(years: y, months: m, days: d, hours: h)
        }
    }
} 