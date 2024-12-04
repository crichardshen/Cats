import SwiftUI

struct FrequencyPicker: View {
    @Binding var frequency: Medicine.Frequency
    @State private var selectedType = 0
    @State private var dailyTimes = 1
    @State private var weeklyDays: Set<Int> = []  // 改为空集合
    @State private var monthlyDays: Set<Int> = []  // 改为空集合
    
    private let frequencyTypes = ["每天", "每周", "每月"]  // 移除"自定义"选项
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
        case .custom:  // 保留 case 以防有历史数据
            selectedType = 0
            dailyTimes = 1
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
        default:
            break
        }
    }
} 