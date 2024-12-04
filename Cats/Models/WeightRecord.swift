import Foundation

struct WeightRecord: Identifiable, Codable {
    let id: UUID
    let catId: UUID
    var weight: Double      // 单位：kg
    var timestamp: Date
    var note: String?
    
    // 计算体重变化（与上一次记录相比）
    func weightChange(from previousRecord: WeightRecord?) -> Double? {
        guard let previous = previousRecord else { return nil }
        return weight - previous.weight
    }
} 