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

    case initialization
    case lattice
    case proton
    case neutron
    case nucleus
    case energyShell
    case current
    case atom
    case alignment
    case bond
    case carbonSkeleton
    case glucose
    case glucoseStabilization
    case glucosePair
    case strandBond
    case strandGrowth
    case finalLock

    var id: Int {
        rawValue
    }

    var title: String {

        switch self {

        case .initialization:
            return "QRTL FIELD INITIALIZATION"

        case .lattice:
            return "QRTL LATTICE FORMATION"

        case .proton:
            return "PROTON FORMATION"

        case .neutron:
            return "NEUTRON FORMATION"

        case .nucleus:
            return "NUCLEAR ASSEMBLY"

        case .energyShell:
            return "ENERGY SHELL FORMATION"

        case .current:
            return "CURRENT → QRTL ENERGY"

        case .atom:
            return "ATOM ASSEMBLY"

        case .alignment:
            return "MOLECULAR ALIGNMENT"

        case .bond:
            return "BOND STABILIZATION"

        case .carbonSkeleton:
            return "CARBON SKELETON"

        case .glucose:
            return "GLUCOSE FORMATION"

        case .glucoseStabilization:
            return "GLUCOSE ENERGY STABILIZATION"

        case .glucosePair:
            return "GLUCOSE–GLUCOSE ALIGNMENT"

        case .strandBond:
            return "GLUCOSE BOND"

        case .strandGrowth:
            return "STRAND GROWTH"

        case .finalLock:
            return "FINAL QRTL ENERGY LOCK"
        }
    }

    var explanation: String {

        switch self {

        case .initialization:
            return "The QRTL field is initialized and the modeled environment is prepared."

        case .lattice:
            return "A spatial lattice is established to provide the modeled environment."

        case .proton:
            return "Proton components are introduced into the modeled nuclear structure."

        case .neutron:
            return "Neutron components are introduced to provide the modeled nuclear structure."

        case .nucleus:
            return "Protons and neutrons are assembled into the central nuclear structure."

        case .energyShell:
            return "A concentrated QRTL energy shell is established around the nucleus."

        case .current:
            return "Incoming current supplies modeled energy to the QRTL system."

        case .atom:
            return "The nucleus is combined with an electron structure to create the modeled atom."

        case .alignment:
            return "Molecular components are guided toward an ordered configuration."

        case .bond:
            return "The modeled interaction helps hold the molecular components together."

        case .carbonSkeleton:
            return "Carbon components begin forming the backbone of the molecular structure."

        case .glucose:
            return "The modeled carbon, oxygen, and hydrogen components are assembled into a glucose-like structure."

        case .glucoseStabilization:
            return "The molecular structure is moved toward a more stable modeled energy configuration."

        case .glucosePair:
            return "A second glucose unit is positioned near the first unit."

        case .strandBond:
            return "The two molecular units are brought into a connected configuration."

        case .strandGrowth:
            return "Additional molecular units are added to extend the strand."

        case .finalLock:
            return "The simulation reaches its final modeled QRTL energy configuration."
        }
    }

    // --------------------------------------------------------
    // MARK: - Simple Analogy
    // --------------------------------------------------------

    var analogy: String {

        switch self {

        case .initialization:
            return "Like turning on the power grid before starting a construction project."

        case .lattice:
            return "Like putting the scaffolding in place before building the structure."

        case .proton:
            return "Like placing the first major building blocks on the foundation."

        case .neutron:
            return "Like adding stabilizing blocks around the first pieces."

        case .nucleus:
            return "Like assembling the central engine of a machine."

        case .energyShell:
            return "Like creating an invisible energy bubble around that engine."

        case .current:
            return "Like opening a fuel line and feeding energy into the chamber."

        case .atom:
            return "Like adding the moving parts around the central engine."

        case .alignment:
            return "Like magnets turning until their directions line up."

        case .bond:
            return "Like adding connectors that keep the pieces together."

        case .carbonSkeleton:
            return "Like building the frame of a house before adding the walls."

        case .glucose:
            return "Like assembling all of the rooms and components into one structure."

        case .glucoseStabilization:
            return "Like letting a newly assembled machine settle into its smoothest operating state."

        case .glucosePair:
            return "Like placing two completed modules next to each other."

        case .strandBond:
            return "Like snapping two modules together with a connector."

        case .strandGrowth:
            return "Like extending a train by attaching more cars."

        case .finalLock:
            return "Like locking the completed structure into its final position."
        }
    }
}

