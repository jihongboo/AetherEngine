import Testing
@testable import AetherEngine

@Suite("VideoFormat")
struct VideoFormatTests {

    @Test("All five cases are distinct under Equatable")
    func allCasesAreDistinct() {
        let all: [VideoFormat] = [.sdr, .hdr10, .hdr10Plus, .dolbyVision, .hlg]
        for (i, a) in all.enumerated() {
            for (j, b) in all.enumerated() {
                if i == j {
                    #expect(a == b)
                } else {
                    #expect(a != b)
                }
            }
        }
    }

    @Test("Sendable across actor boundary")
    func sendableCrossesActorBoundary() async {
        let format: VideoFormat = .dolbyVision
        let received = await Task.detached { format }.value
        #expect(received == .dolbyVision)
    }

    @Test("enableHDR clamps effective and presented video format to SDR")
    func enableHDRClampsToSDR() {
        let hdrCaps = DisplayCapabilities(
            supportsHDR: true,
            supportsDolbyVision: true,
            supportsHDR10: true,
            supportsHLG: true
        )
        // With enableHDR: true (default), DV is kept
        let effectiveWithHDR = AetherEngine.effectiveVideoFormat(
            detected: .dolbyVision,
            baseTransfer: .init(16), // SMPTE2084
            capabilities: hdrCaps,
            enableHDR: true
        )
        #expect(effectiveWithHDR == .dolbyVision)

        // With enableHDR: false, format is clamped to SDR
        let effectiveDisabled = AetherEngine.effectiveVideoFormat(
            detected: .dolbyVision,
            baseTransfer: .init(16),
            capabilities: hdrCaps,
            enableHDR: false
        )
        #expect(effectiveDisabled == .sdr)

        let presentedDisabled = AetherEngine.presentedVideoFormat(
            effectiveFormat: .dolbyVision,
            panelPresentsHDR: true,
            sourceVideoFormat: .dolbyVision,
            enableHDR: false
        )
        #expect(presentedDisabled == .sdr)
    }
}
