import SwiftUI

struct FeedingRecordListView: View {
    @StateObject private var viewModel: FeedingRecordViewModel
    @State private var showingAddRecord = false
    @State private var showingEditRecord: FeedingRecord?
    @State private var showingFilter = false
    
    init(catId: UUID) {
        _viewModel = StateObject(wrappedValue: FeedingRecordViewModel(catId: catId))
    }
    
    var body: some View {
        Group {
            if viewModel.filteredRecords.isEmpty {
                EmptyRecordView {
                    showingAddRecord = true
                }
            } else {
                recordsList
            }
        }
        .navigationTitle("饮食记录")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        showingFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(ThemeColors.forestGreen)
                    }
                    
                    Button {
                        showingAddRecord = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(ThemeColors.forestGreen)
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "搜索品牌或备注")
        .sheet(isPresented: $showingAddRecord) {
            AddFeedingRecordView(catId: viewModel.catId) { record in
                viewModel.addRecord(record)
            }
        }
        .sheet(item: $showingEditRecord) { record in
            AddFeedingRecordView(catId: viewModel.catId, editingRecord: record) { updatedRecord in
                viewModel.updateRecord(updatedRecord)
            }
        }
        .sheet(isPresented: $showingFilter) {
            NavigationView {
                FeedingRecordFilterView(
                    selectedFoodType: $viewModel.selectedFoodType,
                    selectedDateRange: $viewModel.selectedDateRange
                )
                .navigationTitle("筛选")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            showingFilter = false
                        }
                    }
                }
            }
        }
    }
    
    private var recordsList: some View {
        List {
            // 统计信息部分
            Section {
                NavigationLink(destination: FeedingRecordStatsView(statistics: viewModel.statistics)) {
                    HStack {
                        Text("数据统计")
                        Spacer()
                        Text("\(String(format: "%.0f", viewModel.statistics.totalAmount))g")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // 按日期分组的记录列表
            ForEach(viewModel.groupedRecords, id: \.0) { date, records in
                Section(header: Text(date)) {
                    ForEach(records) { record in
                        FeedingRecordRow(record: record)
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
}

// MARK: - 子视图
private struct EmptyRecordView: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bowl.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(ThemeColors.forestGreen)
            
            Text("还没有饮食记录")
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