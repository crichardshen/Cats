import SwiftUI
import Charts

struct WeightRecordStatsView: View {
    let statistics: WeightStatistics
    
    var body: some View {
        List {
            // 基本统计信息
            Section(header: Text("总览")) {
                if let currentWeight = statistics.currentWeight {
                    StatRow(title: "当前体重", value: String(format: "%.2f kg", currentWeight))
                }
                
                if let averageWeight = statistics.averageWeight {
                    StatRow(title: "平均体重", value: String(format: "%.2f kg", averageWeight))
                }
                
                if let totalChange = statistics.totalChange {
                    StatRow(
                        title: "总体变化",
                        value: String(format: "%.2f kg", abs(totalChange)),
                        trend: totalChange >= 0 ? .increase : .decrease
                    )
                }
            }
            
            // 体重变化趋势图
            if !statistics.records.isEmpty {
                Section(header: Text("变化趋势")) {
                    WeightTrendChart(records: statistics.records)
                        .frame(height: 200)
                }
            }
        }
        .navigationTitle("体重统计")
    }
}

// MARK: - 子视图
private struct StatRow: View {
    let title: String
    let value: String
    var trend: Trend?
    
    enum Trend {
        case increase, decrease
        
        var color: Color {
            switch self {
            case .increase: return .red
            case .decrease: return .green
            }
        }
        
        var icon: String {
            switch self {
            case .increase: return "arrow.up.right"
            case .decrease: return "arrow.down.right"
            }
        }
    }
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let trend = trend {
                Image(systemName: trend.icon)
                    .foregroundColor(trend.color)
            }
            Text(value)
                .foregroundColor(.gray)
        }
    }
}

private struct WeightTrendChart: View {
    let records: [WeightRecord]
    
    var body: some View {
        Chart {
            ForEach(records) { record in
                LineMark(
                    x: .value("日期", record.timestamp),
                    y: .value("体重", record.weight)
                )
                .foregroundStyle(ThemeColors.forestGreen)
                
                PointMark(
                    x: .value("日期", record.timestamp),
                    y: .value("体重", record.weight)
                )
                .foregroundStyle(ThemeColors.forestGreen)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let weight = value.as(Double.self) {
                        Text(String(format: "%.1f", weight))
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        WeightRecordStatsView(statistics: WeightStatistics(
            currentWeight: 4.5,
            initialWeight: 4.0,
            totalChange: 0.5,
            records: [
                WeightRecord(id: UUID(), catId: UUID(), weight: 4.0, timestamp: Date().addingTimeInterval(-86400 * 7)),
                WeightRecord(id: UUID(), catId: UUID(), weight: 4.2, timestamp: Date().addingTimeInterval(-86400 * 5)),
                WeightRecord(id: UUID(), catId: UUID(), weight: 4.3, timestamp: Date().addingTimeInterval(-86400 * 3)),
                WeightRecord(id: UUID(), catId: UUID(), weight: 4.5, timestamp: Date())
            ]
        ))
    }
} 