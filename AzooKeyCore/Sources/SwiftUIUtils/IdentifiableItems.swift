//
//  IdentifiableItems.swift
//  azooKey
//
//  Created by ensan on 2021/04/30.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

public extension Binding where Value: RandomAccessCollection & MutableCollection & Sendable, Value.Element: Identifiable, Value.Index: Sendable {
    struct IdentifiableItem: Identifiable {
        @Binding<Value.Element> public private(set) var item: Value.Element
        public let index: Value.Index
        public let id: Value.Element.ID
    }

    var identifiableItems: [IdentifiableItem] {
        // Listが再描画の際に落ちる問題は、Bindingが悪さをしているせいだと考えられる。
        // そこでここでは`Binding`を生成し直すことで対処している。今のところうまく行っている。
        self.wrappedValue.indices.map { i in
            .init(
                item: .init(
                    get: {
                        self.wrappedValue[i]
                    },
                    set: {newValue in
                        self.wrappedValue[i] = newValue
                    }
                ),
                index: i,
                id: self.wrappedValue[i].id
            )
        }
    }
}
