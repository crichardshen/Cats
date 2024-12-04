import Foundation

class CatListViewModel: ObservableObject {
    @Published var cats: [Cat] = []
    @Published var searchText = ""
    
    init() {
        loadCats()
        JSONManager.shared.printDocumentsPath()
    }
    
    private func loadCats() {
        cats = JSONManager.shared.loadCats()
    }
    
    func addCat(_ cat: Cat) {
        cats.append(cat)
        saveCats()
    }
    
    func updateCat(_ cat: Cat) {
        if let index = cats.firstIndex(where: { $0.id == cat.id }) {
            cats[index] = cat
            saveCats()
        }
    }
    
    func deleteCat(_ cat: Cat) {
        cats.removeAll { $0.id == cat.id }
        saveCats()
    }
    
    private func saveCats() {
        JSONManager.shared.saveCats(cats)
    }
    
    var filteredCats: [Cat] {
        if searchText.isEmpty {
            return cats
        }
        return cats.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
} 