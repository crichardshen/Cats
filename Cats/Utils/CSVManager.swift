import Foundation

class CSVManager {
    static let shared = CSVManager()
    
    private let fileManager = FileManager.default
    
    private var documentsPath: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    private init() {}
    
    // 获取CSV文件路径
    private func getFilePath(for filename: String) -> String {
        (documentsPath as NSString).appendingPathComponent("\(filename).csv")
    }
    
    // 保存饮食记录
    func saveFeedingRecords(_ records: [FeedingRecord], forCat catId: UUID) {
        let filename = "feeding_records_\(catId.uuidString)"
        let path = getFilePath(for: filename)
        
        var csvString = "id,catId,foodBrand,foodType,amount,timestamp,note\n"
        
        for record in records {
            let row = [
                record.id.uuidString,
                record.catId.uuidString,
                record.foodBrand,
                record.foodType.rawValue,
                String(record.amount),
                String(record.timestamp.timeIntervalSince1970),
                record.note ?? ""
            ].map { "\"\($0)\"" }.joined(separator: ",")
            
            csvString.append(row + "\n")
        }
        
        do {
            try csvString.write(toFile: path, atomically: true, encoding: .utf8)
            print("Successfully saved records to: \(path)")
        } catch {
            print("Failed to save records: \(error)")
        }
    }
    
    // 加载饮食记录
    func loadFeedingRecords(forCat catId: UUID) -> [FeedingRecord] {
        let filename = "feeding_records_\(catId.uuidString)"
        let path = getFilePath(for: filename)
        
        guard fileManager.fileExists(atPath: path),
              let csvString = try? String(contentsOfFile: path, encoding: .utf8) else {
            return []
        }
        
        var records: [FeedingRecord] = []
        let rows = csvString.components(separatedBy: "\n")
        
        // 跳过标题行
        for row in rows.dropFirst() where !row.isEmpty {
            let columns = row.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) }
            
            guard columns.count >= 6,
                  let id = UUID(uuidString: columns[0]),
                  let catId = UUID(uuidString: columns[1]),
                  let foodType = FeedingRecord.FoodType(rawValue: columns[3]),
                  let amount = Double(columns[4]),
                  let timestamp = Double(columns[5]) else {
                continue
            }
            
            let record = FeedingRecord(
                id: id,
                catId: catId,
                foodBrand: columns[2],
                foodType: foodType,
                amount: amount,
                timestamp: Date(timeIntervalSince1970: timestamp),
                note: columns.count > 6 ? columns[6] : nil
            )
            
            records.append(record)
        }
        
        return records
    }
} 