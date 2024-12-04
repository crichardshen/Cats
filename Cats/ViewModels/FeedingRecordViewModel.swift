import Foundation

class FeedingRecordViewModel: ObservableObject {
    @Published var records: [FeedingRecord] = []
    @Published var searchText = ""
    @Published var selectedFoodType: FeedingRecord.FoodType?
    @Published var selectedDateRange: DateRange = .all
    let catId: UUID
    
    enum DateRange: String, CaseIterable {
        case all = "全部"
        case today = "今天"
        case week = "本周"
        case month = "本月"
        
        var startDate: Date? {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .all:
                return nil
            case .today:
                return calendar.startOfDay(for: now)
            case .week:
                return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
            case .month:
                return calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            }
        }
    }
    
    var filteredRecords: [FeedingRecord] {
        var result = records
        
        // 搜索过滤
        if !searchText.isEmpty {
            result = result.filter { record in
                record.foodBrand.localizedCaseInsensitiveContains(searchText) ||
                record.note?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // 类型过滤
        if let foodType = selectedFoodType {
            result = result.filter { $0.foodType == foodType }
        }
        
        // 日期过滤
        if let startDate = selectedDateRange.startDate {
            result = result.filter { record in
                record.timestamp >= startDate
            }
        }
        
        return result.sorted { $0.timestamp > $1.timestamp }
    }
    
    var groupedRecords: [(String, [FeedingRecord])] {
        let grouped = Dictionary(grouping: filteredRecords) { record in
            Calendar.current.startOfDay(for: record.timestamp)
        }
        return grouped.map { (date, records) in
            (date.formatted(date: .long, time: .omitted), records)
        }.sorted { $0.0 > $1.0 }
    }
    
    // 统计数据
    var statistics: Statistics {
        let total = filteredRecords.reduce(0.0) { $0 + $1.amount }
        let avgPerDay = calculateAveragePerDay()
        let byType = Dictionary(grouping: filteredRecords) { $0.foodType }
            .mapValues { records in
                records.reduce(0.0) { $0 + $1.amount }
            }
        
        return Statistics(
            totalAmount: total,
            averagePerDay: avgPerDay,
            amountByType: byType
        )
    }
    
    private func calculateAveragePerDay() -> Double {
        guard !filteredRecords.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let dates = Set(filteredRecords.map { calendar.startOfDay(for: $0.timestamp) })
        return filteredRecords.reduce(0.0) { $0 + $1.amount } / Double(dates.count)
    }
    
    init(catId: UUID) {
        self.catId = catId
        loadRecords()
    }
    
    private func loadRecords() {
        records = JSONManager.shared.loadFeedingRecords(forCat: catId)
    }
    
    func addRecord(_ record: FeedingRecord) {
        records.append(record)
        saveRecords()
    }
    
    func removeRecord(_ record: FeedingRecord) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    func updateRecord(_ record: FeedingRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            saveRecords()
        }
    }
    
    private func saveRecords() {
        JSONManager.shared.saveFeedingRecords(records, forCat: catId)
    }
    
    var sortedRecords: [FeedingRecord] {
        records.sorted { $0.timestamp > $1.timestamp }
    }
}

// 统计数据模型
struct Statistics {
    let totalAmount: Double
    let averagePerDay: Double
    let amountByType: [FeedingRecord.FoodType: Double]
} 