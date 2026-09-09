//
//  Self_Assembling_SugarTests.swift
//  Self Assembling SugarTests
//
//  Created by David Nishimoto on 9/6/26.
//

import Testing
import XCTest
@testable import Self_Assembling_Sugar



final class QRTLSceneControllerTests: XCTestCase {

    private let tolerance = 0.000001

    private func assertEqual(
        _ actual: Double,
        _ expected: Double,
        _ message: String
    ) {
        XCTAssertEqual(
            actual,
            expected,
            accuracy: tolerance,
            message
        )
    }

    private func verifyStep(
        controller: QRTLSceneController,
        step: Int,
        current: Double,
        efficiency: Double,
        shellEnergy: Double,
        coupling: Double,
        coherence: Double,
        energyLoss: Double
    ) {

        controller.goToStep(step)

        XCTAssertEqual(
            controller.phase.rawValue,
            step
        )

        XCTAssertEqual(
            controller.phaseProgress,
            step
        )

        // ----------------------------------------------------
        // Verify input parameters
        // ----------------------------------------------------

        assertEqual(
            controller.current,
            current,
            "Step \(step + 1): current"
        )

        assertEqual(
            controller.currentEfficiency,
            efficiency,
            "Step \(step + 1): current efficiency"
        )

        assertEqual(
            controller.shellEnergy,
            shellEnergy,
            "Step \(step + 1): shell energy"
        )

        assertEqual(
            controller.shellCoupling,
            coupling,
            "Step \(step + 1): shell coupling"
        )

        assertEqual(
            controller.shellCoherence,
            coherence,
            "Step \(step + 1): shell coherence"
        )

        assertEqual(
            controller.energyLoss,
            energyLoss,
            "Step \(step + 1): energy loss"
        )

        // ----------------------------------------------------
        // Independent equation calculations
        // ----------------------------------------------------

        let expectedEffectiveInput =
            current * efficiency

        let expectedPressure =
            shellEnergy *
            coupling *
            coherence

        let expectedReactionEnergy =
            expectedEffectiveInput *
            (1.0 - energyLoss)

        let expectedForce =
            expectedPressure *
            max(controller.bondForce, 0.001)

        // ----------------------------------------------------
        // Verify controller calculations
        // ----------------------------------------------------

        assertEqual(
            controller.effectiveInput,
            expectedEffectiveInput,
            "Step \(step + 1): effective input equation"
        )

        assertEqual(
            controller.qrtlPressure,
            expectedPressure,
            "Step \(step + 1): pressure equation"
        )

        assertEqual(
            controller.reactionEnergy,
            expectedReactionEnergy,
            "Step \(step + 1): reaction energy equation"
        )

        assertEqual(
            controller.qrtlForce,
            expectedForce,
            "Step \(step + 1): QRTL force equation"
        )
    }


    // ========================================================
    // STEP 1
    // ========================================================

    func testStep01_SpaceEnvironment() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 0,
            current: 0.05,
            efficiency: 0.25,
            shellEnergy: 0.10,
            coupling: 0.20,
            coherence: 0.20,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 2
    // ========================================================

    func testStep02_SourceCollection() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 1,
            current: 0.15,
            efficiency: 0.35,
            shellEnergy: 0.20,
            coupling: 0.30,
            coherence: 0.30,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 3
    // ========================================================

    func testStep03_MolecularSource() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 2,
            current: 0.20,
            efficiency: 0.40,
            shellEnergy: 0.30,
            coupling: 0.35,
            coherence: 0.40,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 4
    // ========================================================

    func testStep04_HydrogenOxygenExcitation() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 3,
            current: 0.25,
            efficiency: 0.45,
            shellEnergy: 0.40,
            coupling: 0.45,
            coherence: 0.50,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 5
    // ========================================================

    func testStep05_AntisymmetricExcitation() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 4,
            current: 0.28,
            efficiency: 0.48,
            shellEnergy: 0.45,
            coupling: 0.50,
            coherence: 0.55,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 6
    // ========================================================

    func testStep06_EnergyInjection() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 5,
            current: 0.40,
            efficiency: 0.55,
            shellEnergy: 0.60,
            coupling: 0.65,
            coherence: 0.65,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 7
    // ========================================================

    func testStep07_QRTLLattice() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 6,
            current: 0.45,
            efficiency: 0.60,
            shellEnergy: 0.70,
            coupling: 0.75,
            coherence: 0.75,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 8
    // ========================================================

    func testStep08_ResonanceLock() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 7,
            current: 0.50,
            efficiency: 0.65,
            shellEnergy: 0.78,
            coupling: 0.82,
            coherence: 0.85,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 9
    // ========================================================

    func testStep09_AtomicCapture() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 8,
            current: 0.45,
            efficiency: 0.65,
            shellEnergy: 0.80,
            coupling: 0.84,
            coherence: 0.86,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 10
    // ========================================================

    func testStep10_CarbonPositioning() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 9,
            current: 0.42,
            efficiency: 0.66,
            shellEnergy: 0.82,
            coupling: 0.85,
            coherence: 0.88,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 11
    // ========================================================

    func testStep11_HydrogenPositioning() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 10,
            current: 0.38,
            efficiency: 0.67,
            shellEnergy: 0.83,
            coupling: 0.86,
            coherence: 0.89,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 12
    // ========================================================

    func testStep12_OxygenPositioning() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 11,
            current: 0.35,
            efficiency: 0.68,
            shellEnergy: 0.84,
            coupling: 0.87,
            coherence: 0.90,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 13
    // ========================================================

    func testStep13_BondAlignment() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 12,
            current: 0.40,
            efficiency: 0.70,
            shellEnergy: 0.87,
            coupling: 0.90,
            coherence: 0.92,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 14
    // ========================================================

    func testStep14_RingClosure() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 13,
            current: 0.35,
            efficiency: 0.70,
            shellEnergy: 0.88,
            coupling: 0.91,
            coherence: 0.93,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 15
    // ========================================================

    func testStep15_GlucoseAssembly() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 14,
            current: 0.30,
            efficiency: 0.70,
            shellEnergy: 0.90,
            coupling: 0.92,
            coherence: 0.94,
            energyLoss: 0.10
        )
    }


    // ========================================================
    // STEP 16
    // ========================================================

    func testStep16_MolecularStabilization() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 15,
            current: 0.08,
            efficiency: 0.72,
            shellEnergy: 0.94,
            coupling: 0.94,
            coherence: 0.97,
            energyLoss: 0.04
        )
    }


    // ========================================================
    // STEP 17
    // ========================================================

    func testStep17_FinalSugar() {

        let controller = QRTLSceneController()

        verifyStep(
            controller: controller,
            step: 16,
            current: 0.02,
            efficiency: 0.75,
            shellEnergy: 1.00,
            coupling: 0.98,
            coherence: 0.99,
            energyLoss: 0.02
        )
    }
}
