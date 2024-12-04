import Foundation

class AddFeedingRecordViewModel: ObservableObject {
    private let catId: UUID
    private let editingRecord: FeedingRecord?
    private let onSave: (FeedingRecord) -> Void
    
    @Published var foodBrand = ""
    @Published var foodType = FeedingRecord.FoodType.dryFood
    @Published var amount = ""
    @Published var timestamp = Date()
    @Published var note = ""
    
    var isEditing: Bool { editingRecord != nil }
    var canSave: Bool { !foodBrand.isEmpty && !amount.isEmpty }
    
    init(catId: UUID, editingRecord: FeedingRecord? = nil, onSave: @escaping (FeedingRecord) -> Void) {
        self.catId = catId
        self.editingRecord = editingRecord
        self.onSave = onSave
        
        if let record = editingRecord {
            self.foodBrand = record.foodBrand
            self.foodType = record.foodType
            self.amount = String(format: "%.0f", record.amount)
            self.timestamp = record.timestamp
            self.note = record.note ?? ""
        }
    }
    
    func save() {
        guard let amountValue = Double(amount) else { return }
        
        let record = FeedingRecord(
            id: editingRecord?.id ?? UUID(),
            catId: catId,
            foodBrand: foodBrand,
            foodType: foodType,
            amount: amountValue,
            timestamp: timestamp,
            note: note.isEmpty ? nil : note
        )
        
        onSave(record)
    }
} 