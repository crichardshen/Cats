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
        let endOfSelectedDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
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
                
            case .custom(let years, let months, let days, let hours):
                // 计算间隔时间（转换为秒）
                let intervalInSeconds = TimeInterval(
                    years * 365 * 24 * 3600 +
                    months * 30 * 24 * 3600 +
                    days * 24 * 3600 +
                    hours * 3600
                )
                
                // 获取从开始时间到选定日期结束时间的所有用药时间点
                var instances: [DailyMedicineInstance] = []
                var currentTime = medicine.startDate
                var dailyInstanceId = 1  // 每天的实例 ID 从 1 开始
                
                while currentTime <= endOfSelectedDate {
                    // 如果时间点在选定日期内，添加一个实例
                    if calendar.isDate(currentTime, inSameDayAs: date) {
                        let log = findInstanceLog(medicineId: medicine.id, instanceId: dailyInstanceId, on: date)
                        instances.append(DailyMedicineInstance(
                            id: dailyInstanceId,  // 使用每天的实例 ID
                            medicine: medicine,
                            date: currentTime,
                            isCompleted: log != nil,
                            completedTime: log?.timestamp
                        ))
                        dailyInstanceId += 1  // 只在添加实例时增加 ID
                    }
                    
                    // 移动到下一个时间点
                    currentTime = currentTime.addingTimeInterval(intervalInSeconds)
                }
                
                return instances
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