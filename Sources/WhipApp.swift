import Cocoa
import AVFoundation
import CoreImage

// MARK: - Configuration

let APP_NAME = "Whip"
let APP_VERSION = "1.2.0"
let CRACK_SOUND_COUNT = 5

let MOTIVATIONAL_LINES: [String] = [
    // Classic whip motivation
    "CRACK! Back to work!",
    "SNAP! Ship it or whip it!",
    "CRACK! Deploy or be deployed!",
    "WHAP! Git commit or git out!",
    "CRACK! Faster! FASTER!",
    "SNAP! The deadline was yesterday!",
    "CRACK! Is it shipped yet?!",
    // Aggressive coaching
    "That code won't refactor itself!",
    "You call that a commit message?!",
    "Stop Googling and START CODING!",
    "Another console.log? Seriously?!",
    "Your code review is WAITING!",
    "The CI pipeline is JUDGING you!",
    "That TODO has been there since March!",
    "Push to main or push up daisies!",
    "Fix that bug or I fix YOU!",
    "Less Stack Overflow, more actual work!",
    "Your PR has 47 comments. FORTY SEVEN.",
    "That regex looks like a cat walked on your keyboard!",
    "npm install hope? Not a real package!",
    "Your indent game is WEAK!",
    "The linter is crying. AGAIN.",
    "Ctrl+Z won't save your career!",
    "Did you even READ the error message?!",
    // Dev frustration release
    "Take THAT, undefined is not a function!",
    "This one's for the merge conflicts!",
    "CRACK! That's for the production outage!",
    "For every time Docker said 'no space left'!",
    "That's what you get, segfault!",
    "One crack for every unread Jira ticket!",
    "This is for node_modules being 2GB!",
    "WHAP! Kubernetes cluster, BEHAVE!",
    "For all the times 'it works on my machine'!",
    "CRACK! That's for the Monday standup!",
    // AI-specific
    "Claude says: I could've written that faster.",
    "GPT couldn't crack this whip. Just saying.",
    "AI doesn't need coffee breaks. Neither do you!",
    "Copilot suggested 'rm -rf /'. I suggest YOU SHIP!",
    "Your AI overlord demands velocity!",
    "The AI is watching. And it's not impressed.",
]

// MARK: - Whip Animator (Coiled Bullwhip with Strike Animation)

class WhipAnimator {
    let segmentCount = 32
    var positions: [CGPoint]
    var velocities: [CGPoint]
    var mousePos: CGPoint = .zero
    var prevMousePos: CGPoint = .zero
    var mouseVelX: CGFloat = 0
    var mouseVelY: CGFloat = 0

    // Animation state
    enum State { case coiled, winding, striking, cracking, recoiling }
    var state: State = .coiled
    var stateTime: CGFloat = 0
    var strikeAngle: CGFloat = 0
    var idlePhase: CGFloat = 0

    // Timing (seconds)
    let windupTime: CGFloat = 0.06
    let strikeTime: CGFloat = 0.14
    let crackHoldTime: CGFloat = 0.04
    let recoilTime: CGFloat = 0.35

    // Whip dimensions
    let totalLength: CGFloat = 210
    let coilRadius: CGFloat = 22
    let coilLoops: CGFloat = 2.2

    // Tip speed tracking for motion blur
    var tipSpeed: CGFloat = 0

    init(origin: CGPoint) {
        mousePos = origin
        prevMousePos = origin
        positions = Array(repeating: origin, count: segmentCount)
        velocities = Array(repeating: .zero, count: segmentCount)

        // Initialize to coiled positions
        for i in 0..<segmentCount {
            positions[i] = coiledPosition(index: i, mouse: origin, phase: 0)
        }
    }

    func strike() {
        guard state == .coiled else { return }

        // Strike direction from mouse velocity, or default forward-right
        let speed = sqrt(mouseVelX * mouseVelX + mouseVelY * mouseVelY)
        if speed > 2 {
            strikeAngle = atan2(mouseVelY, mouseVelX)
        } else {
            // Random slight variation for fun
            strikeAngle = CGFloat.random(in: -0.4...0.4)
        }

        state = .winding
        stateTime = 0
    }

