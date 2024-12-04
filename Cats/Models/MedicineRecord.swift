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
        case daily(times: Int)      // 每天几次
        case weekly(days: [Int])    // 每周几（1-7）
        case monthly(days: [Int])   // 每月几号
        case custom(interval: Int)  // 每隔几天
        
        var description: String {
            switch self {
            case .daily(let times):
                return "每天\(times)次"
            case .weekly(let days):
                let weekDays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
                return "每周" + days.map { weekDays[$0 - 1] }.joined(separator: "、")
            case .monthly(let days):
                return "每月" + days.map { "\($0)号" }.joined(separator: "、")
            case .custom(let interval):
                return "每\(interval)天一次"
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