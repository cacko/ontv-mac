//
//  Base.swift
//  Base
//
//  Created by Alex on 03/10/2021.
//

import AppKit
import Combine
import Foundation
import SwiftUI

protocol Streamable {
    var stream_id: Int64 { get set }
}

protocol Collection {
    var corelazy: LazyStreams { get set }

    init(action: Selector?, corelazy: LazyStreams)
}

class BaseItem: NSMenuItem, NSUserInterfaceValidations {
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        return true
    }

    override init(title: String, action: Selector?, keyEquivalent: String) {
        super.init(title: title, action: action, keyEquivalent: keyEquivalent)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ShiftModifierItem: BaseItem {
  override init(title: String, action: Selector?, keyEquivalent: String) {
    super.init(title: title, action: action, keyEquivalent: keyEquivalent)
    self.keyEquivalentModifierMask.insert(.shift)
  }
  
  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class NoModifierItem: BaseItem {
    override init(title: String, action: Selector?, keyEquivalent: String) {
        super.init(title: title, action: action, keyEquivalent: keyEquivalent)
        self.keyEquivalentModifierMask.remove(.command)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ToggleItem: NoModifierItem {
    var notification: ContentToggle

    init(title: String, action: Selector?, keyEquivalent: String, notification: ContentToggle) {
        self.notification = notification
        super.init(title: title, action: action, keyEquivalent: keyEquivalent)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ToggleInverseItem: ToggleItem {

    override init(
        title: String, action: Selector?, keyEquivalent: String, notification: ContentToggle
    ) {
        super.init(
            title: title, action: action, keyEquivalent: keyEquivalent, notification: notification)
        self.keyEquivalentModifierMask.insert(.command)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FetchItem: NoModifierItem {
    var notification: API.FetchType

    init(title: String, action: Selector?, keyEquivalent: String, notification: API.FetchType) {
        self.notification = notification
        super.init(title: title, action: action, keyEquivalent: keyEquivalent)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NavigationItem: BaseItem {
    var notification: AppNavigation

    init(title: String, action: Selector?, keyEquivalent: String, notification: AppNavigation) {
        self.notification = notification
        super.init(title: title, action: action, keyEquivalent: keyEquivalent)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ListNavigationItem: NoModifierItem {
  var notification: ListNavigation
  
  init(title: String, action: Selector?, keyEquivalent: String, notification: ListNavigation) {
    self.notification = notification
    super.init(title: title, action: action, keyEquivalent: keyEquivalent)
  }
}