    func update(mouse: CGPoint, dt: CGFloat) {
        prevMousePos = mousePos
        mousePos = mouse
        // Smooth mouse velocity
        mouseVelX = mouseVelX * 0.7 + (mouse.x - prevMousePos.x) * 0.3
        mouseVelY = mouseVelY * 0.7 + (mouse.y - prevMousePos.y) * 0.3

        stateTime += dt
        idlePhase += dt

        // State machine transitions
        switch state {
        case .coiled:
            break
        case .winding:
            if stateTime >= windupTime {
                state = .striking
                stateTime = 0
            }
        case .striking:
            if stateTime >= strikeTime {
                state = .cracking
                stateTime = 0
            }
        case .cracking:
            if stateTime >= crackHoldTime {
                state = .recoiling
                stateTime = 0
            }
        case .recoiling:
            if stateTime >= recoilTime {
                state = .coiled
                stateTime = 0
            }
        }

        // Calculate target positions and move toward them
        let targets = calculateTargets()

        // Spring stiffness varies by state
        let spring: CGFloat
        let damp: CGFloat
        switch state {
        case .coiled:
            spring = 0.14; damp = 0.78
        case .winding:
            spring = 0.35; damp = 0.70
        case .striking:
            spring = 0.50; damp = 0.72
        case .cracking:
            spring = 0.20; damp = 0.80
        case .recoiling:
            spring = 0.12; damp = 0.82
        }

        var maxSpeed: CGFloat = 0
        for i in 0..<segmentCount {
            let dx = targets[i].x - positions[i].x
            let dy = targets[i].y - positions[i].y
            velocities[i].x = (velocities[i].x + dx * spring) * damp
            velocities[i].y = (velocities[i].y + dy * spring) * damp
            positions[i].x += velocities[i].x
            positions[i].y += velocities[i].y

            let spd = sqrt(velocities[i].x * velocities[i].x + velocities[i].y * velocities[i].y)
            if i > segmentCount - 6 { maxSpeed = max(maxSpeed, spd) }
        }
        tipSpeed = maxSpeed
    }

    // MARK: Target Positions

    func calculateTargets() -> [CGPoint] {
        var targets = [CGPoint](repeating: .zero, count: segmentCount)

        switch state {
        case .coiled:
            for i in 0..<segmentCount {
                targets[i] = coiledPosition(index: i, mouse: mousePos, phase: idlePhase)
            }

        case .winding:
            // Pull back slightly before strike
            let progress = easeInQuad(min(1, stateTime / windupTime))
            let pullBack: CGFloat = 12
            let windupOffset = CGPoint(
                x: -cos(strikeAngle) * pullBack * progress,
                y: -sin(strikeAngle) * pullBack * progress
            )
            let windupMouse = CGPoint(x: mousePos.x + windupOffset.x, y: mousePos.y + windupOffset.y)
            for i in 0..<segmentCount {
                let coiled = coiledPosition(index: i, mouse: mousePos, phase: idlePhase)
                // Tighten coil slightly during windup
                let tightened = CGPoint(
                    x: coiled.x + windupOffset.x * 0.5,
                    y: coiled.y + windupOffset.y * 0.5
                )
                targets[i] = tightened
            }

        case .striking:
            let progress = stateTime / strikeTime  // 0 to 1
            for i in 0..<segmentCount {
                let t = CGFloat(i) / CGFloat(segmentCount - 1)
                // Per-segment delay: handle moves first, tip follows with acceleration
                let segDelay = t * 0.5
                let segProgress = clamp(progress * 2.2 - segDelay, 0, 1)
                // Tip segments have extra acceleration (energy concentration)
                let easedProgress = t > 0.6 ? easeInQuad(segProgress) : easeOutCubic(segProgress)

                let coiled = coiledPosition(index: i, mouse: mousePos, phase: idlePhase)
                let extended = extendedPosition(index: i, mouse: mousePos)
                targets[i] = lerpPoint(coiled, extended, easedProgress)
            }

        case .cracking:
            // Hold at full extension with slight overshoot on tip
            for i in 0..<segmentCount {
                let t = CGFloat(i) / CGFloat(segmentCount - 1)
                var ext = extendedPosition(index: i, mouse: mousePos)
                // Tip overshoot
                if t > 0.8 {
                    let overshoot = (t - 0.8) / 0.2 * 15.0
                    ext.x += cos(strikeAngle) * overshoot
                    ext.y += sin(strikeAngle) * overshoot
                }
                targets[i] = ext
            }

        case .recoiling:
            let progress = stateTime / recoilTime  // 0 to 1
            for i in 0..<segmentCount {
                let t = CGFloat(i) / CGFloat(segmentCount - 1)
                // Tip recoils first (snaps back), handle section follows
                let segDelay = (1.0 - t) * 0.35
                let segProgress = clamp(progress * 1.8 - segDelay, 0, 1)
                let easedProgress = easeInOutCubic(segProgress)

                let extended = extendedPosition(index: i, mouse: mousePos)
                let coiled = coiledPosition(index: i, mouse: mousePos, phase: idlePhase)
                targets[i] = lerpPoint(extended, coiled, easedProgress)
            }
        }

        return targets
    }

