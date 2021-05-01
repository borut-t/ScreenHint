//
//  ScreenHintApp.swift
//  ScreenHint
//
//  Created by Salem on 5/1/21.
//

import SwiftUI
import AppKit

class RectController:  NSWindowController, NSWindowDelegate {
    var rect: NSRect
    
    init(_ rect: NSRect) {
        self.rect = rect
        let window = NSWindow(contentRect: rect, styleMask: .resizable, backing: .buffered, defer: false)
        window.isOpaque = false
        window.level = .screenSaver
        window.backgroundColor = NSColor.blue
        window.alphaValue = 0.2
        window.ignoresMouseEvents = false
        window.isMovableByWindowBackground = true
        window.isMovable = true
        super.init(window: window)
        window.delegate = self
    }
    
    func setRect(_ rect: NSRect) {
        self.window?.setFrame(rect, display: true)
    }
    
    func finishDragging() {
        self.window?.alphaValue = 1.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func getRectForPoints(_ first: NSPoint, _ second: NSPoint) -> NSRect {
    let x = min(first.x, second.x)
    let y = min(first.y, second.y)
    let width = abs(first.x - second.x)
    let height = abs(first.y - second.y)
    
    return NSRect.init(x:x, y:y, width:width, height:height)
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var mouseLocation: NSPoint = NSPoint.init(x: 0, y: 0)
    var isDragging = false
    var dragStart: NSPoint = NSPoint.init(x: 0, y: 0)
    var dragEnd: NSPoint = NSPoint.init(x: 0, y: 0)
    var activeRect: RectController?
    var rects: [RectController] = []
        
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { _ in
            self.mouseLocation = NSEvent.mouseLocation
            self.dragStart = NSEvent.mouseLocation
            print ("[DN  ] Global location is \(self.mouseLocation)")
            
        }
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { _ in
            self.mouseLocation = NSEvent.mouseLocation
            self.dragEnd = NSEvent.mouseLocation
            print ("[UP  ] Global location is \(self.mouseLocation)")
            
            let rect = getRectForPoints(self.dragStart, self.dragEnd);
            if (self.activeRect != nil) {
                self.activeRect!.setRect(rect)
                self.activeRect!.finishDragging()
                self.rects.append(self.activeRect!)

            }
            self.activeRect = nil
            print("  ==  Added rect: \(rect)")
        }
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged]) { _ in
            self.mouseLocation = NSEvent.mouseLocation
            let rect = getRectForPoints(self.dragStart, self.mouseLocation);
            if (self.activeRect == nil) {
                self.activeRect = RectController(rect);
                self.activeRect!.showWindow(nil)
            }
            self.activeRect!.setRect(rect)

            print ("[DRAG] Global location is \(self.mouseLocation)")
        }

//        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { _ in
//            self.isDragging = true
//            print ("Global location is \(self.mouseLocation)")
//        }
//        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { _ in
//            self.isDragging = false
//            print ("Global location is \(self.mouseLocation)")
//        }


        
        
        let contentView = ContentView()
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
//        popover.delegate = contentView
        self.popover = popover
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "Icon")
            button.action = #selector(togglePopover(_:))
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }
    
}

@main
struct ScreenHintApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
