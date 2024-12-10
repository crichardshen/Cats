import Foundation
import UIKit
import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
class AddCatViewModel: ObservableObject {
    private let catId: UUID
    private let editingCat: Cat?
    private let onSave: (Cat) -> Void
    let onImportSuccess: (() -> Void)?
    
    @Published var name = ""
    @Published var gender: Cat.Gender?
    @Published var birthDate = Date()
    @Published var weight = ""
    @Published var avatarImage: UIImage?
    @Published var imageSelection: PhotosPickerItem? {
        didSet { handleImageSelection() }
    }
    
    let existingCats: [Cat]
    
    var isEditing: Bool { editingCat != nil }
    var canSave: Bool { !name.isEmpty }
    
    init(editingCat: Cat? = nil, existingCats: [Cat] = [], onSave: @escaping (Cat) -> Void, onImportSuccess: (() -> Void)? = nil) {
        self.editingCat = editingCat
        self.existingCats = existingCats
        self.onSave = onSave
        self.onImportSuccess = onImportSuccess
        self.catId = editingCat?.id ?? UUID()
        
        if let cat = editingCat {
            self.name = cat.name
            self.gender = cat.gender
            self.birthDate = cat.birthDate ?? Date()
            self.weight = cat.weight.map { String($0) } ?? ""
            if let avatarData = cat.avatar,
               let image = UIImage(data: avatarData) {
                self.avatarImage = image
            }
        }
    }
    
    func createCat() -> Cat {
        Cat(
            id: editingCat?.id ?? UUID(),
            name: name,
            gender: gender,
            birthDate: birthDate,
            weight: Double(weight),
            avatar: avatarImage?.jpegData(compressionQuality: Constants.ImageCompression.quality)
        )
    }
    
    private func handleImageSelection() {
        guard let item = imageSelection else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    self.avatarImage = image
                }
            }
        }
    }
} 