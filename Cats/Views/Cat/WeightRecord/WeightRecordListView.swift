import SwiftUI

struct WeightRecordListView: View {
    @StateObject private var viewModel: WeightRecordViewModel
    @State private var showingAddRecord = false
    @State private var showingEditRecord: WeightRecord?
    
    init(catId: UUID) {
        _viewModel = StateObject(wrappedValue: WeightRecordViewModel(catId: catId))
    }
    
    var body: some View {
        Group {
            if viewModel.filteredAndSortedRecords.isEmpty {
                EmptyWeightRecordView {
                    showingAddRecord = true
                }
            } else {
                recordsList
            }
        }
        .navigationTitle("体重记录")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddRecord = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(ThemeColors.forestGreen)
                }
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            AddWeightRecordView(catId: viewModel.catId) { record in
                viewModel.addRecord(record)
            }
        }
        .sheet(item: $showingEditRecord) { record in
            AddWeightRecordView(catId: viewModel.catId, editingRecord: record) { updatedRecord in
                viewModel.updateRecord(updatedRecord)
            }
        }
    }
    
    private var recordsList: some View {
        List {
            // 统计信息部分
            Section {
                NavigationLink(destination: WeightRecordStatsView(statistics: viewModel.statistics)) {
                    HStack {
                        Text("数据统计")
                        Spacer()
                        if let currentWeight = viewModel.statistics.currentWeight {
                            Text(String(format: "%.2f kg", currentWeight))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            // 记录列表
            Section {
                ForEach(Array(zip(viewModel.filteredAndSortedRecords, viewModel.filteredAndSortedRecords.dropFirst().map { Optional($0) } + [nil])), id: \.0.id) { record, nextRecord in
                    WeightRecordRow(record: record, previousRecord: nextRecord)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingEditRecord = record
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.removeRecord(record)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

private struct EmptyWeightRecordView: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "scalemass.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(ThemeColors.forestGreen)
            
            Text("还没有体重记录")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button(action: onAdd) {
                Text("添加记录")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(ThemeColors.forestGreen)
                    .cornerRadius(25)
            }
        }
    }
} 