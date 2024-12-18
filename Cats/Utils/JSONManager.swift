import Foundation

class JSONManager {
    static let shared = JSONManager()
    
    private let fileManager = FileManager.default
    
    private var documentsPath: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    private init() {}
    
    // MARK: - 猫咪基本信息
    func saveCats(_ cats: [Cat]) {
        let filename = "cats"
        let path = getFilePath(for: filename)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(cats)
            try data.write(to: URL(fileURLWithPath: path))
            print("Successfully saved cats to: \(path)")
        } catch {
            print("Failed to save cats: \(error)")
        }
    }
    
    func loadCats() -> [Cat] {
        let filename = "cats"
        let path = getFilePath(for: filename)
        
        guard fileManager.fileExists(atPath: path),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Cat].self, from: data)
        } catch {
            print("Failed to load cats: \(error)")
            return []
        }
    }
    
    // MARK: - 饮食记录
    func saveFeedingRecords(_ records: [FeedingRecord], forCat catId: UUID) {
        let filename = "feeding_records_\(catId.uuidString)"
        let path = getFilePath(for: filename)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(records)
            try data.write(to: URL(fileURLWithPath: path))
            print("Successfully saved records to: \(path)")
        } catch {
            print("Failed to save records: \(error)")
        }
    }
    
    func loadFeedingRecords(forCat catId: UUID) -> [FeedingRecord] {
        let filename = "feeding_records_\(catId.uuidString)"
        let path = getFilePath(for: filename)
        
        guard fileManager.fileExists(atPath: path),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([FeedingRecord].self, from: data)
        } catch {
            print("Failed to load records: \(error)")
            return []
        }
    }
    
    // MARK: - 体重记录
    func saveWeightRecords(_ records: [WeightRecord], forCat catId: UUID) {
        let filename = "weight_records_\(catId.uuidString)"
        let path = getFilePath(for: filename)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(records)
            try data.write(to: URL(fileURLWithPath: path))
            print("Successfully saved weight records to: \(path)")
        } catch {
            print("Failed to save weight records: \(error)")
        }
    }
    
    func loadWeightRecords(forCat catId: UUID) -> [WeightRecord] {
        let filename = "weight_records_\(catId.uuidString)"
        let path = getFilePath(for: filename)
        
        guard fileManager.fileExists(atPath: path),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([WeightRecord].self, from: data)
        } catch {
            print("Failed to load weight records: \(error)")
            return []
        }
    }
    
    // MARK: - 医药记录
    func saveMedicines(_ medicines: [Medicine], forCat catId: UUID) {
        let filename = "medicines_\(catId.uuidString)"
        let path = getFilePath(for: filename)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(medicines)
            try data.write(to: URL(fileURLWithPath: path))
            print("Successfully saved medicines to: \(path)")
        } catch {
            print("Failed to save medicines: \(error)")
        }
    }
    
    func loadMedicines(forCat catId: UUID) -> [Medicine] {
        let filename = "medicines_\(catId.uuidString)"
        let path = getFilePath(for: filename)
        
        guard fileManager.fileExists(atPath: path),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Medicine].self, from: data)
        } catch {
            print("Failed to load medicines: \(error)")
            return []
        }
    }
    
    func saveMedicineLogs(_ logs: [MedicineLog], forCat catId: UUID) {
        let filename = "medicine_logs_\(catId.uuidString)"
        let path = getFilePath(for: filename)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(logs)
            try data.write(to: URL(fileURLWithPath: path))
            print("Successfully saved medicine logs to: \(path)")
        } catch {
            print("Failed to save medicine logs: \(error)")
        }
    }
    
    func loadMedicineLogs(forCat catId: UUID) -> [MedicineLog] {
        let filename = "medicine_logs_\(catId.uuidString)"
        let path = getFilePath(for: filename)
        
        guard fileManager.fileExists(atPath: path),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([MedicineLog].self, from: data)
        } catch {
            print("Failed to load medicine logs: \(error)")
            return []
        }
    }
    
    private func getFilePath(for filename: String) -> String {
        (documentsPath as NSString).appendingPathComponent("\(filename).json")
    }
    
    // 添加这个方法来打印文件路径
    func printDocumentsPath() {
        print("Documents Directory Path: \(documentsPath)")
        
        // 打印所有保存的文件
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentsPath)
            print("Saved JSON files:")
            files.filter { $0.hasSuffix(".json") }.forEach { print("- \($0)") }
        } catch {
            print("Error listing files: \(error)")
        }
    }
} 