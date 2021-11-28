//
//  Menu.swift
//  Menu
//
//  Created by Alex on 01/09/2021.
//

import AppKit
import Defaults
import Foundation
import Preferences
import SwiftUI

extension NSMenuItem {
    func attach(_ menu: NSMenu) {
        target = menu
        menu.addItem(self)
    }
}

class Menu: NSMenu, NSMenuDelegate, NSMenuItemValidation, NSUserInterfaceValidations {
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        return true
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
    
    var mainMenu: NSMenu
    var player = Player.instance
    
    init() {
        mainMenu = NSApplication.shared.mainMenu ?? NSMenu()
        super.init(title: "")
        _init()
        update()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addItem(_ newItem: NSMenuItem) {
        mainMenu.addItem(newItem)
    }
    
    override func addItem(withTitle string: String, action selector: Selector?, keyEquivalent charCode: String) -> NSMenuItem {
        return mainMenu.addItem(withTitle: string, action: selector, keyEquivalent: charCode)
    }
    
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        guard item == nil else {
            if let submenu = item!.submenu as? StreamsSubmenu {
                Task.init {
                    await submenu.load()
                }
            }
            return
        }
    }
    
    func _init() {
        _ = mainMenu.items.dropFirst().dropLast().filter { $0.title != "Edit" }.map { $0.menu?.removeItem($0) }
                
        if let helpMenu = mainMenu.items.last {
            mainMenu.removeItem(helpMenu)
            mainMenu.delegate = self
            addMenu(StreamMenu(title: "Stream", parent: self))
            addMenu(VideoMenu(title: "Video", parent: self))
            addMenu(AudioMenu(title: "Audio", parent: self))
            addMenu(CategoryMenu(title: "Category", parent: self))
            addMenu(ScheduleMenu(title: "Schedule", parent: self))
            addMenu(EPGMenu(title: "EPG", parent: self))
            addItem(helpMenu)
        }
    }
    
    func addMenu(_ menu: BaseMenu) {
        let menuItem = addItem(withTitle: menu.title, action: nil, keyEquivalent: "")
        menuItem.target = self
        menu.delegate = self
        menuItem.submenu = menu
    }
}
