//
//  VideoView.swift
//  VideoView
//
//  Created by Alex on 21/09/2021.
//

import AVFoundation
import Defaults
import Metal
import MetalKit
import SwiftUI

enum Video {
  enum Zoom {
    case expand, shrink
  }
}

extension NSNotification.Name {
  static let reaspect = NSNotification.Name("re_aspect")
  static let zoomchange = NSNotification.Name("zppm_change")
}

class VideoView: MTKView {
  var player = Player.instance

  func postInit() {
    player.initView(self)

    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main

    center.addObserver(forName: .fit, object: nil, queue: mainQueue) { note in
      guard !self.player.isFullscreen else {
        return
      }
      guard let frameSize = self.frame.size as NSSize? else {
        return
      }
      let newSize = NSSize(
        width: frameSize.width,
        height: frameSize.width * (1 / self.player.size.aspectRatio)
      )
      self.player.size = newSize
      NotificationCenter.default.post(
        name: .reaspect,
        object: nil
      )
    }

    center.addObserver(forName: .zoomchange, object: nil, queue: mainQueue) { note in
      guard let zoom = note.object as? Video.Zoom else {
        return
      }

      guard let wsize = self.window?.frame.size else {
        return
      }

      guard let screenSize = self.window?.screen?.frame.size else {
        return
      }

      let newSize = wsize.zoom(zoom)

      guard newSize.width > 150 && newSize.width < screenSize.width else {
        return
      }

      self.player.size = wsize.zoom(zoom)
      NotificationCenter.default.post(name: .reaspect, object: nil)
    }

    center.addObserver(forName: .vendorChange, object: nil, queue: mainQueue) { note in
      guard let renderer = note.object as? PlayVendor else {
        return
      }
      self.vendorChange(renderer)
    }

    center.addObserver(forName: .vendorToggle, object: nil, queue: mainQueue) {
      _ in self.vendorToggle()
    }
  }

  func vendorChange(_ vendor: PlayVendor) {
    Defaults[.vendor] = vendor
    self.player.switchVendor(vendor)
    self.player.initView(self)
    if let stream = self.player.stream {
      self.player.play(stream)
    }
  }

  func vendorToggle() {
    let vendors = self.player.availableVendors + self.player.availableVendors
    let newIdx = vendors.index(
      after: vendors.firstIndex(where: { $0.id == self.player.vendor.id })!
    )
    guard let nextRenderer = vendors[newIdx] as VendorInfo? else {
      fatalError()
    }
    NotificationCenter.default.post(name: .vendorChange, object: nextRenderer.id)
  }

  func initPlayer() {
    player.initView(self)
  }

  override func mouseDown(with event: NSEvent) {
    //    guard event.clickCount < 2 else {
    //      NotificationCenter.default.post(name: .toggleFullscreen, object: nil)
    //      return
    //    }
  }

  override func mouseDragged(with event: NSEvent) {
    window?.performDrag(with: event)
  }

}

struct VideoViewRep: NSViewRepresentable {

  typealias NSViewType = VideoView

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeNSView(context: Context) -> VideoView {

    let mtkView = VideoView()
    mtkView.delegate = context.coordinator
    mtkView.preferredFramesPerSecond = 60
    mtkView.enableSetNeedsDisplay = true
    if let metalDevice = MTLCreateSystemDefaultDevice() {
      mtkView.device = metalDevice
    }
    mtkView.framebufferOnly = false
    mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
    mtkView.drawableSize = mtkView.frame.size
    mtkView.enableSetNeedsDisplay = true
    mtkView.postInit()
    return mtkView

  }

  func updateNSView(_ nsView: VideoView, context: Context) {}

  class Coordinator: NSObject, MTKViewDelegate {
    var parent: VideoViewRep
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!

    init(
      _ parent: VideoViewRep
    ) {
      self.parent = parent
      if let metalDevice = MTLCreateSystemDefaultDevice() {
        self.metalDevice = metalDevice
      }
      self.metalCommandQueue = metalDevice.makeCommandQueue()!
      super.init()
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    func draw(in view: MTKView) {
      guard let drawable = view.currentDrawable else {
        return
      }
      let commandBuffer = metalCommandQueue.makeCommandBuffer()
      let rpd = view.currentRenderPassDescriptor
      rpd?.colorAttachments[0].clearColor = MTLClearColorMake(0, 1, 0, 1)
      rpd?.colorAttachments[0].loadAction = .clear
      rpd?.colorAttachments[0].storeAction = .store
      let re = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd!)
      re?.endEncoding()
      commandBuffer?.present(drawable)
      commandBuffer?.commit()
    }
  }

}
