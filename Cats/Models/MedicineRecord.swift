import Foundation

// 药物或疫苗的基本信息
struct Medicine: Identifiable, Codable {
    let id: UUID
    let catId: UUID
    var name: String
    var type: MedicineType
    var frequency: Frequency
    var startDate: Date
    var endDate: Date?
    var note: String?
    
    enum MedicineType: String, Codable, CaseIterable {
        case medicine = "药物"
        case vaccine = "疫苗"
    }
    
    enum Frequency: Codable {
        case daily(times: Int)
        case weekly(days: [Int])
        case monthly(days: [Int])
        case custom(years: Int, months: Int, days: Int, hours: Int)
        
        var description: String {
            switch self {
            case .daily(let times):
                return "每天\(times)次"
            case .weekly(let days):
                let weekDays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
                return "每周" + days.map { weekDays[$0 - 1] }.joined(separator: "、")
            case .monthly(let days):
                return "每月" + days.map { "\($0)号" }.joined(separator: "、")
            case .custom(let years, let months, let days, let hours):
                var parts: [String] = []
                if years > 0 { parts.append("\(years)年") }
                if months > 0 { parts.append("\(months)月") }
                if days > 0 { parts.append("\(days)天") }
                if hours > 0 { parts.append("\(hours)小时") }
                return "每隔" + parts.joined()
            }
        }
        
        func nextOccurrence(after date: Date = Date()) -> Date? {
            let calendar = Calendar.current
            let now = date
            
            switch self {
            case .custom(let years, let months, let days, let hours):
                var dateComponents = DateComponents()
                dateComponents.year = years
                dateComponents.month = months
                dateComponents.day = days
                dateComponents.hour = hours
                
                let roundedHour = calendar.date(
                    bySetting: .minute,
                    value: 0,
                    of: calendar.date(
                        bySetting: .second,
                        value: 0,
                        of: now
                    ) ?? now
                ) ?? now
                
                return calendar.date(byAdding: dateComponents, to: roundedHour)
            default:
                return nil
            }
        }
    }
}

// 药物或疫苗的执行记录
struct MedicineLog: Identifiable, Codable {
    let id: UUID
    let medicineId: UUID
    let instanceId: Int  // 添加实例ID来区分同一天的多次用药
    let timestamp: Date
    var note: String?
} 