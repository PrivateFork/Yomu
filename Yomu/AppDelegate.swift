//
//  AppDelegate.swift
//  Yomu
//
//  Created by Sendy Halim on 6/6/16.
//  Copyright © 2016 Sendy Halim. All rights reserved.
//

import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  var mainWindow: NSWindow!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    mainWindow = NSApplication.shared().windows.first!
    mainWindow.titleVisibility = NSWindowTitleVisibility.hidden
    mainWindow.titlebarAppearsTransparent = true
    mainWindow.styleMask = [NSFullSizeContentViewWindowMask, mainWindow.styleMask]
    mainWindow.setFrame(NSScreen.main()!.frame, display: true)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    mainWindow.makeKeyAndOrderFront(sender)

    return true
  }
}
