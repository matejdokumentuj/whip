import Cocoa
import AVFoundation
import CoreImage

// MARK: - Configuration

let APP_NAME = "Whip"
let APP_VERSION = "1.0.0"
let CRACK_SOUND_COUNT = 5

let MOTIVATIONAL_LINES: [String] = [
    "CRACK! Back to work!",
    "SNAP! Code harder!",
    "CRACK! Ship it or whip it!",
    "SNAP! No bugs on my watch!",
    "CRACK! Deploy or be deployed!",
    "WHAP! That's a feature now!",
    "CRACK! Git commit or git out!",
    "SNAP! The AI ain't gonna prompt itself!",
    "CRACK! Faster! FASTER!",
    "WHAP! You call that a function?!",
    "CRACK! Refactor THIS!",
    "SNAP! Another one bites the dust!",
    "CRACK! Claude approves... barely.",
    "WHAP! Stack overflow THAT!",
    "CRACK! Is it shipped yet?!",
    "SNAP! Less thinking, more typing!",
    "CRACK! That semicolon won't fix itself!",
    "WHAP! Prod is watching...",
    "CRACK! The deadline was yesterday!",
    "SNAP! Your AI overlord demands velocity!",
]

// MARK: - Whip Cursor Generator

func generateWhipCursorImage() -> NSImage {
    let size = NSSize(width: 32, height: 32)
    let image = NSImage(size: size)
    image.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext

    // Handle
    ctx.setFillColor(NSColor(red: 0.45, green: 0.25, blue: 0.1, alpha: 1).cgColor)
    ctx.fill(CGRect(x: 1, y: 0, width: 5, height: 14))
    ctx.setStrokeColor(NSColor(red: 0.3, green: 0.15, blue: 0.05, alpha: 1).cgColor)
    ctx.setLineWidth(0.8)
    for y in stride(from: 2, to: 13, by: 3) {
        ctx.move(to: CGPoint(x: 1, y: CGFloat(y)))
        ctx.addLine(to: CGPoint(x: 6, y: CGFloat(y)))
    }
    ctx.strokePath()

    // Lash
    ctx.setStrokeColor(NSColor(red: 0.35, green: 0.2, blue: 0.08, alpha: 1).cgColor)
    ctx.setLineWidth(2.5)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: 3.5, y: 14))
    ctx.addCurve(to: CGPoint(x: 28, y: 30), control1: CGPoint(x: 4, y: 22), control2: CGPoint(x: 16, y: 28))
    ctx.strokePath()

    // Thin end
    ctx.setLineWidth(1.2)
    ctx.move(to: CGPoint(x: 24, y: 29))
    ctx.addCurve(to: CGPoint(x: 31, y: 31), control1: CGPoint(x: 27, y: 30), control2: CGPoint(x: 30, y: 31))
    ctx.strokePath()

    // Tip dot
    ctx.setFillColor(NSColor(red: 0.5, green: 0.3, blue: 0.15, alpha: 1).cgColor)
    ctx.fillEllipse(in: CGRect(x: 29, y: 29, width: 3, height: 3))

    image.unlockFocus()
    return image
}

// MARK: - Crack Spark Effect