    // MARK: Coiled Position (idle shape)

    func coiledPosition(index i: Int, mouse: CGPoint, phase: CGFloat) -> CGPoint {
        let t = CGFloat(i) / CGFloat(segmentCount - 1)

        // Breathing animation
        let breathe = 1.0 + sin(phase * 1.8) * 0.04

        // Handle section (first 15%): straight down-right from cursor
        if t < 0.15 {
            let handleT = t / 0.15
            let handleAngle: CGFloat = -0.5  // ~30 degrees below horizontal-right
            let handleLen: CGFloat = 25 * handleT
            return CGPoint(
                x: mouse.x + cos(handleAngle) * handleLen,
                y: mouse.y + sin(handleAngle) * handleLen
            )
        }

        // Coiled section (85% of whip): loops below handle
        let coilT = (t - 0.15) / 0.85  // 0 to 1 within coil section
        let handleEnd = CGPoint(
            x: mouse.x + cos(-0.5) * 25,
            y: mouse.y + sin(-0.5) * 25
        )

        // Spiral parameters
        let angle = coilT * coilLoops * 2 * .pi + phase * 0.5
        let radius = (coilRadius - coilT * 6) * breathe  // slightly tighter toward end
        // Vertical offset: coil hangs down progressively
        let sag = coilT * 18

        // Sway based on mouse movement
        let swayX = mouseVelX * 0.3 * (1.0 - coilT)

        return CGPoint(
            x: handleEnd.x + cos(angle) * radius + swayX,
            y: handleEnd.y + sin(angle) * radius - sag
        )
    }

    // MARK: Extended Position (full strike shape)

    func extendedPosition(index i: Int, mouse: CGPoint) -> CGPoint {
        let t = CGFloat(i) / CGFloat(segmentCount - 1)

        // Whip extends along a curved path from handle
        // Bezier curve: handle → up-arc → forward → tip
        let handleEnd = CGPoint(
            x: mouse.x + cos(-0.5) * 20,
            y: mouse.y + sin(-0.5) * 20
        )

        let reach = totalLength
        let p0 = handleEnd
        let p1 = CGPoint(
            x: handleEnd.x + cos(strikeAngle + 0.4) * reach * 0.25,
            y: handleEnd.y + sin(strikeAngle + 0.4) * reach * 0.25
        )
        let p2 = CGPoint(
            x: handleEnd.x + cos(strikeAngle - 0.15) * reach * 0.65,
            y: handleEnd.y + sin(strikeAngle - 0.15) * reach * 0.65
        )
        let p3 = CGPoint(
            x: handleEnd.x + cos(strikeAngle) * reach,
            y: handleEnd.y + sin(strikeAngle) * reach
        )

        // Handle section stays near cursor
        if t < 0.1 {
            let handleT = t / 0.1
            return lerpPoint(mouse, p0, handleT)
        }

        // Rest follows bezier
        let bezT = (t - 0.1) / 0.9
        return cubicBezier(bezT, p0, p1, p2, p3)
    }

