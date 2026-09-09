//
//  File.swift
//  Self Assembling SugarTests
//
//  Created by David Nishimoto on 9/9/26.
//


//
//  QRTLEnergyShellTests.swift
//  Self Assembling SugarTests
//
//  Created by David Nishimoto on 9/6/26.
//

import XCTest
import Testing
import SceneKit

@testable import Self_Assembling_Sugar

final class QRTLEnergyShellTests: XCTestCase {
    
    private let doubleTolerance = 0.000001
    private let floatTolerance: Float = 0.0001
    
    // ============================================================
    // MARK: - Numeric Assertion
    // ============================================================
    
    private func assertEqual(
        _ actual: Double,
        _ expected: Double,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            actual,
            expected,
            accuracy: doubleTolerance,
            message,
            file: file,
            line: line
        )
    }
    
    // ============================================================
    // MARK: - Configuration Helper
    // ============================================================
    
    private func configure(
        _ controller: QRTLSceneController,
        current: Double,
        driveFrequencyHz: Double,
        resonanceFrequencyHz: Double,
        maximumDetuningHz: Double,
        minimumShellCurrent: Double,
        coherence: Double = 1.0,
        coupling: Double = 1.0
    ) {
        controller.configureEnergyShellForTesting(
            current: current,
            driveFrequencyHz: driveFrequencyHz,
            resonanceFrequencyHz: resonanceFrequencyHz,
            maximumDetuningHz: maximumDetuningHz,
            minimumShellCurrent: minimumShellCurrent,
            coherence: coherence,
            coupling: coupling
        )
    }
    
    // ============================================================
    // MARK: - Current Configuration
    // ============================================================
    
    func testCurrentBelowMinimumPreventsEnergyShellFormation() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 0.499,
            driveFrequencyHz: 100.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.500
        )
        
        XCTAssertTrue(
            controller.isFrequencyLocked,
            "Frequency should be locked; this test isolates insufficient current."
        )
        
        XCTAssertFalse(
            controller.isEnergyShellActive,
            "Energy shell must not form when current is below the required minimum."
        )
        
        XCTAssertNil(
            controller.energyShellNode,
            "A shell node should not be created when formation requirements fail."
        )
    }
    
    func testCurrentExactlyAtMinimumAllowsEnergyShellFormation() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 0.500,
            driveFrequencyHz: 100.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.500
        )
        
        XCTAssertTrue(
            controller.isFrequencyLocked,
            "Frequency must lock at exact resonance."
        )
        
        XCTAssertTrue(
            controller.isEnergyShellActive,
            "Current exactly equal to the threshold should allow shell formation."
        )
        
        XCTAssertNotNil(
            controller.energyShellNode,
            "An active shell must create an energy-shell node."
        )
    }
    
    func testCurrentAboveMinimumAllowsEnergyShellFormation() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 0.75,
            driveFrequencyHz: 100.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.50
        )
        
        XCTAssertTrue(
            controller.isFrequencyLocked
        )
        
        XCTAssertTrue(
            controller.isEnergyShellActive,
            "Current above the required threshold should permit shell formation."
        )
    }
    
    // ============================================================
    // MARK: - Frequency and Resonance Configuration
    // ============================================================
    
    func testExactResonanceProducesZeroDetuningAndFrequencyLock() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 250.0,
            resonanceFrequencyHz: 250.0,
            maximumDetuningHz: 0.5,
            minimumShellCurrent: 0.1
        )
        
        assertEqual(
            controller.frequencyDetuningHz,
            0.0,
            "Exact resonance must report zero detuning."
        )
        
        XCTAssertTrue(
            controller.isFrequencyLocked,
            "Matching drive and resonance frequencies must lock."
        )
        
        XCTAssertTrue(
            controller.isEnergyShellActive,
            "A shell should form when current and all other requirements are met."
        )
    }
    
    func testDetuningInsideToleranceMaintainsFrequencyLock() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 100.75,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1
        )
        
        assertEqual(
            controller.frequencyDetuningHz,
            0.75,
            "Detuning must equal the absolute drive-to-resonance difference."
        )
        
        XCTAssertTrue(
            controller.isFrequencyLocked,
            "A detuning smaller than the allowed tolerance must remain locked."
        )
        
        XCTAssertTrue(
            controller.isEnergyShellActive,
            "The shell should form while frequency remains within tolerance."
        )
    }
    
    func testDetuningAtExactToleranceMaintainsFrequencyLock() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 101.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1
        )
        
        assertEqual(
            controller.frequencyDetuningHz,
            1.0,
            "Detuning should equal the exact configured boundary."
        )
        
        XCTAssertTrue(
            controller.isFrequencyLocked,
            "The frequency-lock boundary should be inclusive."
        )
        
        XCTAssertTrue(
            controller.isEnergyShellActive,
            "The shell should remain active at the inclusive detuning boundary."
        )
    }
    
    func testDetuningBeyondToleranceBreaksFrequencyLockAndPreventsShellFormation() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 101.000001,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1
        )
        
        XCTAssertGreaterThan(
            controller.frequencyDetuningHz,
            controller.maximumFrequencyDetuningHz,
            "This test must be outside the allowed resonance tolerance."
        )
        
        XCTAssertFalse(
            controller.isFrequencyLocked,
            "Detuning beyond tolerance must break frequency lock."
        )
        
        XCTAssertFalse(
            controller.isEnergyShellActive,
            "The shell must not form while the drive frequency is off resonance."
        )
    }
    
    func testLowerDriveFrequencyUsesAbsoluteFrequencyDetuning() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 99.25,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1
        )
        
        assertEqual(
            controller.frequencyDetuningHz,
            0.75,
            "Detuning must be positive even when drive frequency is lower."
        )
        
        XCTAssertTrue(
            controller.isFrequencyLocked,
            "A lower drive frequency inside tolerance must still lock."
        )
        
        XCTAssertTrue(
            controller.isEnergyShellActive
        )
    }
    
    // ============================================================
    // MARK: - Coherence and Coupling Requirements
    // ============================================================
    
    func testInsufficientCoherencePreventsEnergyShellFormation() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 100.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1,
            coherence: controller.minimumShellCoherence - 0.001,
            coupling: 1.0
        )
        
        XCTAssertTrue(
            controller.isFrequencyLocked,
            "Frequency should lock; this test isolates coherence."
        )
        
        XCTAssertFalse(
            controller.isEnergyShellActive,
            "The shell must not form below the coherence requirement."
        )
    }
    
    func testCoherenceAtMinimumThresholdAllowsEnergyShellFormation() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 100.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1,
            coherence: controller.minimumShellCoherence,
            coupling: 1.0
        )
        
        XCTAssertTrue(
            controller.isEnergyShellActive,
            "Coherence exactly at its minimum threshold should allow shell formation."
        )
    }
    
    func testInsufficientCouplingPreventsEnergyShellFormation() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 100.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1,
            coherence: 1.0,
            coupling: controller.minimumShellCoupling - 0.001
        )
        
        XCTAssertTrue(
            controller.isFrequencyLocked,
            "Frequency should lock; this test isolates coupling."
        )
        
        XCTAssertFalse(
            controller.isEnergyShellActive,
            "The shell must not form below the coupling requirement."
        )
    }
    
    func testCouplingAtMinimumThresholdAllowsEnergyShellFormation() {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 100.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1,
            coherence: 1.0,
            coupling: controller.minimumShellCoupling
        )
        
        XCTAssertTrue(
            controller.isEnergyShellActive,
            "Coupling exactly at its minimum threshold should allow shell formation."
        )
    }
    
    // ============================================================
    // MARK: - Shell Node Behavior
    // ============================================================
    
    func testActiveShellCreatesVisibleRenderableNode() throws {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 100.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1
        )
        
        let shellNode = try XCTUnwrap(
            controller.energyShellNode,
            "An active energy shell must create a SceneKit node."
        )
        
        XCTAssertEqual(
            shellNode.name,
            "QRTLEnergyShell",
            "The shell node should have a stable identifier."
        )
        
        XCTAssertFalse(
            shellNode.isHidden,
            "An active shell node must be visible."
        )
        
        XCTAssertGreaterThan(
            shellNode.opacity,
            0.0,
            "An active shell must have visible opacity."
        )
        
        XCTAssertNotNil(
            shellNode.geometry,
            "An energy shell must have renderable geometry."
        )
        
        XCTAssertTrue(
            shellNode.geometry is SCNSphere,
            "The shell should use spherical SceneKit geometry."
        )
    }
    
  
    func testShellHidesWhenARequirementStopsBeingMet() throws {
        
        let controller = QRTLSceneController()
        
        configure(
            controller,
            current: 1.0,
            driveFrequencyHz: 100.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1
        )
        
        let shellNode = try XCTUnwrap(
            controller.energyShellNode,
            "The test requires a shell to exist before disabling it."
        )
        
        XCTAssertFalse(
            shellNode.isHidden
        )
        
        XCTAssertTrue(
            controller.isEnergyShellActive
        )
        
        configure(
            controller,
            current: 0.099,
            driveFrequencyHz: 100.0,
            resonanceFrequencyHz: 100.0,
            maximumDetuningHz: 1.0,
            minimumShellCurrent: 0.1
        )
        
        XCTAssertFalse(
            controller.isEnergyShellActive,
            "Dropping below the current threshold must deactivate the shell."
        )
        
        XCTAssertTrue(
            shellNode.isHidden,
            "A previously created shell node must hide after deactivation."
        )
    }
    
}
