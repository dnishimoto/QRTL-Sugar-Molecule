//
//  File.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/9/26.
//

import Foundation
import SwiftUI
import SceneKit


final class QRTLPhysicsModel {

    var parameters: QRTLParameters

    init(
        parameters: QRTLParameters = QRTLParameters()
    ) {

        self.parameters = parameters
    }

    // --------------------------------------------------------
    // QRTL potential
    // --------------------------------------------------------

    func qrtlPotential(
        distance r: Double
    ) -> Double {

        let rs =
            parameters.shellRadius

        let sigma =
            max(
                parameters.shellWidth,
                0.001
            )

        let exponent =
            -pow(
                r - rs,
                2.0
            ) /
            (
                2.0 *
                sigma *
                sigma
            )

        return
            -parameters.shellEnergy *
            exp(exponent) *
            parameters.shellCoupling
    }

    // --------------------------------------------------------
    // QRTL force
    // --------------------------------------------------------

    func qrtlForce(
        distance r: Double
    ) -> Double {

        let rs =
            parameters.shellRadius

        let sigma =
            max(
                parameters.shellWidth,
                0.001
            )

        let potential =
            qrtlPotential(
                distance: r
            )

        let derivative =
            potential *
            (
                -(r - rs) /
                (
                    sigma *
                    sigma
                )
            )

        return
            -derivative *
            parameters.qrtlForceStrength
    }

    // --------------------------------------------------------
    // Current converted to effective modeled input
    // --------------------------------------------------------

    func currentPower() -> Double {

        return
            parameters.current *
            parameters.currentEfficiency
    }

    // --------------------------------------------------------
    // QRTL pressure index
    //
    // This is a normalized model index.
    // It is NOT pressure in Pascals.
    // --------------------------------------------------------

    func qrtlPressureIndex() -> Double {

        let radius =
            max(
                parameters.shellRadius,
                0.001
            )

        let width =
            max(
                parameters.shellWidth,
                0.001
            )

        let innerRadius =
            max(
                radius - width / 2.0,
                0.001
            )

        let outerRadius =
            radius +
            width / 2.0

        let volume =
            (
                4.0 / 3.0
            ) *
            Double.pi *
            (
                pow(
                    outerRadius,
                    3.0
                ) -
                pow(
                    innerRadius,
                    3.0
                )
            )

        return
            parameters.shellEnergy /
            max(
                volume,
                0.001
            )
    }

    // --------------------------------------------------------
    // Reaction energy index
    //
    // Normalized model quantity.
    // Not measured joules.
    // --------------------------------------------------------

    func reactionEnergyIndex() -> Double {

        return
            parameters.shellEnergy *
            parameters.shellCoupling *
            parameters.shellCoherence
    }

    // --------------------------------------------------------
    // Energy derivative
    // --------------------------------------------------------

    func shellEnergyDerivative() -> Double {

        let input =
            currentPower()

        let loss =
            parameters.energyLoss *
            parameters.shellEnergy

        let coupling =
            parameters.shellCoupling *
            parameters.shellEnergy *
            0.05

        return
            input -
            loss -
            coupling
    }

    // --------------------------------------------------------
    // Conceptual net force magnitude
    // --------------------------------------------------------

    func netForceMagnitude(
        distance: Double
    ) -> Double {

        let qrtl =
            abs(
                qrtlForce(
                    distance: distance
                )
            )

        return
            qrtl +
            parameters.externalForce +
            parameters.kineticForce +
            parameters.bondStrength
    }

    // --------------------------------------------------------
    // External force vector
    // --------------------------------------------------------

    func externalForceVector()
        -> SCNVector3 {

        return SCNVector3(
            0,
            Float(
                parameters.externalForce
            ),
            0
        )
    }

    // --------------------------------------------------------
    // Kinetic force vector
    // --------------------------------------------------------

    func kineticForceVector()
        -> SCNVector3 {

        return SCNVector3(
            Float(
                parameters.kineticForce
            ),
            0,
            0
        )
    }
}
