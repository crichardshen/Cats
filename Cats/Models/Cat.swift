import Foundation

struct Cat: Identifiable, Codable {
    let id: UUID
    var name: String
    var gender: Gender?
    var birthDate: Date?
    var weight: Double?
    var avatar: Data?
    
    enum Gender: String, Codable, CaseIterable {
        case male = "公猫"
        case female = "母猫"
    }
} 