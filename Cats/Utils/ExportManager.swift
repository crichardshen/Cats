import Foundation
import UIKit
import UniformTypeIdentifiers

class ExportManager {
    static let shared = ExportManager()
    private init() {}
    
    func exportCatData(_ cat: Cat) -> URL? {
        // 创建要导出的数据结构
        let exportData = CatExportData(
            cat: cat,
            feedingRecords: JSONManager.shared.loadFeedingRecords(forCat: cat.id),
            weightRecords: JSONManager.shared.loadWeightRecords(forCat: cat.id),
            medicines: JSONManager.shared.loadMedicines(forCat: cat.id),
            medicineLogs: JSONManager.shared.loadMedicineLogs(forCat: cat.id)
        )
        
        // 获取导出目录
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportPath = documentsPath.appendingPathComponent("Exports", isDirectory: true)
        
        do {
            // 创建导出目录（如果不存在）
            try FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true)
            
            // 创建导出文件路径
            let fileName = "\(cat.name)_DataExport.json"
            let fileURL = exportPath.appendingPathComponent(fileName)
            
            // 编码数据
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(exportData)
            
            // 写入文件
            try jsonData.write(to: fileURL)
            
            // 标记文件可以被其他应用访问
            try (fileURL as NSURL).setResourceValue(URLFileProtection.none, forKey: .fileProtectionKey)
            
            return fileURL
            
        } catch {
            print("导出失败: \(error)")
            return nil
        }
    }
    
    func showInFiles(_ url: URL, from viewController: UIViewController) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [url])
        viewController.present(documentPicker, animated: true)
    }
    
    func importCatData(from url: URL, existingCats: [Cat]) -> Bool {
        do {
            // 直接读取文件，不使用安全作用域资源
            let data = try Data(contentsOf: url)
            print("读取文件成功，数据大小: \(data.count) bytes")
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let importData = try decoder.decode(CatExportData.self, from: data)
                print("解码成功，宠物名称: \(importData.cat.name)")
                
                // 处理重名情况
                var newCatName = importData.cat.name
                var suffix = 2
                while existingCats.contains(where: { $0.name == newCatName }) {
                    newCatName = "\(importData.cat.name)_\(suffix)"
                    suffix += 1
                }
                
                // 创建新的宠物记录
                let newCat = Cat(
                    id: UUID(),
                    name: newCatName,
                    gender: importData.cat.gender,
                    birthDate: importData.cat.birthDate,
                    weight: importData.cat.weight,
                    avatar: importData.cat.avatar
                )
                
                // 保存宠物基本信息
                var currentCats = JSONManager.shared.loadCats()  // 载现有的宠物
                currentCats.append(newCat)  // 添加新宠物
                JSONManager.shared.saveCats(currentCats)  // 保存所有宠物
                print("保存新宠物成功: \(newCatName)")
                
                // 更新所有相关记录
                let updatedFeedingRecords = importData.feedingRecords.map { record in
                    FeedingRecord(
                        id: UUID(),
                        catId: newCat.id,
                        foodBrand: record.foodBrand,
                        foodType: record.foodType,
                        amount: record.amount,
                        timestamp: record.timestamp,
                        note: record.note
                    )
                }
                
                let updatedWeightRecords = importData.weightRecords.map { record in
                    WeightRecord(
                        id: UUID(),
                        catId: newCat.id,
                        weight: record.weight,
                        timestamp: record.timestamp,
                        note: record.note
                    )
                }
                
                let updatedMedicines = importData.medicines.map { medicine in
                    Medicine(
                        id: UUID(),
                        catId: newCat.id,
                        name: medicine.name,
                        type: medicine.type,
                        frequency: medicine.frequency,
                        startDate: medicine.startDate,
                        endDate: medicine.endDate,
                        note: medicine.note
                    )
                }
                
                let updatedMedicineLogs = importData.medicineLogs.map { log in
                    MedicineLog(
                        id: UUID(),
                        medicineId: log.medicineId,  // 这里需要更新为新的 medicineId
                        instanceId: log.instanceId,
                        timestamp: log.timestamp,
                        note: log.note
                    )
                }
                
                // 保存所有相关记录
                JSONManager.shared.saveFeedingRecords(updatedFeedingRecords, forCat: newCat.id)
                JSONManager.shared.saveWeightRecords(updatedWeightRecords, forCat: newCat.id)
                JSONManager.shared.saveMedicines(updatedMedicines, forCat: newCat.id)
                JSONManager.shared.saveMedicineLogs(updatedMedicineLogs, forCat: newCat.id)
                
                return true
            } catch {
                print("JSON 解码失败: \(error)")
                return false
            }
        } catch {
            print("读取文件失败: \(error)")
            return false
        }
    }
    
    func showFilePicker(from viewController: UIViewController, completion: @escaping (URL?) -> Void) {
        print("准备显示文件选择器...")
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        documentPicker.shouldShowFileExtensions = true
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        
        let delegate = DocumentPickerDelegate(completion: completion)
        objc_setAssociatedObject(documentPicker, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        documentPicker.delegate = delegate
        
        DispatchQueue.main.async {
            print("显示文件选择器...")
            viewController.present(documentPicker, animated: true)
        }
    }
}

// 文件选择器代理
private class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    let completion: (URL?) -> Void
    
    init(completion: @escaping (URL?) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let sourceURL = urls.first else { return }
        
        // 确保获取文件访问权限
        guard sourceURL.startAccessingSecurityScopedResource() else {
            print("无法获取文件访问权限")
            completion(nil)
            return
        }
        
        defer {
            sourceURL.stopAccessingSecurityScopedResource()
        }
        
        do {
            // 直接读取源文件内容
            let data = try Data(contentsOf: sourceURL)
            
            // 创建目标文件路径
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent(sourceURL.lastPathComponent)
            
            // 直接写入数据
            try data.write(to: destinationURL)
            print("文件复制成功: \(destinationURL.path)")
            
            // 确保文件可读
            try (destinationURL as NSURL).setResourceValue(URLFileProtection.none, forKey: .fileProtectionKey)
            
            completion(destinationURL)
        } catch {
            print("文件处理失败: \(error)")
            completion(nil)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion(nil)
    }
}

// 导出数据结构
struct CatExportData: Codable {
    let cat: Cat
    let feedingRecords: [FeedingRecord]
    let weightRecords: [WeightRecord]
    let medicines: [Medicine]
    let medicineLogs: [MedicineLog]
    let exportDate: Date = Date()
} 