import SwiftUI
import Charts

struct MedicineStatsView: View {
    let medicine: Medicine
    let logs: [MedicineLog]
    
    private var completionStats: CompletionStats {
        let calendar = Calendar.current
        let now = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
        
        // 获取最近30天的记录
        let recentLogs = logs.filter { log in
            log.timestamp >= thirtyDaysAgo && log.timestamp <= now
        }
        
        // 计算应该服用的次数
        var totalRequired = 0
        var date = thirtyDaysAgo
        while date <= now {
            if shouldTakeMedicine(on: date) {
                switch medicine.frequency {
                case .daily(let times):
                    totalRequired += times
                case .weekly, .monthly, .custom:
                    totalRequired += 1
                }
            }
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return CompletionStats(
            totalRequired: totalRequired,
            completed: recentLogs.count,
            completionRate: totalRequired > 0 ? Double(recentLogs.count) / Double(totalRequired) : 0
        )
    }
    
    private func shouldTakeMedicine(on date: Date) -> Bool {
        let calendar = Calendar.current
        
        guard date >= medicine.startDate else { return false }
        if let endDate = medicine.endDate, date > endDate {
            return false
        }
        
        switch medicine.frequency {
        case .daily:
            return true
        case .weekly(let days):
            let weekday = calendar.component(.weekday, from: date)
            return days.contains(weekday)
        case .monthly(let days):
            let day = calendar.component(.day, from: date)
            return days.contains(day)
        case .custom(let interval):
            let days = calendar.dateComponents([.day], from: medicine.startDate, to: date).day ?? 0
            return days % interval == 0
        }
    }
    
    var body: some View {
        List {
            // 基本信息
            Section(header: Text("基本信息")) {
                InfoRow(title: "药物名称", value: medicine.name)
                InfoRow(title: "类型", value: medicine.type.rawValue)
                InfoRow(title: "使用频率", value: medicine.frequency.description)
                InfoRow(title: "开始日期", value: medicine.startDate.formatted(date: .long, time: .omitted))
                if let endDate = medicine.endDate {
                    InfoRow(title: "结束日期", value: endDate.formatted(date: .long, time: .omitted))
                }
            }
            
            // 执行情况统计
            Section(header: Text("最近30天执行情况")) {
                VStack(spacing: 15) {
                    // 完成率环形图
                    CompletionRateRing(rate: completionStats.completionRate)
                        .frame(height: 150)
                    
                    // 具体数据
                    HStack(spacing: 30) {
                        StatBox(
                            title: "应执行",
                            value: "\(completionStats.totalRequired)",
                            color: .gray
                        )
                        StatBox(
                            title: "已完成",
                            value: "\(completionStats.completed)",
                            color: ThemeColors.forestGreen
                        )
                        StatBox(
                            title: "完成率",
                            value: String(format: "%.0f%%", completionStats.completionRate * 100),
                            color: ThemeColors.forestGreen
                        )
                    }
                }
                .padding(.vertical)
            }
            
            // 每日执行时间分布
            if !logs.isEmpty {
                Section(header: Text("执行时间分布")) {
                    TimeDistributionChart(logs: logs)
                        .frame(height: 200)
                }
            }
        }
        .navigationTitle("数据统计")
    }
}

// MARK: - 支持类型
private struct CompletionStats {
    let totalRequired: Int
    let completed: Int
    let completionRate: Double
}

// MARK: - 子视图
private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
        }
    }
}

private struct CompletionRateRing: View {
    let rate: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            
            Circle()
                .trim(from: 0, to: rate)
                .stroke(ThemeColors.forestGreen, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: rate)
            
            VStack {
                Text(String(format: "%.0f%%", rate * 100))
                    .font(.title)
                    .bold()
                Text("完成率")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

private struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .foregroundColor(color)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

private struct TimeDistributionChart: View {
    let logs: [MedicineLog]
    
    private var hourlyDistribution: [(hour: Int, count: Int)] {
        var distribution = Array(repeating: 0, count: 24)
        let calendar = Calendar.current
        
        for log in logs {
            let hour = calendar.component(.hour, from: log.timestamp)
            distribution[hour] += 1
        }
        
        return Array(0..<24).map { hour in
            (hour: hour, count: distribution[hour])
        }
    }
    
    var body: some View {
        Chart {
            ForEach(hourlyDistribution, id: \.hour) { item in
                BarMark(
                    x: .value("时间", "\(item.hour):00"),
                    y: .value("次数", item.count)
                )
                .foregroundStyle(ThemeColors.forestGreen.gradient)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 3)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
    }
} 