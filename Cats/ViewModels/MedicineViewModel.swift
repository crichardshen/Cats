import Foundation

// 添加新的结构体来表示每日多次用药的单次记录
struct DailyMedicineInstance: Identifiable {
    let id: Int  // 第几次服用，从1开始
    let medicine: Medicine
    let date: Date  // 添加日期信息
    var isCompleted: Bool
    var completedTime: Date?
}

class MedicineViewModel: ObservableObject {
    let catId: UUID
    @Published var medicines: [Medicine] = []
    @Published var logs: [MedicineLog] = []
    @Published var selectedDate = Date()  // 添加选中日期属性
    var onStatusChanged: (() -> Void)?
    
    init(catId: UUID) {
        self.catId = catId
        loadMedicines()
        loadLogs()
    }
    
    private func loadMedicines() {
        medicines = JSONManager.shared.loadMedicines(forCat: catId)
    }
    
    private func loadLogs() {
        logs = JSONManager.shared.loadMedicineLogs(forCat: catId)
    }
    
    func addMedicine(_ medicine: Medicine) {
        medicines.append(medicine)
        saveMedicines()
        onStatusChanged?()  // 添加这行，触发状态更新
    }
    
    func removeMedicine(_ medicine: Medicine) {
        medicines.removeAll { $0.id == medicine.id }
        logs.removeAll { $0.medicineId == medicine.id }
        saveMedicines()
        saveLogs()
        onStatusChanged?()  // 添加这行，触发状态更新
    }
    
    func toggleInstanceLog(for medicine: Medicine, instanceId: Int, on date: Date = Date()) {
        let calendar = Calendar.current
        let startOfSelectedDate = calendar.startOfDay(for: date)
        let startOfToday = calendar.startOfDay(for: Date())
        
        // 检查是否已有记录
        if let existingLog = findInstanceLog(medicineId: medicine.id, instanceId: instanceId, on: date) {
            // 如果已有记录，则删除（取消选中）
            logs.removeAll { $0.id == existingLog.id }
        } else {
            // 检查是否在有效期内
            let startDate = calendar.startOfDay(for: medicine.startDate)
            let endDate = medicine.endDate.map { calendar.startOfDay(for: $0) }
            
            let isWithinDateRange = startOfSelectedDate >= startDate && 
                (endDate == nil || startOfSelectedDate <= endDate!)
            
            // 检查是否是未来日期
            let isFutureDate = startOfSelectedDate > startOfToday
            
            // 如果在有效期内且不是未来日期，则添加记录
            if isWithinDateRange && !isFutureDate {
                let log = MedicineLog(
                    id: UUID(),
                    medicineId: medicine.id,
                    instanceId: instanceId,
                    timestamp: date,
                    note: nil
                )
                logs.append(log)
            }
        }
        
        saveLogs()
        onStatusChanged?()
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
        let startOfSelectedDate = calendar.startOfDay(for: date)
        let startOfToday = calendar.startOfDay(for: Date())
        
        return medicines.flatMap { medicine -> [DailyMedicineInstance] in
            // 检查日期是否在药物的有效期内
            let startDate = calendar.startOfDay(for: medicine.startDate)
            let endDate = medicine.endDate.map { calendar.startOfDay(for: $0) }
            
            let isWithinDateRange = startOfSelectedDate >= startDate && 
                (endDate == nil || startOfSelectedDate <= endDate!)
            
            guard isWithinDateRange else { return [] }
            
            // 根据频率创建实例
            switch medicine.frequency {
            case .daily(let times):
                return (1...times).map { instanceId in
                    let log = findInstanceLog(medicineId: medicine.id, instanceId: instanceId, on: date)
                    return DailyMedicineInstance(
                        id: instanceId,
                        medicine: medicine,
                        date: date,
                        isCompleted: log != nil,
                        completedTime: log?.timestamp
                    )
                }
                
            case .weekly(let days):
                let weekday = calendar.component(.weekday, from: date)
                guard days.contains(weekday) else { return [] }
                return [DailyMedicineInstance(
                    id: 1,
                    medicine: medicine,
                    date: date,
                    isCompleted: findInstanceLog(medicineId: medicine.id, instanceId: 1, on: date) != nil,
                    completedTime: findInstanceLog(medicineId: medicine.id, instanceId: 1, on: date)?.timestamp
                )]
                
            case .monthly(let days):
                let day = calendar.component(.day, from: date)
                guard days.contains(day) else { return [] }
                return [DailyMedicineInstance(
                    id: 1,
                    medicine: medicine,
                    date: date,
                    isCompleted: findInstanceLog(medicineId: medicine.id, instanceId: 1, on: date) != nil,
                    completedTime: findInstanceLog(medicineId: medicine.id, instanceId: 1, on: date)?.timestamp
                )]
                
            case .custom:
                // 暂时简单处理自定义频率，每天一次
                return [DailyMedicineInstance(
                    id: 1,
                    medicine: medicine,
                    date: date,
                    isCompleted: findInstanceLog(medicineId: medicine.id, instanceId: 1, on: date) != nil,
                    completedTime: findInstanceLog(medicineId: medicine.id, instanceId: 1, on: date)?.timestamp
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
            onStatusChanged?()  // 添加这行，触发状态更新
        }
    }
} 