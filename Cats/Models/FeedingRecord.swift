import Foundation

struct FeedingRecord: Identifiable, Codable {
    let id: UUID
    let catId: UUID
    var foodBrand: String
    var foodType: FoodType
    var amount: Double  // 单位：克
    var timestamp: Date
    var note: String?
    
    enum FoodType: String, Codable, CaseIterable, Comparable {
        case dryFood = "干粮"
        case wetFood = "湿粮"
        case snack = "零食"
        case other = "其他"
        
        // 实现 Comparable 协议
        static func < (lhs: FoodType, rhs: FoodType) -> Bool {
            let order: [FoodType] = [.dryFood, .wetFood, .snack, .other]
            let lhsIndex = order.firstIndex(of: lhs) ?? 0
            let rhsIndex = order.firstIndex(of: rhs) ?? 0
            return lhsIndex < rhsIndex
        }
    }
} 