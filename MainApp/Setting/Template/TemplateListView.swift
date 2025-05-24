//
//  TemplateListView.swift
//  MainApp
//
//  Created by ensan on 2020/12/19.
//  Copyright © 2020 ensan. All rights reserved.
//

import SwiftUI
import struct KanaKanjiConverterModule.TemplateData
import struct KanaKanjiConverterModule.DateTemplateLiteral

final class TemplateDataList: ObservableObject {
    @Published var templates: [TemplateData] = []
}

extension TemplateData: @retroactive Identifiable {
    public var id: String {
        self.name
    }
}

// このモデルがNavigation状態を管理し、プレビューが遷移後も更新し続けるのを防ぐ
private final class NavigationModel: ObservableObject {
    @Published var linkSelection: Int?
}

// Listが大元のtemplatesを持ち、各EditingViewにBindingで渡して編集させる。
@MainActor
struct TemplateListView: View {
    private static let dataFileName = "user_templates.json"
    @ObservedObject private var data = TemplateDataList()
    @ObservedObject private var navigationModel = NavigationModel()

    init() {
        self.data.templates = TemplateData.load()
    }

    var body: some View {
        Form {
            List {
                let validationInfo = data.templates.map {$0.name}
                ForEach($data.templates.identifiableItems) {value in
                    NavigationLink {
                        TemplateEditingView(value.$item, validationInfo: validationInfo)
                    } label: {
                        TimelineView(.periodic(from: Date(), by: 1.0)) { _ in
                            LabeledContent {
                                Text(value.item.previewString)
                                    .foregroundStyle(.gray)
                                    .monospacedDigit()
                            } label: {
                                Text(value.item.name)
                            }
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            data.templates.remove(at: value.index)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: {self.delete(at: $0)})
            }
            Section {
                NavigationLink("テンプレートの設定") {
                    TemplateSettingTipsView()
                }
            } header: {
                Text("設定方法")
            }
        }.navigationBarTitle(Text("テンプレートの管理"), displayMode: .inline)
        .navigationBarItems(trailing: addButton)
        .onEnterBackground {_ in
            self.save()
        }
        .onDisappear {
            // save処理
            self.save()
        }
    }

    private var addButton: some View {
        Button {
            let core = "new_template"
            var number = 0
            var name = core
            while !data.templates.allSatisfy({$0.name != name}) {
                number += 1
                name = "\(core)#\(number)"
            }
            let newData = TemplateData(template: DateTemplateLiteral.example.export(), name: name)
            data.templates.append(newData)
        }label: {
            Image(systemName: "plus")
        }
    }

    private func delete(at offsets: IndexSet) {
        data.templates.remove(atOffsets: offsets)
    }

    private func save() {
        TemplateData.save(self.data.templates)
    }
}