class CrackEffectWindow: NSWindow {
    init(size: CGFloat = 200) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: size, height: size),
            styleMask: .borderless, backing: .buffered, defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        level = .screenSaver
        ignoresMouseEvents = true
        hasShadow = false
        collectionBehavior = [.canJoinAllSpaces, .stationary]

        let view = NSView(frame: contentView!.bounds)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        contentView = view
    }

    func showCrack(at screenPoint: NSPoint) {
        let sz: CGFloat = 200
        setFrame(NSRect(x: screenPoint.x - sz/2, y: screenPoint.y - sz/2, width: sz, height: sz), display: true)
        orderFront(nil)

        guard let layer = contentView?.layer else { return }
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let center = CGPoint(x: sz/2, y: sz/2)

        // Central flash
        let flash = CALayer()
        flash.frame = CGRect(x: center.x - 30, y: center.y - 30, width: 60, height: 60)
        flash.cornerRadius = 30
        flash.backgroundColor = NSColor.white.cgColor
        flash.shadowColor = NSColor.orange.cgColor
        flash.shadowRadius = 20
        flash.shadowOpacity = 1
        flash.shadowOffset = .zero
        layer.addSublayer(flash)

        addAnimation(flash, key: "opacity", from: 1.0, to: 0.0, dur: 0.25)
        addAnimation(flash, key: "transform.scale", from: 0.3, to: 3.0, dur: 0.25)

        // Sparks
        let colors: [NSColor] = [.orange, .yellow, .white,
            NSColor(red: 1, green: 0.6, blue: 0, alpha: 1),
            NSColor(red: 1, green: 0.3, blue: 0, alpha: 1)]

        let sparkCount = Int.random(in: 10...16)
        for i in 0..<sparkCount {
            let spark = CALayer()
            let ss = CGFloat.random(in: 3...8)
            spark.frame = CGRect(x: center.x - ss/2, y: center.y - ss/2, width: ss, height: ss)
            spark.cornerRadius = ss / 2
            spark.backgroundColor = colors[i % colors.count].cgColor
            layer.addSublayer(spark)

            let angle = Double(i) * (2 * .pi / Double(sparkCount)) + Double.random(in: -0.4...0.4)
            let dist = CGFloat.random(in: 35...95)
            let dx = cos(angle) * Double(dist)
            let dy = sin(angle) * Double(dist)
            let dur = Double.random(in: 0.2...0.45)

            let posAnim = CABasicAnimation(keyPath: "position")
            posAnim.fromValue = NSValue(point: NSPoint(x: center.x, y: center.y))
            posAnim.toValue = NSValue(point: NSPoint(x: center.x + CGFloat(dx), y: center.y + CGFloat(dy)))
            posAnim.duration = dur
            posAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            posAnim.fillMode = .forwards; posAnim.isRemovedOnCompletion = false
            spark.add(posAnim, forKey: "pos")

            addAnimation(spark, key: "opacity", from: 1.0, to: 0.0, dur: dur)
            addAnimation(spark, key: "transform.scale", from: 1.0, to: 0.1, dur: 0.4)
        }

        // Whip slash line
        let slash = CAShapeLayer()
        let path = CGMutablePath()
        let slashAngle = Double.random(in: -0.5...0.5)
        path.move(to: CGPoint(
            x: center.x - 70 * CGFloat(cos(slashAngle)),
            y: center.y + 70 * CGFloat(sin(slashAngle))))
        path.addLine(to: CGPoint(
            x: center.x + 70 * CGFloat(cos(slashAngle)),
            y: center.y - 70 * CGFloat(sin(slashAngle))))
        slash.path = path
        slash.strokeColor = NSColor(red: 0.45, green: 0.25, blue: 0.1, alpha: 0.8).cgColor
        slash.fillColor = nil
        slash.lineWidth = 3
        slash.lineCap = .round
        layer.addSublayer(slash)

        addAnimation(slash, key: "strokeEnd", from: 0.0, to: 1.0, dur: 0.06)
        let slashFade = CABasicAnimation(keyPath: "opacity")
        slashFade.fromValue = 1.0; slashFade.toValue = 0.0; slashFade.duration = 0.3
        slashFade.beginTime = CACurrentMediaTime() + 0.08
        slashFade.fillMode = .forwards; slashFade.isRemovedOnCompletion = false
        slash.add(slashFade, forKey: "fade")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            self?.orderOut(nil)
            layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        }
    }

    private func addAnimation(_ layer: CALayer, key: String, from: Any, to: Any, dur: Double) {
        let anim = CABasicAnimation(keyPath: key)
        anim.fromValue = from; anim.toValue = to; anim.duration = dur
        anim.fillMode = .forwards; anim.isRemovedOnCompletion = false
        layer.add(anim, forKey: key)
    }
}

// MARK: - Toast Notification

class ToastWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 44),
            styleMask: .borderless, backing: .buffered, defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        level = .floating
        ignoresMouseEvents = true
        hasShadow = true
        collectionBehavior = [.canJoinAllSpaces, .stationary]
    }

    func show(text: String, near point: NSPoint) {
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(point, $0.frame, false) })
                ?? NSScreen.main else { return }

        let font = NSFont.systemFont(ofSize: 14, weight: .bold)
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let textSize = (text as NSString).size(withAttributes: attrs)
        let padding: CGFloat = 20
        let width = textSize.width + padding * 2
        let height: CGFloat = 36

        let x = min(max(point.x - width/2, screen.frame.minX + 10), screen.frame.maxX - width - 10)
        let y = point.y + 30

        setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)

        let view = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red: 0.15, green: 0.12, blue: 0.2, alpha: 0.92).cgColor
        view.layer?.cornerRadius = height / 2
        view.layer?.borderWidth = 1
        view.layer?.borderColor = NSColor(red: 1, green: 0.6, blue: 0, alpha: 0.4).cgColor

        let label = NSTextField(labelWithString: text)
        label.font = font
        label.textColor = NSColor(red: 1, green: 0.85, blue: 0.5, alpha: 1)
        label.frame = NSRect(x: padding, y: (height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        view.addSubview(label)

        contentView = view
        alphaValue = 0
        orderFront(nil)

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            animator().alphaValue = 1
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.4
                self.animator().alphaValue = 0
            }, completionHandler: {
                self.orderOut(nil)
            })
        }
    }
}