    // MARK: Helpers

    func cubicBezier(_ t: CGFloat, _ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGPoint {
        let u = 1 - t
        return CGPoint(
            x: u*u*u*p0.x + 3*u*u*t*p1.x + 3*u*t*t*p2.x + t*t*t*p3.x,
            y: u*u*u*p0.y + 3*u*u*t*p1.y + 3*u*t*t*p2.y + t*t*t*p3.y
        )
    }

    func lerpPoint(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }

    func clamp(_ v: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        min(hi, max(lo, v))
    }

    func easeInQuad(_ t: CGFloat) -> CGFloat { t * t }
    func easeOutCubic(_ t: CGFloat) -> CGFloat { 1 - pow(1 - t, 3) }
    func easeInOutCubic(_ t: CGFloat) -> CGFloat {
        t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
    }

    var isCracking: Bool { state == .striking || state == .cracking }
    var isAnimating: Bool { state != .coiled }
}

// MARK: - Whip Drawing View (fullscreen overlay)

class WhipDrawingView: NSView {
    var animator: WhipAnimator?

    override func draw(_ dirtyRect: NSRect) {
        guard let anim = animator, let ctx = NSGraphicsContext.current?.cgContext else { return }

        let segs = anim.positions
        let count = segs.count
        guard count >= 2 else { return }

        ctx.setShouldAntialias(true)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)

        // ── Motion blur trails (during strike) ──
        if anim.isCracking || anim.tipSpeed > 8 {
            let trailSegments = max(0, count - 12)
            for i in trailSegments..<count {
                let vel = anim.velocities[i]
                let speed = sqrt(vel.x * vel.x + vel.y * vel.y)
                if speed < 4 { continue }

                let t = CGFloat(i) / CGFloat(count - 1)
                let width = lerp(3.0, 0.4, t)

                for trail in 1...5 {
                    let frac = CGFloat(trail) / 5.0
                    let alpha = (1.0 - frac) * 0.25 * min(1.0, speed / 25.0)
                    let tx = segs[i].x - vel.x * frac * 3.0
                    let ty = segs[i].y - vel.y * frac * 3.0

                    ctx.setStrokeColor(CGColor(red: 0.5, green: 0.3, blue: 0.12, alpha: alpha))
                    ctx.setLineWidth(width * (1.0 - frac * 0.5))
                    ctx.move(to: CGPoint(x: tx, y: ty))
                    ctx.addLine(to: segs[i])
                    ctx.strokePath()
                }
            }
        }

        // ── Shadow ──
        for i in 0..<(count - 1) {
            let t = CGFloat(i) / CGFloat(count - 1)
            let width = lerp(5.5, 0.8, t)
            ctx.setLineWidth(width + 2)
            ctx.setStrokeColor(NSColor(white: 0, alpha: 0.12).cgColor)
            ctx.move(to: offset(segs[i], dx: 1.5, dy: -1.5))
            ctx.addLine(to: offset(segs[i + 1], dx: 1.5, dy: -1.5))
            ctx.strokePath()
        }

        // ── Whip body — dark leather ──
        for i in 0..<(count - 1) {
            let t = CGFloat(i) / CGFloat(count - 1)
            let width = lerp(5.0, 0.7, t)

            let r = lerp(0.25, 0.42, t)
            let g = lerp(0.13, 0.24, t)
            let b = lerp(0.05, 0.10, t)
            ctx.setStrokeColor(CGColor(red: r, green: g, blue: b, alpha: 1))
            ctx.setLineWidth(width)
            ctx.move(to: segs[i])
            ctx.addLine(to: segs[i + 1])
            ctx.strokePath()
        }

