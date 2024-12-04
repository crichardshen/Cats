import Foundation

class CatDataManager: ObservableObject {
    static let shared = CatDataManager()
    
    @Published var cats: [Cat] = []
    
    private init() {}
    
    func addCat(_ cat: Cat) {
        cats.append(cat)
    }
    
    func updateCat(_ cat: Cat) {
        if let index = cats.firstIndex(where: { $0.id == cat.id }) {
            cats[index] = cat
        }
    }
    
    func deleteCat(_ cat: Cat) {
        cats.removeAll { $0.id == cat.id }
    }
} 