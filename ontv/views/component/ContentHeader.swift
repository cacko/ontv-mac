//
//  ContentHeader.swift
//  craptv
//
//  Created by Alex on 05/11/2021.
//

import Foundation
import SwiftUI

struct ContentHeaderView: View {
  struct HeaderView: View {
    var text: String
    var body: some View {
      HStack(alignment: .center, spacing: 0) {
        Spacer()
        Text(text)
          .font(Theme.Font.title)
          .lineLimit(1)
          .textCase(.uppercase)
          .opacity(1)
          .padding()
      }.background(Theme.Color.Background.header)
    }
  }

  class HeaderHostingController: NSHostingController<HeaderView> {

    private var wasDragged = false

    override func mouseDragged(with event: NSEvent) {
      view.window?.performDrag(with: event)
    }
    override func mouseDown(with event: NSEvent) {
      view.window?.performDrag(with: event)
    }
  }

  struct HeaderRepresentable: NSViewControllerRepresentable {
    var text: String
    typealias NSViewControllerType = NSViewController
    func makeNSViewController(context: Context) -> NSViewController {
      let hosting = HeaderHostingController(rootView: HeaderView(text: text))
      hosting.view.translatesAutoresizingMaskIntoConstraints = false
      return hosting
    }
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
  }

  var title: String

  var body: some View {
    HeaderRepresentable(text: title)
  }
}
