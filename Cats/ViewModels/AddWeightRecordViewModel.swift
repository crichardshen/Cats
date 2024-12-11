import Foundation

class AddWeightRecordViewModel: ObservableObject {
    private let catId: UUID
    private let editingRecord: WeightRecord?
    private let onSave: (WeightRecord) -> Void
    
    @Published var weight = ""
    @Published var timestamp = Date()
    @Published var note = ""
    
    var isEditing: Bool { editingRecord != nil }
    var canSave: Bool { !weight.isEmpty }
    
    init(catId: UUID, editingRecord: WeightRecord? = nil, onSave: @escaping (WeightRecord) -> Void) {
        self.catId = catId
        self.editingRecord = editingRecord
        self.onSave = onSave
        
        if let record = editingRecord {
            self.weight = String(format: "%.1f", record.weight)
            self.timestamp = record.timestamp
            self.note = record.note ?? ""
        }
    }
    
    func save() {
        guard let weightValue = Double(weight) else { return }
        
        let record = WeightRecord(
            id: editingRecord?.id ?? UUID(),
            catId: catId,
            weight: weightValue,
            timestamp: timestamp,
            note: note.isEmpty ? nil : note
        )
        
        onSave(record)
    }
} 