import Foundation

// 添加新的结构体来表示每日多次用药的单次记录
struct DailyMedicineInstance: Identifiable {
    let id: Int  // 第几次服用，从1开始
    let medicine: Medicine
    var isCompleted: Bool
    var completedTime: Date?
}

class MedicineViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []
    @Published var logs: [MedicineLog] = []
    let catId: UUID
    
    init(catId: UUID) {
        self.catId = catId
        loadData()
    }
    
    private func loadData() {
        medicines = JSONManager.shared.loadMedicines(forCat: catId)
        logs = JSONManager.shared.loadMedicineLogs(forCat: catId)
    }
    
    func addMedicine(_ medicine: Medicine) {
        medicines.append(medicine)
        saveMedicines()
    }
    
    func removeMedicine(_ medicine: Medicine) {
        medicines.removeAll { $0.id == medicine.id }
        // 同时删除相关的记录
        logs.removeAll { $0.medicineId == medicine.id }
        saveMedicines()
        saveLogs()
    }
    
    func toggleInstanceLog(for medicine: Medicine, instanceId: Int, on date: Date = Date()) {
        let calendar = Calendar.current
        
        // 检查是否已有记录
        if let existingLog = findInstanceLog(medicineId: medicine.id, instanceId: instanceId, on: date) {
            // 如果已有记录，则删除（取消选中）
            logs.removeAll { $0.id == existingLog.id }
        } else {
            // 如果没有记录，则添加新记录（选中）
            let log = MedicineLog(
                id: UUID(),
                medicineId: medicine.id,
                instanceId: instanceId,
                timestamp: Date()
            )
            logs.append(log)
        }
        saveLogs()
    }
    
    func findLog(for medicine: Medicine, on date: Date) -> MedicineLog? {
        let calendar = Calendar.current
        return logs.first { log in
            log.medicineId == medicine.id &&
            calendar.isDate(log.timestamp, inSameDayAs: date)
        }
    }
    
    private func saveMedicines() {
        JSONManager.shared.saveMedicines(medicines, forCat: catId)
    }
    
    private func saveLogs() {
        JSONManager.shared.saveMedicineLogs(logs, forCat: catId)
    }
    
    // 获取指定日期需要服用/注射的药物列表
    func medicinesForDate(_ date: Date) -> [DailyMedicineInstance] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        return medicines.filter { medicine in
            // 将开始日期标准化到当天的开始时间
            let startOfStartDate = calendar.startOfDay(for: medicine.startDate)
            
            // 检查日期是否在有效范围内
            guard startOfDay >= startOfStartDate else { return false }
            if let endDate = medicine.endDate {
                let startOfEndDate = calendar.startOfDay(for: endDate)
                guard startOfDay <= startOfEndDate else { return false }
            }
            
            // 检查频率
            switch medicine.frequency {
            case .daily:
                return true
            case .weekly(let days):
                // 获取周几（1是周日，2是周一，以此类推）
                let weekday = calendar.component(.weekday, from: date)
                return days.contains(weekday)
            case .monthly(let days):
                let day = calendar.component(.day, from: date)
                return days.contains(day)
            case .custom(let interval):
                let days = calendar.dateComponents([.day], from: startOfStartDate, to: startOfDay).day ?? 0
                return days % interval == 0
            }
        }.flatMap { medicine -> [DailyMedicineInstance] in
            // 如果是每日多次，创建多个实例
            if case .daily(let times) = medicine.frequency {
                return (1...times).map { index in
                    let instanceId = "\(medicine.id)-\(index)"
                    let log = findInstanceLog(medicineId: medicine.id, instanceId: index, on: date)
                    return DailyMedicineInstance(
                        id: index,
                        medicine: medicine,
                        isCompleted: log != nil,
                        completedTime: log?.timestamp
                    )
                }
            } else {
                // 其他频率只创建一个实例
                return [DailyMedicineInstance(
                    id: 1,
                    medicine: medicine,
                    isCompleted: findLog(for: medicine, on: date) != nil,
                    completedTime: findLog(for: medicine, on: date)?.timestamp
                )]
            }
        }
    }
    
    private func findInstanceLog(medicineId: UUID, instanceId: Int, on date: Date) -> MedicineLog? {
        let calendar = Calendar.current
        return logs.first { log in
            log.medicineId == medicineId &&
            log.instanceId == instanceId &&
            calendar.isDate(log.timestamp, inSameDayAs: date)
        }
    }
    
    func updateMedicine(_ medicine: Medicine) {
        if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
            medicines[index] = medicine
            saveMedicines()
        }
    }
} 