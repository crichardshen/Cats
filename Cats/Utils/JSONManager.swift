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