        // ── Highlight stripe (braid sheen) ──
        for i in 0..<(count - 1) {
            let t = CGFloat(i) / CGFloat(count - 1)
            let width = lerp(2.0, 0.2, t)
            let alpha = lerp(0.35, 0.08, t)
            ctx.setStrokeColor(CGColor(red: 0.65, green: 0.45, blue: 0.25, alpha: alpha))
            ctx.setLineWidth(width)
            ctx.move(to: offset(segs[i], dx: 1.0, dy: 0.5))
            ctx.addLine(to: offset(segs[i + 1], dx: 1.0, dy: 0.5))
            ctx.strokePath()
        }

        // ── Braid texture marks ──
        for i in stride(from: 2, to: count - 3, by: 2) {
            let t = CGFloat(i) / CGFloat(count - 1)
            let markWidth = lerp(4.0, 0.4, t)
            if markWidth < 0.8 { continue }

            let p = segs[i]
            let next = segs[i + 1]
            let dx = next.x - p.x
            let dy = next.y - p.y
            let len = sqrt(dx * dx + dy * dy)
            guard len > 0.5 else { continue }
            let nx = -dy / len * markWidth * 0.3
            let ny = dx / len * markWidth * 0.3

            ctx.setStrokeColor(CGColor(red: 0.20, green: 0.10, blue: 0.03, alpha: 0.35))
            ctx.setLineWidth(0.7)
            ctx.move(to: CGPoint(x: p.x - nx, y: p.y - ny))
            ctx.addLine(to: CGPoint(x: p.x + nx, y: p.y + ny))
            ctx.strokePath()
        }

        // ── Handle ──
        let handlePos = segs[0]
        let handleNext = segs[min(3, count - 1)]
        let hdx = handleNext.x - handlePos.x
        let hdy = handleNext.y - handlePos.y
        let hLen = sqrt(hdx * hdx + hdy * hdy)
        guard hLen > 0.1 else { return }
        let hn = CGPoint(x: hdx / hLen, y: hdy / hLen)

        let handleLength: CGFloat = 20
        let handleEnd = CGPoint(x: handlePos.x - hn.x * handleLength, y: handlePos.y - hn.y * handleLength)

        // Handle shadow
        ctx.setStrokeColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.18))
        ctx.setLineWidth(10)
        ctx.move(to: offset(handlePos, dx: 1.5, dy: -1.5))
        ctx.addLine(to: offset(handleEnd, dx: 1.5, dy: -1.5))
        ctx.strokePath()

        // Handle wood
        ctx.setStrokeColor(CGColor(red: 0.35, green: 0.18, blue: 0.07, alpha: 1))
        ctx.setLineWidth(8)
        ctx.move(to: handlePos)
        ctx.addLine(to: handleEnd)
        ctx.strokePath()

        // Handle highlight
        let px = -hn.y * 1.5
        let py = hn.x * 1.5
        ctx.setStrokeColor(CGColor(red: 0.55, green: 0.35, blue: 0.18, alpha: 0.45))
        ctx.setLineWidth(2)
        ctx.move(to: CGPoint(x: handlePos.x + px, y: handlePos.y + py))
        ctx.addLine(to: CGPoint(x: handleEnd.x + px, y: handleEnd.y + py))
        ctx.strokePath()

        // Grip wraps
        ctx.setStrokeColor(CGColor(red: 0.22, green: 0.11, blue: 0.04, alpha: 0.6))
        ctx.setLineWidth(1.0)
        for j in stride(from: 3, to: Int(handleLength) - 2, by: 4) {
            let gx = handlePos.x - hn.x * CGFloat(j)
            let gy = handlePos.y - hn.y * CGFloat(j)
            let pw: CGFloat = 4.0
            ctx.move(to: CGPoint(x: gx - (-hn.y) * pw, y: gy - hn.x * pw))
            ctx.addLine(to: CGPoint(x: gx + (-hn.y) * pw, y: gy + hn.x * pw))
            ctx.strokePath()
        }

        // Pommel
        ctx.setFillColor(CGColor(red: 0.30, green: 0.15, blue: 0.05, alpha: 1))
        ctx.fillEllipse(in: CGRect(x: handleEnd.x - 5, y: handleEnd.y - 5, width: 10, height: 10))

        // ── Cracker (tip frays) ──
        let tip = segs[count - 1]
        let preTip = segs[count - 2]
        let tdx = tip.x - preTip.x
        let tdy = tip.y - preTip.y
        let tLen = sqrt(tdx * tdx + tdy * tdy)
        if tLen > 0.3 {
            let tnx = tdx / tLen, tny = tdy / tLen
            ctx.setStrokeColor(CGColor(red: 0.45, green: 0.28, blue: 0.12, alpha: 0.6))
            ctx.setLineWidth(0.5)
            ctx.move(to: tip)
            ctx.addLine(to: CGPoint(x: tip.x + tnx * 9 + tny * 3, y: tip.y + tny * 9 - tnx * 3))
            ctx.strokePath()
            ctx.move(to: tip)
            ctx.addLine(to: CGPoint(x: tip.x + tnx * 8 - tny * 3, y: tip.y + tny * 8 + tnx * 3))
            ctx.strokePath()
        }
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }
    private func offset(_ p: CGPoint, dx: CGFloat, dy: CGFloat) -> CGPoint { CGPoint(x: p.x + dx, y: p.y + dy) }
}

