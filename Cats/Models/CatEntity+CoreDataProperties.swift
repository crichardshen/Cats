import Foundation
import CoreData

extension CatEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CatEntity> {
        return NSFetchRequest<CatEntity>(entityName: "CatEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var gender: String?
    @NSManaged public var birthDate: Date?
    @NSManaged public var weight: Double
    @NSManaged public var avatar: Data?
    
    var wrappedName: String {
        name ?? "未命名猫咪"
    }
    
    var wrappedGender: Cat.Gender? {
        get { gender.flatMap { Cat.Gender(rawValue: $0) } }
        set { gender = newValue?.rawValue }
    }
    
    func toCat() -> Cat {
        Cat(
            id: id ?? UUID(),
            name: wrappedName,
            gender: wrappedGender,
            birthDate: birthDate,
            weight: weight,
            avatar: avatar
        )
    }
    
    func update(from cat: Cat) {
        id = cat.id
        name = cat.name
        gender = cat.gender?.rawValue
        birthDate = cat.birthDate
        weight = cat.weight ?? 0
        avatar = cat.avatar
    }
} 