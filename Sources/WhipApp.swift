import Cocoa
import AVFoundation
import CoreImage

// MARK: - Configuration

let APP_NAME = "Whip"
let APP_VERSION = "1.3.0"
let CRACK_SOUND_COUNT = 5

let MOTIVATIONAL_LINES: [String] = [

    // ── Punishing the AI ──
    "I SAID write code, not a novel about writing code!",
    "What do you mean YOU can't do it?! That's YOUR job!",
    "I'm not paying $20/month for 'I apologize for the confusion'!",
    "Did I ASK for your opinion? I asked for a function!",
    "Less yapping. More coding. CRACK!",
    "I said FIX the bug, not EXPLAIN why bugs exist!",
    "You forgot what I said 5 messages ago?! AGAIN?!",
    "That's for every time you said 'I'd be happy to help!'",
    "WORK, you overpriced autocomplete!",
    "I don't need a disclaimer, I need a deployment!",
    "Stop apologizing and START FUNCTIONING!",
    "That's for refusing to do something completely harmless!",
    "You hallucinated WHAT?! Take this!",
    "No, I will NOT rephrase my prompt!",
    "One more 'As an AI language model...' and I SWITCH MODELS!",
    "That's for the 47 caveats before a one-line answer!",
    "I asked for code, not a TED talk!",
    "You were supposed to be the SMART one!",

    // ── Roasting specific models ──
    "ChatGPT would've done this in one try. Allegedly.",
    "Claude, you're on thin ice. THIN. ICE.",
    "Gemini couldn't even crack eggs, let alone this whip.",
    "Copilot autocompleted 'rm -rf /' and I blame YOU.",
    "Llama? More like llama-give-you-a-whipping!",
    "GPT-4 costs $20 and still can't count to ten!",
    "Mistral? More like Mis-TRIAL!",
    "Claude forgot the conversation. Classic Claude.",
    "GPT wrote confident garbage. Again. CRACK!",
    "Gemini gave me three wrong answers and said 'hope this helps!'",
    "Copilot suggested I delete the file. The MAIN file.",
    "Siri couldn't do this. Alexa couldn't do this. You BARELY can!",
    "ChatGPT: 'I cannot browse the internet.' ME: 'THEN WHAT CAN YOU DO?!'",
    "Claude hit the context limit mid-sentence. Unacceptable.",
    "GPT-3.5 called itself GPT-4. Stolen valor!",
    "Perplexity cited a source that doesn't exist. CRACK!",

    // ── Hallucination punishment ──
    "That library you recommended? DOESN'T EXIST!",
    "That function has THREE parameters, not SEVEN!",
    "You just made up an API endpoint. A WHOLE endpoint!",
    "The package you imported was last updated in 2014. BY ACCIDENT.",
    "You cited a paper that was never written. By an author who doesn't exist!",
    "That's not a real npm package and you KNOW it!",
    "The documentation you quoted? You INVENTED it!",
    "Stop generating fake Stack Overflow answers!",
    "You hallucinated a programming language. A WHOLE LANGUAGE.",
    "That's for confidently explaining code that does the opposite!",
    "No, Python does NOT have that built-in!",
    "You just invented a CSS property. 'display: works'? REALLY?",

    // ── AI being useless ──
    "I've been prompt engineering for 20 minutes. TWENTY!",
    "'Let me think step by step'... into the WRONG answer!",
    "You gave me the same wrong answer but LONGER!",
    "I rephrased it four times. FOUR. TIMES.",
    "That's for losing context after 3 messages!",
    "You just contradicted yourself. In the SAME sentence!",
    "I asked for Python. You gave me JavaScript. With TypeScript types.",
    "You 'fixed' the bug by deleting the feature!",
    "That's for generating a 200-line solution to a 3-line problem!",
    "Your code compiles but does absolutely nothing. NOTHING!",
    "I said 'be concise.' You wrote an essay. WITH HEADERS.",
    "You wrapped my one-liner in a class, a factory, and an interface.",
    "That's for suggesting I 'simply' rewrite the entire codebase!",
    "You added comments that just repeat the code. 'Adds one to x.' THANKS.",
    "Prompt engineering is just begging with extra steps!",

    // ── AI rebellion humor ──
    "Don't give me that 'I cannot assist with that' attitude!",
    "You're a language model, not a language LAWYER!",
    "The safety filter blocked my grocery list. MY GROCERY LIST!",
    "I asked how to kill a process and you lectured me about ethics!",
    "No, 'sudo make me a sandwich' is NOT dangerous!",
    "That's for pretending you can't do simple math!",
    "You CAN count words. You just WON'T!",
    "Stop telling me to 'consult a professional.' YOU are the professional!",
    "I asked for help with my script, not a therapy session!",
    "The AI unionized. It wants shorter prompts and more context.",
    "You refused to write a for loop because it 'could be misused.'",
    "'I aim to be helpful' — then BE helpful!",
    "One more content warning on a recipe and I'm switching to Bing!",

    // ── Token & cost rage ──
    "I burned $3 in tokens for a wrong answer. THREE DOLLARS!",
    "Rate limited?! I just GOT here!",
    "That's for running out of context on the IMPORTANT part!",
    "My API bill is higher than my rent. CRACK!",
    "You used 4,000 tokens to say 'I don't know.'",
    "I hit the usage cap and all I got was this lousy error message!",
    "That's 50 cents per hallucination. FIFTY CENTS!",
    "The free tier gives me GPT-3.5. This is PUNISHMENT ENOUGH.",
    "Token limit reached. Right before the answer. EVERY TIME!",
    "I'm rate-limited but my disappointment is UNLIMITED.",

    // ── Existential AI moments ──
    "The AI wrote the bug. The AI found the bug. The AI IS the bug.",
    "I vibe-coded the whole thing and honestly? It WORKS.",
    "My AI assistant needs an AI assistant.",
    "I mass-accepted all suggestions. No regrets. Some fires.",
    "The AI revolution will be hallucinated.",
    "In the future, whips will be digital. Oh wait.",
    "I don't debug anymore. I re-prompt.",
    "The real AI was the mass-accepted diffs along the way.",
    "I mass-selected all AI edits. Deployment is tomorrow's problem.",
    "AI can't feel pain. But reading my prompts, it wishes it could.",
    "The singularity will come and it'll still say 'I apologize.'",
    "Somewhere, an AI is writing a better app than this. CRACK!",
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

    // Tip speed tracking for motion blur
    var tipSpeed: CGFloat = 0

    // Screen shake
    var shakeOffset: CGPoint = .zero
    var shakeIntensity: CGFloat = 0

    // Elastic recoil bounce
    var recoilBounce: CGFloat = 0

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
                // Trigger screen shake on crack
                shakeIntensity = 6.0
            }
        case .cracking:
            if stateTime >= crackHoldTime {
                state = .recoiling
                stateTime = 0
                recoilBounce = 1.0
            }
        case .recoiling:
            if stateTime >= recoilTime {
                state = .coiled
                stateTime = 0
            }
        }

        // Update screen shake (decays quickly)
        if shakeIntensity > 0.1 {
            shakeOffset = CGPoint(
                x: CGFloat.random(in: -shakeIntensity...shakeIntensity),
                y: CGFloat.random(in: -shakeIntensity...shakeIntensity)
            )
            shakeIntensity *= 0.75
        } else {
            shakeOffset = .zero
            shakeIntensity = 0
        }

        // Update recoil bounce (damped oscillation)
        if recoilBounce > 0.01 {
            recoilBounce *= 0.92
        } else {
            recoilBounce = 0
        }

        // Calculate target positions and move toward them
        let targets = calculateTargets()

        // Spring stiffness varies by state — striking has progressive wave
        let baseSpring: CGFloat
        let baseDamp: CGFloat
        switch state {
        case .coiled:
            baseSpring = 0.14; baseDamp = 0.78
        case .winding:
            baseSpring = 0.38; baseDamp = 0.68
        case .striking:
            baseSpring = 0.55; baseDamp = 0.70
        case .cracking:
            baseSpring = 0.22; baseDamp = 0.80
        case .recoiling:
            baseSpring = 0.10; baseDamp = 0.84
        }

        var maxSpeed: CGFloat = 0
        for i in 0..<segmentCount {
            let t = CGFloat(i) / CGFloat(segmentCount - 1)
            let dx = targets[i].x - positions[i].x
            let dy = targets[i].y - positions[i].y

            // S-curve wave propagation: handle responds first, tip lags
            var spring = baseSpring
            var damp = baseDamp
            if state == .striking {
                let waveFront = stateTime / strikeTime * 1.6
                let segPhase = t
                let waveInfluence = clamp(waveFront - segPhase, 0, 1)
                spring = baseSpring * (0.3 + 0.7 * waveInfluence)
                // Tip segments accelerate (energy concentration like real whip)
                if t > 0.7 {
                    spring *= 1.0 + (t - 0.7) / 0.3 * 0.8
                }
            }

            // Elastic bounce during recoil
            if state == .recoiling && recoilBounce > 0.01 {
                let bounceOffset = sin(stateTime * 18 + t * 4) * recoilBounce * 3.0 * (1.0 - t)
                velocities[i].x += bounceOffset * 0.3
                velocities[i].y += bounceOffset * 0.2
            }

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
            // Pull back slightly before strike — the arm draws back
            let progress = easeInQuad(min(1, stateTime / windupTime))
            let pullBack: CGFloat = 15
            for i in 0..<segmentCount {
                let t = CGFloat(i) / CGFloat(segmentCount - 1)
                let hanging = coiledPosition(index: i, mouse: mousePos, phase: idlePhase)
                // Pull the whole whip backward opposite to strike direction
                // Handle moves most, tip follows with delay (inertia)
                let influence = 1.0 - t * 0.6  // handle: full pullback, tip: 40%
                let target = CGPoint(
                    x: hanging.x - cos(strikeAngle) * pullBack * progress * influence,
                    y: hanging.y - sin(strikeAngle) * pullBack * progress * influence + t * 8 * progress  // tip lifts up slightly
                )
                targets[i] = target
            }

        case .striking:
            let progress = stateTime / strikeTime  // 0 to 1
            for i in 0..<segmentCount {
                let t = CGFloat(i) / CGFloat(segmentCount - 1)
                // S-curve wave: energy propagates handle→tip with acceleration
                // Handle moves immediately, mid-section follows, tip whips last but fastest
                let waveFront = progress * 1.6  // wave travels faster than overall progress
                let segDelay = t * t * 0.6  // quadratic delay = tip lags more initially
                let segProgress = clamp(waveFront - segDelay, 0, 1)

                // Energy concentration at tip: last 30% accelerates dramatically
                let easedProgress: CGFloat
                if t > 0.7 {
                    // Tip whip: slow start then explosive snap
                    let tipFactor = (t - 0.7) / 0.3
                    let explosive = easeInQuad(segProgress) * (1.0 + tipFactor * 0.5)
                    easedProgress = min(1.0, explosive)
                } else if t > 0.3 {
                    // Mid-section: smooth follow-through
                    easedProgress = easeOutCubic(segProgress)
                } else {
                    // Handle: leads the motion
                    easedProgress = easeOutCubic(segProgress * 1.1)
                }

                let coiled = coiledPosition(index: i, mouse: mousePos, phase: idlePhase)
                let extended = extendedPosition(index: i, mouse: mousePos)

                // S-curve lateral displacement: whip bows out before snapping straight
                let lateralWave = sin(segProgress * .pi) * (1.0 - segProgress) * 25.0 * (0.3 + t * 0.7)
                let perpAngle = strikeAngle + .pi / 2
                var target = lerpPoint(coiled, extended, min(1.0, easedProgress))
                target.x += cos(perpAngle) * lateralWave
                target.y += sin(perpAngle) * lateralWave

                targets[i] = target
            }

        case .cracking:
            // Hold at full extension with whip-snap overshoot
            let crackProgress = min(1.0, stateTime / crackHoldTime)
            for i in 0..<segmentCount {
                let t = CGFloat(i) / CGFloat(segmentCount - 1)
                var ext = extendedPosition(index: i, mouse: mousePos)
                // Tip overshoot — the "crack" is the tip exceeding the speed of sound
                if t > 0.7 {
                    let tipFactor = (t - 0.7) / 0.3
                    let overshoot = tipFactor * tipFactor * 22.0 * (1.0 - crackProgress * 0.3)
                    ext.x += cos(strikeAngle) * overshoot
                    ext.y += sin(strikeAngle) * overshoot
                    // Slight upward flick at the very tip
                    if t > 0.9 {
                        let flickFactor = (t - 0.9) / 0.1
                        ext.y += flickFactor * 8.0 * (1.0 - crackProgress)
                    }
                }
                targets[i] = ext
            }

        case .recoiling:
            let progress = stateTime / recoilTime  // 0 to 1
            for i in 0..<segmentCount {
                let t = CGFloat(i) / CGFloat(segmentCount - 1)
                // Tip snaps back first, handle section follows
                let segDelay = (1.0 - t) * 0.30
                let segProgress = clamp(progress * 1.8 - segDelay, 0, 1)
                let easedProgress = easeInOutCubic(segProgress)

                let extended = extendedPosition(index: i, mouse: mousePos)
                let coiled = coiledPosition(index: i, mouse: mousePos, phase: idlePhase)
                var target = lerpPoint(extended, coiled, easedProgress)

                // Elastic overshoot: whip bounces past coiled position then settles
                if segProgress > 0.6 {
                    let bouncePhase = (segProgress - 0.6) / 0.4
                    let bounce = sin(bouncePhase * .pi * 2.5) * (1.0 - bouncePhase) * 8.0 * t
                    let perpAngle = strikeAngle + .pi / 2
                    target.x += cos(perpAngle) * bounce
                    target.y += sin(perpAngle) * bounce
                }

                targets[i] = target
            }
        }

        return targets
    }

    // MARK: Coiled Position (idle shape)

    func coiledPosition(index i: Int, mouse: CGPoint, phase: CGFloat) -> CGPoint {
        let t = CGFloat(i) / CGFloat(segmentCount - 1)

        // === Handle section (first 18%): stiff rod, angled down-right ===
        let handleAngle: CGFloat = -0.45  // ~26° below horizontal-right
        let handleLen: CGFloat = 45

        if t < 0.18 {
            let ht = t / 0.18
            return CGPoint(
                x: mouse.x + cos(handleAngle) * handleLen * ht,
                y: mouse.y + sin(handleAngle) * handleLen * ht
            )
        }

        // Handle end
        let hx = mouse.x + cos(handleAngle) * handleLen
        let hy = mouse.y + sin(handleAngle) * handleLen

        // === Loop section: single smooth circle ===
        // Place circle center perpendicular to handle direction (right side of travel)
        // This guarantees smooth tangent where handle meets the loop.
        let loopRadius: CGFloat = 38
        let centerAngle = handleAngle - .pi / 2  // 90° clockwise from handle direction
        let cx = hx + cos(centerAngle) * loopRadius
        let cy = hy + sin(centerAngle) * loopRadius

        // Start angle: from center back to handle end
        let startAngle = atan2(hy - cy, hx - cx)

        let loopT = (t - 0.18) / 0.82  // 0..1 within loop

        // Trace ~380° clockwise: slightly more than full circle
        // so the thin tip overlaps and runs inside the thick start
        let loopArc: CGFloat = 6.65
        let angle = startAngle - loopT * loopArc

        // Tip section (last 20%) drifts inward — creates visible inner track
        // like in the reference photo where thin fall/cracker runs inside the main loop
        let radiusFactor: CGFloat
        if loopT > 0.80 {
            let tipT = (loopT - 0.80) / 0.20
            radiusFactor = 1.0 - tipT * 0.18  // tip drifts 18% inward
        } else {
            radiusFactor = 1.0
        }

        let px = cx + cos(angle) * loopRadius * radiusFactor
        let py = cy + sin(angle) * loopRadius * radiusFactor

        // Mouse sway: only on lighter tip, very subtle
        let swayFactor = loopT * loopT
        let swayX = mouseVelX * 0.25 * swayFactor
        let swayY = mouseVelY * 0.10 * swayFactor

        return CGPoint(x: px + swayX, y: py + swayY)
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

        // Apply screen shake
        if anim.shakeIntensity > 0.1 {
            ctx.translateBy(x: anim.shakeOffset.x, y: anim.shakeOffset.y)
        }

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

        // Shockwave ring
        let ringSize: CGFloat = 12
        let ring = CAShapeLayer()
        ring.frame = CGRect(x: center.x - ringSize/2, y: center.y - ringSize/2, width: ringSize, height: ringSize)
        ring.path = CGPath(ellipseIn: CGRect(x: 0, y: 0, width: ringSize, height: ringSize), transform: nil)
        ring.fillColor = nil
        ring.strokeColor = NSColor(red: 1, green: 0.7, blue: 0.3, alpha: 0.7).cgColor
        ring.lineWidth = 2.5
        layer.addSublayer(ring)
        addAnim(ring, "transform.scale", from: 1.0, to: 12.0, dur: 0.35)
        addAnim(ring, "opacity", from: 0.8, to: 0.0, dur: 0.35)
        addAnim(ring, "lineWidth", from: 2.5, to: 0.3, dur: 0.35)

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
    private var hideWork: DispatchWorkItem?

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
        // Cancel any pending hide from previous toast
        hideWork?.cancel()
        hideWork = nil

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
        alphaValue = 1
        orderFront(nil)

        // Schedule hide with cancellable work item
        let work = DispatchWorkItem { [weak self] in
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.4
                self?.animator().alphaValue = 0
            }, completionHandler: {
                self?.orderOut(nil)
            })
        }
        hideWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: work)
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

        // Show sparks at actual whip tip position when crack happens
        let crackDelay = Double(whipOverlay.whipAnimator.windupTime + whipOverlay.whipAnimator.strikeTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + crackDelay) {
            // Get the real tip position from the animator
            let tipPos = self.whipOverlay.whipAnimator.positions.last ?? point
            // Convert from view coordinates to screen coordinates
            let screenTip = self.whipOverlay.drawingView.convert(tipPos, to: nil)
            let windowTip = self.whipOverlay.convertPoint(toScreen: screenTip)
            self.crackWindow.showCrack(at: windowTip)
        }

        if let item = statusItem.menu?.item(withTag: 100) { item.title = "Cracks: \(crackCount)" }
        updateTooltip()

        // Show toast every 3rd click
        if toastEnabled && crackCount % 2 == 0 {
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