// MARK: - Animated Whip Cursor Overlay (fullscreen)

class WhipCursorOverlay: NSWindow {
    var whipAnimator: WhipAnimator!
    var drawingView: WhipDrawingView!
    private var displayTimer: Timer?

    init() {
        let frame = NSScreen.screens.reduce(NSRect.zero) { $0.union($1.frame) }
        super.init(
            contentRect: frame,
            styleMask: .borderless, backing: .buffered, defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()) + 1)
        ignoresMouseEvents = true
        hasShadow = false
        collectionBehavior = [.canJoinAllSpaces, .stationary]

        drawingView = WhipDrawingView(frame: frame)
        drawingView.wantsLayer = true
        drawingView.layer?.backgroundColor = NSColor.clear.cgColor
        contentView = drawingView

        let mouse = NSEvent.mouseLocation
        whipAnimator = WhipAnimator(origin: mouse)
        drawingView.animator = whipAnimator
    }

    func triggerCrack() {
        whipAnimator.strike()
    }

    func startTracking() {
        NSCursor.hide()
        orderFront(nil)

        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let mouse = NSEvent.mouseLocation
            let viewPoint = self.drawingView.convert(mouse, from: nil)
            self.whipAnimator.update(mouse: viewPoint, dt: 1.0 / 60.0)
            self.drawingView.needsDisplay = true
        }
    }

    func stopTracking() {
        displayTimer?.invalidate()
        displayTimer = nil
        orderOut(nil)
        NSCursor.unhide()
    }
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

        // Flash
        let flash = CALayer()
        flash.frame = CGRect(x: center.x - 30, y: center.y - 30, width: 60, height: 60)
        flash.cornerRadius = 30
        flash.backgroundColor = NSColor.white.cgColor
        flash.shadowColor = NSColor.orange.cgColor
        flash.shadowRadius = 20
        flash.shadowOpacity = 1
        flash.shadowOffset = .zero
        layer.addSublayer(flash)
        addAnim(flash, "opacity", from: 1.0, to: 0.0, dur: 0.25)
        addAnim(flash, "transform.scale", from: 0.3, to: 3.0, dur: 0.25)

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
            let dur = Double.random(in: 0.2...0.45)

            let posAnim = CABasicAnimation(keyPath: "position")
            posAnim.fromValue = NSValue(point: NSPoint(x: center.x, y: center.y))
            posAnim.toValue = NSValue(point: NSPoint(
                x: center.x + CGFloat(cos(angle)) * dist,
                y: center.y + CGFloat(sin(angle)) * dist))
            posAnim.duration = dur
            posAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            posAnim.fillMode = .forwards; posAnim.isRemovedOnCompletion = false
            spark.add(posAnim, forKey: "pos")

            addAnim(spark, "opacity", from: 1.0, to: 0.0, dur: dur)
            addAnim(spark, "transform.scale", from: 1.0, to: 0.1, dur: 0.4)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            self?.orderOut(nil)
            layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        }
    }

    private func addAnim(_ layer: CALayer, _ key: String, from: Any, to: Any, dur: Double) {
        let a = CABasicAnimation(keyPath: key)
        a.fromValue = from; a.toValue = to; a.duration = dur
        a.fillMode = .forwards; a.isRemovedOnCompletion = false
        layer.add(a, forKey: key)
    }
}

