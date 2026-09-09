//
//  DataStructures.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/9/26.
//

import Foundation

// ============================================================
// MARK: - QRTL PHASE
// ============================================================

enum QRTLPhase: Int, CaseIterable, Identifiable {

    // ========================================================
    // MARK: QRTL Formation Pipeline
    // ========================================================

    case spaceEnvironment = 0
    case sourceCollection = 1
    case molecularSource = 2
    case hydrogenOxygenExcitation = 3
    case antisymmetricExcitation = 4
    case energyInjection = 5
    case qrtlLattice = 6
    case resonanceLock = 7
    case atomicCapture = 8

    // ========================================================
    // MARK: Molecular Assembly
    // ========================================================

    case carbonPositioning = 9
    case hydrogenPositioning = 10
    case oxygenPositioning = 11
    case bondAlignment = 12
    case ringClosure = 13
    case glucoseAssembly = 14
    case molecularStabilization = 15
    case finalSugar = 16

    // ========================================================
    // MARK: Identifiable
    // ========================================================

    var id: Int {
        rawValue
    }

    // ========================================================
    // MARK: Title
    // ========================================================

    var title: String {

        switch self {

        case .spaceEnvironment:
            return "SPACE ENVIRONMENT"

        case .sourceCollection:
            return "SOURCE MATERIAL COLLECTION"

        case .molecularSource:
            return "MOLECULAR SOURCE"

        case .hydrogenOxygenExcitation:
            return "HYDROGEN–OXYGEN EXCITATION"

        case .antisymmetricExcitation:
            return "ANTISYMMETRIC EXCITATION"

        case .energyInjection:
            return "ENERGY INJECTION"

        case .qrtlLattice:
            return "QRTL LATTICE FORMATION"

        case .resonanceLock:
            return "QRTL RESONANCE LOCK"

        case .atomicCapture:
            return "ATOMIC CAPTURE"

        case .carbonPositioning:
            return "CARBON POSITIONING"

        case .hydrogenPositioning:
            return "HYDROGEN POSITIONING"

        case .oxygenPositioning:
            return "OXYGEN POSITIONING"

        case .bondAlignment:
            return "BOND ALIGNMENT"

        case .ringClosure:
            return "RING CLOSURE"

        case .glucoseAssembly:
            return "C₆H₁₂O₆ ASSEMBLY"

        case .molecularStabilization:
            return "MOLECULAR STABILIZATION"

        case .finalSugar:
            return "FINAL SUGAR"
        }
    }

    // ========================================================
    // MARK: Explanation
    // ========================================================

    var explanation: String {

        switch self {

        case .spaceEnvironment:
            return "The modeled space environment is established as the starting condition for the QRTL simulation."

        case .sourceCollection:
            return "Modeled source material is collected from the surrounding environment and directed toward the assembly region."

        case .molecularSource:
            return "The collected material is represented as a molecular source for the subsequent excitation and assembly stages."

        case .hydrogenOxygenExcitation:
            return "Hydrogen and oxygen components are subjected to the modeled excitation process."

        case .antisymmetricExcitation:
            return "The excitation state is driven into the modeled antisymmetric configuration."

        case .energyInjection:
            return "External energy is injected into the modeled system to increase the available excitation and coupling."

        case .qrtlLattice:
            return "A QRTL lattice is established as the modeled resonating spatial structure."

        case .resonanceLock:
            return "The modeled system approaches a coherent resonance condition in which the interacting components are more strongly coupled."

        case .atomicCapture:
            return "Atomic components are captured and positioned within the modeled QRTL interaction region."

        case .carbonPositioning:
            return "Carbon atoms are progressively positioned to establish the six-carbon molecular framework."

        case .hydrogenPositioning:
            return "Hydrogen atoms are progressively positioned around the developing molecular framework."

        case .oxygenPositioning:
            return "Oxygen atoms are progressively positioned at their modeled molecular sites."

        case .bondAlignment:
            return "The molecular components are moved toward their intended bond geometry."

        case .ringClosure:
            return "The molecular chain is progressively closed into the modeled ring configuration."

        case .glucoseAssembly:
            return "The carbon, hydrogen, and oxygen components are assembled into the modeled C₆H₁₂O₆ glucose-like structure."

        case .molecularStabilization:
            return "The assembled molecular structure is moved toward its modeled stable configuration."

        case .finalSugar:
            return "The simulation reaches the final modeled sugar configuration."
        }
    }

    // ========================================================
    // MARK: Analogy
    // ========================================================

    var analogy: String {

        switch self {

        case .spaceEnvironment:
            return "Like preparing the construction site before bringing in the materials."

        case .sourceCollection:
            return "Like gathering all of the raw materials needed for a construction project."

        case .molecularSource:
            return "Like sorting those materials into the specific parts needed to build the structure."

        case .hydrogenOxygenExcitation:
            return "Like energizing the parts so they are ready to move and interact."

        case .antisymmetricExcitation:
            return "Like putting two coordinated systems into a special rhythm that allows them to interact."

        case .energyInjection:
            return "Like supplying additional power to the machinery doing the construction."

        case .qrtlLattice:
            return "Like putting a precision framework or scaffold around the construction area."

        case .resonanceLock:
            return "Like tuning every instrument in an orchestra to the same coordinated rhythm."

        case .atomicCapture:
            return "Like catching each building component and placing it onto its assigned position."

        case .carbonPositioning:
            return "Like building the main frame of a house."

        case .hydrogenPositioning:
            return "Like attaching the smaller supporting pieces around the frame."

        case .oxygenPositioning:
            return "Like installing specialized components at specific locations in the structure."

        case .bondAlignment:
            return "Like rotating every connector until all of the pieces line up."

        case .ringClosure:
            return "Like connecting the final section of a circular track."

        case .glucoseAssembly:
            return "Like completing the entire building from its individual components."

        case .molecularStabilization:
            return "Like tightening every connection and allowing the completed structure to settle."

        case .finalSugar:
            return "Like locking the finished construction into its final configuration."
        }
    }
}
