import SwiftUI

struct MedicineListView: View {
    @StateObject private var viewModel: MedicineViewModel
    @ObservedObject var listViewModel: CatListViewModel
    @State private var showingAddSheet = false
    @State private var showingDatePicker = false
    @State private var editingMedicine: Medicine? = nil
    @State private var medicineToDelete: Medicine? = nil
    
    init(catId: UUID, listViewModel: CatListViewModel) {
        _viewModel = StateObject(wrappedValue: MedicineViewModel(catId: catId))
        self.listViewModel = listViewModel
    }
    
    var body: some View {
        List {
            // 日期选择部分
            Section {
                Button {
                    showingDatePicker = true
                } label: {
                    HStack {
                        Text("查看指定日期")
                        Spacer()
                        Text(viewModel.selectedDate.formattedYYYYMMDD())
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // 今日待执行项目
            Section {
                let medicineInstances = viewModel.medicinesForDate(viewModel.selectedDate)
                if medicineInstances.isEmpty {
                    Text("今日没有需要执行的项目")
                        .foregroundColor(.gray)
                } else {
                    ForEach(Dictionary(grouping: medicineInstances) { $0.medicine.id }
                        .sorted(by: { $0.value[0].medicine.name < $1.value[0].medicine.name }), id: \.key) { _, instances in
                        if instances.count > 1 {
                            // 多次用药的折叠视图
                            DisclosureGroup {
                                ForEach(instances) { instance in
                                    MedicineInstanceRow(
                                        instance: instance,
                                        onToggle: {
                                            withAnimation {
                                                viewModel.toggleInstanceLog(
                                                    for: instance.medicine,
                                                    instanceId: instance.id,
                                                    on: viewModel.selectedDate
                                                )
                                            }
                                        }
                                    )
                                }
                            } label: {
                                Text("\(instances[0].medicine.name) (今日\(instances.count)次)")
                                    .font(.headline)
                            }
                        } else {
                            // 单次用药直接显示
                            MedicineInstanceRow(
                                instance: instances[0],
                                onToggle: {
                                    withAnimation {
                                        viewModel.toggleInstanceLog(
                                            for: instances[0].medicine,
                                            instanceId: 1,
                                            on: viewModel.selectedDate
                                        )
                                    }
                                }
                            )
                        }
                    }
                }
            } header: {
                HStack {
                    Text("待执行项目")
                    Spacer()
                    Text(viewModel.selectedDate.formattedYYYYMMDD())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // 所有药物/疫苗列表
            Section {
                ForEach(viewModel.medicines) { medicine in
                    MedicineItemRow(
                        medicine: medicine,
                        logs: viewModel.logs
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            medicineToDelete = medicine
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                        
                        Button {
                            editingMedicine = medicine
                        } label: {
                            Label("编辑", systemImage: "pencil")
                        }
                        .tint(ThemeColors.forestGreen)
                    }
                }
            } header: {
                HStack {
                    Text("使用中的药物")
                    Spacer()
                    Text("← 左滑指定药物可编辑 / 删除")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("医药管理")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Text("添加药物")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.forestGreen)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddMedicineView(catId: viewModel.catId) { medicine in
                viewModel.addMedicine(medicine)
            }
        }
        .sheet(item: $editingMedicine) { medicine in
            AddMedicineView(
                catId: viewModel.catId,
                editingMedicine: medicine
            ) { updatedMedicine in
                viewModel.updateMedicine(updatedMedicine)
            }
        }
        .alert("确认删除", isPresented: Binding(
            get: { medicineToDelete != nil },
            set: { if !$0 { medicineToDelete = nil } }
        )) {
            Button("取消", role: .cancel) {
                medicineToDelete = nil
            }
            Button("删除", role: .destructive) {
                if let medicine = medicineToDelete {
                    withAnimation {
                        viewModel.removeMedicine(medicine)
                    }
                }
                medicineToDelete = nil
            }
        } message: {
            Text("该药物将从待执行项目中删除，是否仍要删除该药物")
        }
        .onAppear {
            viewModel.onStatusChanged = { [weak listViewModel] in
                listViewModel?.refreshMedicineStatus()
            }
        }
        .localizedDatePickerSheet(
            isPresented: $showingDatePicker,
            date: $viewModel.selectedDate,
            title: Locale.isChineseEnvironment ? "选择日期" : "Select Date"
        )
    }
}

// MARK: - 子视图
private struct MedicineInstanceRow: View {
    let instance: DailyMedicineInstance
    let onToggle: () -> Void
    
    private var isFutureDate: Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: instance.date) > calendar.startOfDay(for: Date())
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if instance.id > 1 {
                    Text("\(instance.medicine.name) - 第\(instance.id)次")
                        .font(.headline)
                } else {
                    Text(instance.medicine.name)
                        .font(.headline)
                }
                HStack {
                    Text(instance.medicine.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if let time = instance.completedTime {
                        Text("✓ \(time.formatted(date: .omitted, time: .shortened))")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.forestGreen)
                    }
                }
            }
            
            Spacer()
            
            if isFutureDate {
                Image(systemName: "circle")
                    .foregroundColor(.gray.opacity(0.5))
                    .imageScale(.large)
            } else {
                Button(action: onToggle) {
                    Image(systemName: instance.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(instance.isCompleted ? ThemeColors.forestGreen : .gray)
                        .imageScale(.large)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

private struct MedicineItemRow: View {
    let medicine: Medicine
    let logs: [MedicineLog]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(medicine.name)
                .font(.headline)
            
            HStack {
                Text(medicine.type.rawValue)
                Text("•")
                Text(medicine.frequency.description)
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            HStack {
                Text("开始：\(medicine.startDate.formattedYYYYMMDD())")
                if let endDate = medicine.endDate {
                    Text("结束：\(endDate.formattedYYYYMMDD())")
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            if let note = medicine.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
} 