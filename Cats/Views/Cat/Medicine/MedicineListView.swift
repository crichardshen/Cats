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
                    Text(selectedDate.formattedYYYYMMDD())
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
    let logs: [MedicineLog]
    
    var body: some View {
        NavigationLink {
            MedicineStatsView(
                medicine: medicine,
                logs: logs.filter { $0.medicineId == medicine.id }
            )
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                // 第一行：名称和类型
                HStack(alignment: .center) {
                    Text(medicine.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(medicine.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
                
                // 第二行：使用频率
                Text(medicine.frequency.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // 第三行：起始日期
                HStack {
                    Text("从 \(medicine.startDate.formattedYYYYMMDD()) 开始")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let endDate = medicine.endDate {
                        Text("至 \(endDate.formattedYYYYMMDD())")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // 第四行：备注（如果有）
                if let note = medicine.note {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 6)
        }
    }
}

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
                // 未来日期显示禁用状态的圆圈
                Image(systemName: "circle")
                    .foregroundColor(.gray.opacity(0.5))
                    .imageScale(.large)
            } else {
                // 当前或过去日期显示可点击的按钮
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