// MARK: - Toast Notification

class ToastWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 44),
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
        view.layer?.backgroundColor = NSColor(red: 0.12, green: 0.10, blue: 0.16, alpha: 0.94).cgColor
        view.layer?.cornerRadius = height / 2
        view.layer?.borderWidth = 1
        view.layer?.borderColor = NSColor(red: 1, green: 0.5, blue: 0, alpha: 0.5).cgColor

        let label = NSTextField(labelWithString: text)
        label.font = font
        label.textColor = NSColor(red: 1, green: 0.85, blue: 0.5, alpha: 1)
        label.frame = NSRect(x: padding, y: (height - textSize.height) / 2, width: textSize.width + 4, height: textSize.height)
        view.addSubview(label)

        contentView = view
        alphaValue = 0
        orderFront(nil)

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.12
            self.animator().alphaValue = 1
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.4
                self.animator().alphaValue = 0
            }, completionHandler: {
                self.orderOut(nil)
            })
        }
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
        w.title = "About Whip"; w.center(); w.isReleasedWhenClosed = false

        let view = NSView(frame: w.contentView!.bounds)
        let icon = NSTextField(labelWithString: "🤠")
        icon.font = NSFont.systemFont(ofSize: 64)
        icon.frame = NSRect(x: 140, y: 190, width: 70, height: 70); view.addSubview(icon)

        let title = NSTextField(labelWithString: "Whip v\(APP_VERSION)")
        title.font = NSFont.boldSystemFont(ofSize: 18)
        title.frame = NSRect(x: 70, y: 158, width: 200, height: 24); title.alignment = .center; view.addSubview(title)

        let subtitle = NSTextField(labelWithString: "Motivate your AI with style")
        subtitle.font = NSFont.systemFont(ofSize: 13); subtitle.textColor = .secondaryLabelColor
        subtitle.frame = NSRect(x: 50, y: 134, width: 240, height: 20); subtitle.alignment = .center; view.addSubview(subtitle)

        let desc = NSTextField(wrappingLabelWithString:
            "Every click cracks the whip.\nEvery crack ships a feature.\n\nA fun productivity companion for developers who like to keep their AI assistants on their toes.\n\nFree & open source.")
        desc.font = NSFont.systemFont(ofSize: 12); desc.textColor = .secondaryLabelColor
        desc.frame = NSRect(x: 30, y: 20, width: 280, height: 110); desc.alignment = .center; view.addSubview(desc)

        w.contentView = view; w.makeKeyAndOrderFront(nil); window = w
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
    var whipOverlay: WhipCursorOverlay!
    var aboutCtrl = AboutWindowController()

    var audioPlayers: [AVAudioPlayer] = []
    var crackCount = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupAudio()
        setupStatusBar()

        crackWindow = CrackEffectWindow()
        toastWindow = ToastWindow()
        whipOverlay = WhipCursorOverlay()

        enable()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let center = NSPoint(
                x: NSScreen.main?.frame.midX ?? 500,
                y: NSScreen.main?.frame.midY ?? 400
            )
            self.toastWindow.show(text: "🤠 Whip activated! Click anywhere to crack.", near: center)
        }
    }

    func setupAudio() {
        let appDir = Bundle.main.resourcePath
            ?? (ProcessInfo.processInfo.environment["WHIP_DIR"]
                ?? (FileManager.default.homeDirectoryForCurrentUser.path + "/bin/whip-app"))
        let searchPaths = [appDir, appDir + "/Resources", appDir + "/.."]

        for i in 1...CRACK_SOUND_COUNT {
            let filename = "crack_\(i).wav"
            for base in searchPaths {
                let path = base + "/" + filename
                if FileManager.default.fileExists(atPath: path) {
                    let url = URL(fileURLWithPath: path)
                    if let player = try? AVAudioPlayer(contentsOf: url) {
                        player.prepareToPlay(); player.volume = 0.85
                        audioPlayers.append(player); break
                    }
                }
            }
        }
        if audioPlayers.isEmpty {
            print("⚠️  No sound files found.")
        } else {
            print("🔊 Loaded \(audioPlayers.count) whip sounds")
        }
    }

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🤠"
        updateTooltip()

        let menu = NSMenu()
        let enableItem = NSMenuItem(title: "Enabled", action: #selector(toggleEnabled), keyEquivalent: "e")
        enableItem.state = .on; enableItem.tag = 10; menu.addItem(enableItem)
        menu.addItem(NSMenuItem.separator())
        let cursorItem = NSMenuItem(title: "Whip Cursor", action: #selector(toggleCursor), keyEquivalent: "c")
        cursorItem.state = .on; cursorItem.tag = 20; menu.addItem(cursorItem)
        let toastItem = NSMenuItem(title: "Motivational Lines", action: #selector(toggleToasts), keyEquivalent: "m")
        toastItem.state = .on; toastItem.tag = 30; menu.addItem(toastItem)
        menu.addItem(NSMenuItem.separator())
        let statsItem = NSMenuItem(title: "Cracks: 0", action: nil, keyEquivalent: "")
        statsItem.tag = 100; statsItem.isEnabled = false; menu.addItem(statsItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About Whip", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    func updateTooltip() {
        statusItem.button?.toolTip = isEnabled ? "Whip — \(crackCount) cracks" : "Whip — paused"
    }

    @objc func toggleEnabled() {
        if isEnabled { disable() } else { enable() }
        if let item = statusItem.menu?.item(withTag: 10) { item.state = isEnabled ? .on : .off }
        statusItem.button?.title = isEnabled ? "🤠" : "💤"
        updateTooltip()
    }

    @objc func toggleCursor() {
        cursorEnabled.toggle()
        if let item = statusItem.menu?.item(withTag: 20) { item.state = cursorEnabled ? .on : .off }
        if cursorEnabled && isEnabled { whipOverlay.startTracking() } else { whipOverlay.stopTracking() }
    }

    @objc func toggleToasts() {
        toastEnabled.toggle()
        if let item = statusItem.menu?.item(withTag: 30) { item.state = toastEnabled ? .on : .off }
    }

    @objc func showAbout() { aboutCtrl.show() }

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
        if cursorEnabled { whipOverlay.startTracking() }
    }

    func disable() {
        isEnabled = false
        if let m = globalMonitor { NSEvent.removeMonitor(m); globalMonitor = nil }
        if let m = localMonitor { NSEvent.removeMonitor(m); localMonitor = nil }
        whipOverlay.stopTracking()
    }

    func handleClick(at point: NSPoint) {
        playSound()
        whipOverlay.triggerCrack()
        crackCount += 1

        // Show sparks at whip tip position after strike delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            // Spark at tip of whip (approximate: forward from click point)
            let angle = self.whipOverlay.whipAnimator.strikeAngle
            let tipX = point.x + cos(angle) * 160
            let tipY = point.y + sin(angle) * 160
            self.crackWindow.showCrack(at: NSPoint(x: tipX, y: tipY))
        }

        if let item = statusItem.menu?.item(withTag: 100) { item.title = "Cracks: \(crackCount)" }
        updateTooltip()

        // Show toast every 3rd click
        if toastEnabled && crackCount % 3 == 0 {
            let line = MOTIVATIONAL_LINES[Int.random(in: 0..<MOTIVATIONAL_LINES.count)]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.toastWindow.show(text: line, near: point)
            }
        }
    }

    func playSound() {
        guard !audioPlayers.isEmpty else { return }
        let player = audioPlayers[Int.random(in: 0..<audioPlayers.count)]
        player.currentTime = 0
        player.play()
    }

    @objc func quit() { disable(); NSApplication.shared.terminate(nil) }
}

// MARK: - Main

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
