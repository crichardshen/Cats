import Foundation

class AddMedicineViewModel: ObservableObject {
    private let catId: UUID
    private let editingMedicine: Medicine?
    private let onSave: (Medicine) -> Void
    
    @Published var name = ""
    @Published var type = Medicine.MedicineType.medicine
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(86400 * 7) // 默认一周
    @Published var frequency = Medicine.Frequency.daily(times: 1)
    @Published var note = ""
    @Published var hasEndDate = false
    
    var isEditing: Bool { editingMedicine != nil }
    
    var canSave: Bool {
        !name.isEmpty && isValidFrequency
    }
    
    private var isValidFrequency: Bool {
        switch frequency {
        case .daily(let times):
            return times > 0
        case .weekly(let days):
            return !days.isEmpty
        case .monthly(let days):
            return !days.isEmpty
        case .custom(let years, let months, let days, let hours):
            return years > 0 || months > 0 || days > 0 || hours > 0
        }
    }
    
    init(catId: UUID, editingMedicine: Medicine? = nil, onSave: @escaping (Medicine) -> Void) {
        self.catId = catId
        self.editingMedicine = editingMedicine
        self.onSave = onSave
        
        // 如果是编辑模式，初始化现有数据
        if let medicine = editingMedicine {
            self.name = medicine.name
            self.type = medicine.type
            self.startDate = medicine.startDate
            if let endDate = medicine.endDate {
                self.endDate = endDate
                self.hasEndDate = true
            }
            self.frequency = medicine.frequency
            self.note = medicine.note ?? ""
        }
    }
    
    func save() {
        let medicine = Medicine(
            id: editingMedicine?.id ?? UUID(),
            catId: catId,
            name: name,
            type: type,
            frequency: frequency,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            note: note.isEmpty ? nil : note
        )
        
        onSave(medicine)
    }
} 