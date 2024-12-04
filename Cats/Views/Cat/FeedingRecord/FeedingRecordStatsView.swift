import SwiftUI

struct FeedingRecordStatsView: View {
    let statistics: Statistics
    
    var body: some View {
        List {
            Section(header: Text("总览")) {
                StatRow(title: "总量", value: String(format: "%.0fg", statistics.totalAmount))
                StatRow(title: "日均", value: String(format: "%.0fg", statistics.averagePerDay))
            }
            
            Section(header: Text("分类统计")) {
                ForEach(Array(statistics.amountByType.keys.sorted()), id: \.self) { type in
                    if let amount = statistics.amountByType[type] {
                        StatRow(
                            title: type.rawValue,
                            value: String(format: "%.0fg", amount),
                            percentage: amount / statistics.totalAmount * 100
                        )
                    }
                }
            }
        }
        .navigationTitle("数据统计")
    }
}

private struct StatRow: View {
    let title: String
    let value: String
    var percentage: Double?
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let percentage = percentage {
                Text(String(format: "%.1f%%", percentage))
                    .foregroundColor(.gray)
                    .frame(width: 60, alignment: .trailing)
            }
            Text(value)
                .foregroundColor(.gray)
        }
    }
} 