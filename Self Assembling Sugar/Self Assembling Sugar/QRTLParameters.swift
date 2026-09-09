//
//  File.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/9/26.
//

import Foundation

// ============================================================
// MARK: - QRTL PARAMETERS
// ============================================================

struct QRTLParameters {

    // Energy shell
    var shellEnergy: Double = 0.75
    var shellRadius: Double = 1.65
    var shellWidth: Double = 0.42

    // Shell interaction
    var shellCoupling: Double = 0.80
    var shellCoherence: Double = 0.90

    // Energy accounting
    var energyLoss: Double = 0.08

    // Electrical input
    var current: Double = 0.50
    var currentEfficiency: Double = 0.70

    // External forces
    var externalForce: Double = 0.40
    var kineticForce: Double = 0.35

    // QRTL force
    var qrtlForceStrength: Double = 1.00

    // Bonding
    var bondStrength: Double = 0.70

    // Model controls
    var replaceStrongForce: Bool = true
    var animationSpeed: Double = 1.0
}

