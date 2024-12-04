import Foundation

class WeightRecordViewModel: ObservableObject {
    @Published var records: [WeightRecord] = []
    @Published var searchText = ""
    @Published var selectedDateRange: DateRange = .all
    let catId: UUID
    
    enum DateRange: String, CaseIterable {
        case all = "全部"
        case week = "最近一周"
        case month = "最近一月"
        case threeMonths = "最近三月"
        
        var startDate: Date? {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .all:
                return nil
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)
            case .threeMonths:
                return calendar.date(byAdding: .month, value: -3, to: now)
            }
        }
    }
    
    init(catId: UUID) {
        self.catId = catId
        loadRecords()
    }
    
    private func loadRecords() {
        records = JSONManager.shared.loadWeightRecords(forCat: catId)
    }
    
    func addRecord(_ record: WeightRecord) {
        records.append(record)
        saveRecords()
    }
    
    func updateRecord(_ record: WeightRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            saveRecords()
        }
    }
    
    func removeRecord(_ record: WeightRecord) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    private func saveRecords() {
        JSONManager.shared.saveWeightRecords(records, forCat: catId)
    }
    
    var filteredAndSortedRecords: [WeightRecord] {
        var result = records
        
        if let startDate = selectedDateRange.startDate {
            result = result.filter { $0.timestamp >= startDate }
        }
        
        return result.sorted { $0.timestamp > $1.timestamp }
    }
    
    var statistics: WeightStatistics {
        let sortedRecords = filteredAndSortedRecords
        let currentWeight = sortedRecords.first?.weight
        let initialWeight = sortedRecords.last?.weight
        let totalChange = initialWeight.flatMap { initial in
            currentWeight.map { current in
                current - initial
            }
        }
        
        return WeightStatistics(
            currentWeight: currentWeight,
            initialWeight: initialWeight,
            totalChange: totalChange,
            records: sortedRecords
        )
    }
}

struct WeightStatistics {
    let currentWeight: Double?
    let initialWeight: Double?
    let totalChange: Double?
    let records: [WeightRecord]
    
    var averageWeight: Double? {
        guard !records.isEmpty else { return nil }
        let total = records.reduce(0.0) { $0 + $1.weight }
        return total / Double(records.count)
    }
} 