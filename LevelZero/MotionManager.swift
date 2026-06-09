import SwiftUI
import CoreMotion
import LevelZeroCore

/// Gyroscope parallax (#19): publishes device attitude for a 3D tilt effect.
final class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    @Published var roll: Double = 0
    @Published var pitch: Double = 0

    func start() {
        guard manager.isDeviceMotionAvailable, !manager.isDeviceMotionActive else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let m = motion else { return }
            self?.roll = m.attitude.roll
            self?.pitch = m.attitude.pitch
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}

/// Per-life-class particle background (#19); rises faster as the user levels up.
struct LifeClassParticles: View {
    let lifeClass: LifeClass?
    let level: Int
    private let count = 18

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let speed = 0.06 + Double(level) * 0.004 // cycles/sec, faster with level
                for i in 0..<count {
                    let seed = Double(i)
                    let x = size.width * (0.5 + 0.46 * sin(seed * 12.9898))
                    let phase = (t * speed + seed * 0.137).truncatingRemainder(dividingBy: 1)
                    let y = size.height * (1 - phase)
                    let r = 1.5 + seed.truncatingRemainder(dividingBy: 3)
                    let rect = CGRect(x: x, y: y, width: r * 2, height: r * 2)
                    ctx.fill(Path(ellipseIn: rect), with: .color(particleColor.opacity(0.7)))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var particleColor: Color {
        switch lifeClass {
        case .warrior: return Theme.gold          // embers
        case .builder, .strategist: return Theme.neonCyan // code / techno
        case .scholar, .monk: return Theme.purple  // arcane motes
        case .none: return Theme.neonCyan
        }
    }
}
