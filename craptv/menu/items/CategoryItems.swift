//
//  Category.swift
//  Category
//
//  Created by Alex on 03/10/2021.
//

import Foundation

class CategoryItem: BaseItem, Collection {
    var corelazy: LazyStreams

    required init(action: Selector?, corelazy: LazyStreams) {
        self.corelazy = corelazy
        super.init(title: self.corelazy.title, action: action, keyEquivalent: "")
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
