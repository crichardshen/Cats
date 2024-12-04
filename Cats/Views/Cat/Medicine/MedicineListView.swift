import SwiftUI

struct MedicineListView: View {
    @StateObject private var viewModel: MedicineViewModel
    @State private var showingAddMedicine = false
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var editingMedicine: Medicine? = nil
    @State private var medicineToDelete: Medicine? = nil
    
    init(catId: UUID) {
        _viewModel = StateObject(wrappedValue: MedicineViewModel(catId: catId))
    }
    
    var body: some View {
        List {
            // 日期选择器按钮和日历
            Section {
                Button(action: {
                    withAnimation {
                        showingDatePicker.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(ThemeColors.forestGreen)
                        Text("查看指定日期完成状况")
                        Spacer()
                        Image(systemName: showingDatePicker ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                }
                
                if showingDatePicker {
                    VStack {
                        // 添加"今天"按钮
                        HStack {
                            Spacer()
                            Button(action: {
                                selectedDate = Date()  // 先更新日期
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  // 延迟关闭日历
                                    withAnimation {
                                        showingDatePicker = false
                                    }
                                }
                            }) {
                                Label("今天", systemImage: "arrow.uturn.backward")
                                    .foregroundColor(ThemeColors.forestGreen)
                            }
                            .padding(.trailing)
                        }
                        
                        DatePicker(
                            "选择日期",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .onChange(of: selectedDate) { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  // 延迟关闭日历
                                withAnimation {
                                    showingDatePicker = false
                                }
                            }
                        }
                    }
                }
            }
            
            // 今日待执行项目
            Section {
                let medicineInstances = viewModel.medicinesForDate(selectedDate)
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
                                                    on: selectedDate
                                                )
                                            }
                                        }
                                    )
                                }
                            } label: {
                                Text("\(instances[0].medicine.name) (每日\(instances.count)次)")
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
                                            on: selectedDate
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
                    Text(selectedDate.formatted(date: .long, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // 所有药物/疫苗列表
            Section {
                ForEach(viewModel.medicines) { medicine in
                    MedicineItemRow(
                        medicine: medicine,
                        onEdit: {
                            editingMedicine = medicine
                        }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            medicineToDelete = medicine
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            } header: {
                HStack {
                    Text("正在使用的药物")
                    Spacer()
                    Text("← 左滑指定药物可删除")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("医药管理")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddMedicine = true
                } label: {
                    Text("配置药剂项目")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.forestGreen)
                }
            }
        }
        .sheet(isPresented: $showingAddMedicine) {
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
    }
}

// MARK: - 子视图
private struct MedicineRow: View {
    let medicine: Medicine
    let isCompleted: Bool
    let completedTime: Date?
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(medicine.name)
                    .font(.headline)
                HStack {
                    Text(medicine.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if let time = completedTime {
                        Text("✓ \(time.formatted(date: .omitted, time: .shortened))")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.forestGreen)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? ThemeColors.forestGreen : .gray)
                    .imageScale(.large)
            }
        }
        .contentShape(Rectangle())
    }
}

private struct MedicineItemRow: View {
    let medicine: Medicine
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(medicine.name)
                    .font(.headline)
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle")
                        .foregroundColor(ThemeColors.forestGreen)
                }
                Text(medicine.type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Text(medicine.frequency.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if let note = medicine.note {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct MedicineInstanceRow: View {
    let instance: DailyMedicineInstance
    let onToggle: () -> Void
    
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
            
            Button(action: onToggle) {
                Image(systemName: instance.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(instance.isCompleted ? ThemeColors.forestGreen : .gray)
                    .imageScale(.large)
            }
        }
        .contentShape(Rectangle())
    }
} 