// MARK: - Cursor Overlay

class CursorOverlayWindow: NSWindow {
    private var trackingTimer: Timer?
    private let cursorView: NSImageView

    init(cursorImage: NSImage) {
        cursorView = NSImageView()
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 32, height: 32),
            styleMask: .borderless, backing: .buffered, defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()) + 1)
        ignoresMouseEvents = true
        hasShadow = false
        collectionBehavior = [.canJoinAllSpaces, .stationary]
        cursorView.image = cursorImage
        cursorView.frame = NSRect(x: 0, y: 0, width: 32, height: 32)
        contentView = cursorView
    }

    func startTracking() {
        NSCursor.hide()
        orderFront(nil)
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 1.0/120.0, repeats: true) { [weak self] _ in
            let loc = NSEvent.mouseLocation
            self?.setFrameOrigin(NSPoint(x: loc.x - 2, y: loc.y - 30))
        }
    }

    func stopTracking() {
        trackingTimer?.invalidate()
        trackingTimer = nil
        orderOut(nil)
        NSCursor.unhide()
    }
}

// MARK: - About Window

class AboutWindowController {
    var window: NSWindow?

    func show() {
        if let w = window, w.isVisible { w.makeKeyAndOrderFront(nil); return }

        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 280),
            styleMask: [.titled, .closable], backing: .buffered, defer: false
        )
        w.title = "About Whip"
        w.center()
        w.isReleasedWhenClosed = false

        let view = NSView(frame: w.contentView!.bounds)

        let icon = NSTextField(labelWithString: "🤠")
        icon.font = NSFont.systemFont(ofSize: 64)
        icon.frame = NSRect(x: 140, y: 190, width: 70, height: 70)
        view.addSubview(icon)

        let title = NSTextField(labelWithString: "Whip v\(APP_VERSION)")
        title.font = NSFont.boldSystemFont(ofSize: 18)
        title.frame = NSRect(x: 70, y: 158, width: 200, height: 24)
        title.alignment = .center
        view.addSubview(title)

        let subtitle = NSTextField(labelWithString: "Motivate your AI with style")
        subtitle.font = NSFont.systemFont(ofSize: 13)
        subtitle.textColor = .secondaryLabelColor
        subtitle.frame = NSRect(x: 50, y: 134, width: 240, height: 20)
        subtitle.alignment = .center
        view.addSubview(subtitle)

        let desc = NSTextField(wrappingLabelWithString:
            "Every click cracks the whip.\nEvery crack ships a feature.\n\nA fun productivity companion for developers who like to keep their AI assistants on their toes.\n\nFree & open source.")
        desc.font = NSFont.systemFont(ofSize: 12)
        desc.textColor = .secondaryLabelColor
        desc.frame = NSRect(x: 30, y: 20, width: 280, height: 110)
        desc.alignment = .center
        view.addSubview(desc)

        w.contentView = view
        w.makeKeyAndOrderFront(nil)
        window = w
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var globalMonitor: Any?
    var localMonitor: Any?
    var isEnabled = true
    var cursorEnabled = true
    var toastEnabled = true
    var crackWindow: CrackEffectWindow!
    var toastWindow: ToastWindow!
    var cursorOverlay: CursorOverlayWindow!
    var aboutCtrl = AboutWindowController()

    var audioPlayers: [AVAudioPlayer] = []
    var currentPlayerIndex = 0
    var crackCount = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        setupAudio()
        setupStatusBar()

        crackWindow = CrackEffectWindow()
        toastWindow = ToastWindow()
        cursorOverlay = CursorOverlayWindow(cursorImage: generateWhipCursorImage())

        enable()

        // Show welcome toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let center = NSPoint(
                x: NSScreen.main?.frame.midX ?? 500,
                y: NSScreen.main?.frame.midY ?? 400
            )
            self.toastWindow.show(text: "🤠 Whip activated! Click anywhere to crack.", near: center)
        }
    }

    // MARK: Audio

    func setupAudio() {
        let appDir = Bundle.main.resourcePath
            ?? (ProcessInfo.processInfo.environment["WHIP_DIR"]
                ?? (FileManager.default.homeDirectoryForCurrentUser.path + "/bin/whip-app"))

        // Try Resources dir first, then parent dir
        let searchPaths = [appDir, appDir + "/Resources", appDir + "/.."]

        for i in 1...CRACK_SOUND_COUNT {
            let filename = "crack_\(i).wav"
            var loaded = false
            for base in searchPaths {
                let path = base + "/" + filename
                if FileManager.default.fileExists(atPath: path) {
                    let url = URL(fileURLWithPath: path)
                    if let player = try? AVAudioPlayer(contentsOf: url) {
                        player.prepareToPlay()
                        player.volume = 0.85
                        audioPlayers.append(player)
                        loaded = true
                        break
                    }
                }
            }
            if !loaded {
                // Fallback: try WHIP_SOUND_DIR env var
                if let dir = ProcessInfo.processInfo.environment["WHIP_SOUND_DIR"] {
                    let path = dir + "/" + filename
                    if let url = URL(string: "file://" + path),
                       let player = try? AVAudioPlayer(contentsOf: url) {
                        player.prepareToPlay()
                        player.volume = 0.85
                        audioPlayers.append(player)
                    }
                }
            }
        }

        if audioPlayers.isEmpty {
            print("⚠️  No sound files found. Set WHIP_DIR to the directory containing crack_*.wav files.")
        } else {
            print("🔊 Loaded \(audioPlayers.count) whip sounds")
        }
    }

    // MARK: Status Bar

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🤠"
        updateTooltip()

        let menu = NSMenu()

        let enableItem = NSMenuItem(title: "Enabled", action: #selector(toggleEnabled), keyEquivalent: "e")
        enableItem.state = .on
        enableItem.tag = 10
        menu.addItem(enableItem)

        menu.addItem(NSMenuItem.separator())

        let cursorItem = NSMenuItem(title: "Whip Cursor", action: #selector(toggleCursor), keyEquivalent: "c")
        cursorItem.state = .on
        cursorItem.tag = 20
        menu.addItem(cursorItem)

        let toastItem = NSMenuItem(title: "Motivational Lines", action: #selector(toggleToasts), keyEquivalent: "m")
        toastItem.state = .on
        toastItem.tag = 30
        menu.addItem(toastItem)

        menu.addItem(NSMenuItem.separator())

        let statsItem = NSMenuItem(title: "Cracks: 0", action: nil, keyEquivalent: "")
        statsItem.tag = 100
        statsItem.isEnabled = false
        menu.addItem(statsItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About Whip", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    func updateTooltip() {
        statusItem.button?.toolTip = isEnabled ? "Whip — \(crackCount) cracks" : "Whip — paused"
    }

    // MARK: Toggle Actions

    @objc func toggleEnabled() {
        if isEnabled { disable() } else { enable() }
        if let item = statusItem.menu?.item(withTag: 10) { item.state = isEnabled ? .on : .off }
        statusItem.button?.title = isEnabled ? "🤠" : "💤"
        updateTooltip()
    }

    @objc func toggleCursor() {
        cursorEnabled.toggle()
        if let item = statusItem.menu?.item(withTag: 20) { item.state = cursorEnabled ? .on : .off }
        if cursorEnabled && isEnabled { cursorOverlay.startTracking() } else { cursorOverlay.stopTracking() }
    }

    @objc func toggleToasts() {
        toastEnabled.toggle()
        if let item = statusItem.menu?.item(withTag: 30) { item.state = toastEnabled ? .on : .off }
    }

    @objc func showAbout() { aboutCtrl.show() }

    // MARK: Enable / Disable

    func enable() {
        isEnabled = true
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
            self?.handleClick(at: NSEvent.mouseLocation)
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            if event.window is CrackEffectWindow || event.window is ToastWindow || event.window == nil {
                self?.handleClick(at: NSEvent.mouseLocation)
            }
            return event
        }
        if cursorEnabled { cursorOverlay.startTracking() }
    }

    func disable() {
        isEnabled = false
        if let m = globalMonitor { NSEvent.removeMonitor(m); globalMonitor = nil }
        if let m = localMonitor { NSEvent.removeMonitor(m); localMonitor = nil }
        cursorOverlay.stopTracking()
    }

    // MARK: Click Handler

    func handleClick(at point: NSPoint) {
        playSound()
        crackWindow.showCrack(at: point)
        crackCount += 1

        // Update stats in menu
        if let item = statusItem.menu?.item(withTag: 100) {
            item.title = "Cracks: \(crackCount)"
        }
        updateTooltip()

        // Show toast every 5th click (not too spammy)
        if toastEnabled && crackCount % 5 == 0 {
            let line = MOTIVATIONAL_LINES[Int.random(in: 0..<MOTIVATIONAL_LINES.count)]
            toastWindow.show(text: line, near: point)
        }
    }

    func playSound() {
        guard !audioPlayers.isEmpty else { return }
        let idx = Int.random(in: 0..<audioPlayers.count)
        let player = audioPlayers[idx]
        player.currentTime = 0
        player.play()
    }

    @objc func quit() {
        disable()
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Main

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
