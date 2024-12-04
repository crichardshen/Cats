import Foundation

class CatDetailViewModel: ObservableObject {
    @Published var cat: Cat
    @Published var showingEditSheet = false
    @Published var showingDeleteAlert = false
    
    init(cat: Cat) {
        self.cat = cat
    }
    
    var formattedBirthDate: String? {
        cat.birthDate?.formatted(date: .long, time: .omitted)
    }
    
    var formattedWeight: String? {
        cat.weight.map { String(format: "%.1f kg", $0) }
    }
} 