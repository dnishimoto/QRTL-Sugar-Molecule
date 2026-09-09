//
//  AboutView.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/9/26.
//

import SwiftUI

struct AboutView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: AboutSection = .overview

    @ScaledMetric(relativeTo: .body)
    private var cardCornerRadius: CGFloat = 20

    enum AboutSection: String, CaseIterable, Identifiable {
        case overview = "Overview"
        case pipeline = "Pipeline"
        case cascade = "Frequency Cascade"
        case analogy = "Musical Analogy"
        case chemistry = "Chemical Bridge"
        case science = "Scientific Boundary"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .overview:
                return "sparkles"
            case .pipeline:
                return "point.3.connected.trianglepath.dotted"
            case .cascade:
                return "waveform.path.ecg"
            case .analogy:
                return "music.note.list"
            case .chemistry:
                return "atom"
            case .science:
                return "checkmark.seal"
            }
        }

        var shortTitle: String {
            switch self {
            case .overview:
                return "Overview"
            case .pipeline:
                return "Pipeline"
            case .cascade:
                return "Cascade"
            case .analogy:
                return "Analogy"
            case .chemistry:
                return "Chemistry"
            case .science:
                return "Boundary"
            }
        }
    }

    struct PipelineStage: Identifiable {
        let id: Int
        let title: String
        let subtitle: String
        let icon: String
        let explanation: String
        let importance: String
    }

    private let stages: [PipelineStage] = [
        PipelineStage(
            id: 1,
            title: "Space Environment",
            subtitle: "The starting physical environment",
            icon: "sparkles",
            explanation:
                "The simulation begins with an interstellar environment containing plasma, charged particles, electromagnetic fields, radiation, temperature, and available molecular material. These conditions establish the initial energy and frequency environment.",
            importance:
                "This stage defines what physical resources are available before the proposed molecular assembly process begins."
        ),

        PipelineStage(
            id: 2,
            title: "Source-Material Collection",
            subtitle: "Gathering the molecular ingredients",
            icon: "shippingbox",
            explanation:
                "The model identifies carbon, hydrogen, and oxygen together with molecules such as water, carbon monoxide, carbon dioxide, methanol, and formaldehyde. Icy dust grains can provide surfaces where molecules become concentrated and brought into proximity.",
            importance:
                "The ingredients must exist and become available to the reaction environment before increasingly complex chemistry can occur."
        ),

        PipelineStage(
            id: 3,
            title: "Molecular Source Environment",
            subtitle: "Creating opportunities for interaction",
            icon: "circle.grid.3x3",
            explanation:
                "Collected materials enter an environment where molecules can collide, attach, react, and exchange energy. Water and simple carbon-containing molecules provide important starting materials for the proposed chemical pathway.",
            importance:
                "Molecular availability is different from molecular interaction. The model must determine whether the ingredients can actually encounter one another."
        ),

        PipelineStage(
            id: 4,
            title: "Hydrogen–Oxygen Excitation",
            subtitle: "Interacting with molecular modes",
            icon: "waveform",
            explanation:
                "The simulation examines whether available electromagnetic frequencies can interact with molecular modes involving hydrogen and oxygen. Experimentally known molecular frequencies provide reference points for determining whether an interaction is spectroscopically plausible.",
            importance:
                "This stage connects the external electromagnetic environment with measurable molecular behavior."
        ),

        PipelineStage(
            id: 5,
            title: "Antisymmetric Molecular Excitation",
            subtitle: "Exploring additional vibrational modes",
            icon: "waveform.path",
            explanation:
                "The model examines additional molecular vibrational modes, including asymmetric motions of atoms within molecules. Frequency matching, bandwidth, energy, phase, and coupling determine the modeled interaction strength.",
            importance:
                "A frequency being present is not enough. The model must determine whether it actually couples to a relevant molecular mode."
        ),

        PipelineStage(
            id: 6,
            title: "Energy Injection",
            subtitle: "Supplying the energy",
            icon: "bolt.fill",
            explanation:
                "Energy enters the active region from an explicitly defined external source. The simulation tracks this energy rather than allowing resonance to create energy.",
            importance:
                "Resonance can organize or transfer energy, but it is not an independent source of energy. The energy budget must remain accounted for."
        ),

        PipelineStage(
            id: 7,
            title: "QRTL Lattice Formation",
            subtitle: "Establishing the proposed resonant architecture",
            icon: "hexagon",
            explanation:
                "The proposed Quark Twister Resonating Lattice is introduced as an organized resonant environment. The model assigns a degree of lattice order or coherence describing how organized the modeled energy configuration has become.",
            importance:
                "This is where the proposed QRTL mechanism enters the pipeline."
        ),

        PipelineStage(
            id: 8,
            title: "QRTL Resonance Locking",
            subtitle: "Maintaining compatible resonance",
            icon: "lock.rotation",
            explanation:
                "The system searches for compatible resonant conditions. Frequency and phase are evaluated to determine whether incoming energy can remain coupled to the proposed QRTL resonant structure.",
            importance:
                "Stable resonance requires compatible frequency and phase relationships rather than simply applying energy at an arbitrary frequency."
        ),

        PipelineStage(
            id: 9,
            title: "Atomic Capture",
            subtitle: "Concentrating the building blocks",
            icon: "dot.scope",
            explanation:
                "Carbon-, hydrogen-, and oxygen-containing species become concentrated within the modeled interaction region. Capture represents localization and interaction opportunity rather than automatic chemical bonding.",
            importance:
                "The atoms or molecular fragments must be available in the correct region before their positions can be organized."
        ),

        PipelineStage(
            id: 10,
            title: "Carbon Positioning",
            subtitle: "Building the molecular framework",
            icon: "circle.hexagongrid.fill",
            explanation:
                "Carbon atoms or carbon-containing molecular fragments are organized into positions compatible with the desired molecular architecture.",
            importance:
                "Carbon provides the backbone of many organic structures, including carbohydrates. Correct molecular geometry matters more than simply reaching a carbon count."
        ),

        PipelineStage(
            id: 11,
            title: "Hydrogen Positioning",
            subtitle: "Completing hydrogen relationships",
            icon: "circle.fill",
            explanation:
                "Hydrogen atoms are positioned relative to the developing carbon and oxygen framework. Their locations influence molecular geometry, bonding, and the eventual hydrogen count.",
            importance:
                "Hydrogen placement is coupled to the surrounding molecular structure."
        ),

        PipelineStage(
            id: 12,
            title: "Oxygen Positioning",
            subtitle: "Organizing oxygen-containing groups",
            icon: "circle.hexagonpath",
            explanation:
                "Oxygen atoms and oxygen-containing groups are organized within the developing molecular structure.",
            importance:
                "Oxygen positioning must remain coupled to carbon and hydrogen positioning because molecular geometry is an interconnected system."
        ),

        PipelineStage(
            id: 13,
            title: "Bond Alignment",
            subtitle: "Testing chemically meaningful geometry",
            icon: "link",
            explanation:
                "The interacting atoms are evaluated for chemically meaningful bonding arrangements. Electromagnetic excitation alone does not establish that a chemical bond will form.",
            importance:
                "This stage connects energetic excitation to actual chemical structure."
        ),

        PipelineStage(
            id: 14,
            title: "Molecular Ring Closure",
            subtitle: "Creating the target molecular geometry",
            icon: "arrow.triangle.merge",
            explanation:
                "The developing molecular structure undergoes the modeled rearrangement necessary to produce a ring configuration. Geometry, connectivity, energy, and stability are evaluated.",
            importance:
                "Ring formation requires a specific molecular arrangement and cannot be reduced to simply supplying more energy."
        ),

        PipelineStage(
            id: 15,
            title: "C₆H₁₂O₆ Assembly",
            subtitle: "Reaching the target composition",
            icon: "hexagon.fill",
            explanation:
                "The model attempts to reach a molecular composition containing six carbon atoms, twelve hydrogen atoms, and six oxygen atoms.",
            importance:
                "C₆H₁₂O₆ is a molecular formula, not a complete molecular identity. The simulation must evaluate structure and connectivity before classifying the result as glucose-like."
        ),

        PipelineStage(
            id: 16,
            title: "Molecular Stabilization",
            subtitle: "Determining whether the structure survives",
            icon: "shield.checkered",
            explanation:
                "The resulting molecular configuration is evaluated for stability. The simulation determines whether the structure remains intact under the modeled conditions or dissociates into other configurations.",
            importance:
                "A transient structure is not equivalent to a stable molecular product."
        ),

        PipelineStage(
            id: 17,
            title: "Final Sugar State",
            subtitle: "Evaluating the complete result",
            icon: "checkmark.seal.fill",
            explanation:
                "The final stage evaluates whether a glucose-like molecular structure has been produced according to the model's criteria.",
            importance:
                "The simulation can report predicted abundance, formation rate, energy expenditure, stability, molecular structure, and spectroscopic signatures."
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        headerCard
                        sectionPicker

                        Group {
                            switch selectedSection {
                            case .overview:
                                overviewContent
                            case .pipeline:
                                pipelineContent
                            case .cascade:
                                cascadeContent
                            case .analogy:
                                analogyContent
                            case .chemistry:
                                chemistryContent
                            case .science:
                                scienceContent
                            }
                        }
                        .id(selectedSection)

                        Spacer(minLength: 28)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "xmark")
                    }
                    .accessibilityLabel("Close About Space Sugar")
                }
            }
        }
        .tint(AppTheme.accent)
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [
                AppTheme.backgroundTop,
                AppTheme.backgroundBottom
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.16))
                        .frame(width: 58, height: 58)

                    Image(systemName: "atom")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("SPACE SUGAR")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("QRTL Frequency-Cascade Self-Assembly")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.82))
                }

                Spacer(minLength: 0)
            }

            Text(
                "A computational concept model exploring the relationship between environmental energy, resonance, molecular interaction, and the emergence of increasingly complex organic structures."
            )
            .font(.body)
            .foregroundStyle(.white.opacity(0.94))
            .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Image(systemName: "flask.fill")

                Text("PROPOSED COMPUTATIONAL MODEL")
                    .tracking(0.9)
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(.white.opacity(0.16), in: Capsule())
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.heroStart,
                    AppTheme.heroEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
        )
        .shadow(
            color: AppTheme.heroStart.opacity(0.28),
            radius: 16,
            x: 0,
            y: 8
        )
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach(AboutSection.allCases) { section in
                    Button {
                        withAnimation(.snappy(duration: 0.28)) {
                            selectedSection = section
                        }
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: section.icon)
                                .font(.caption.weight(.semibold))

                            Text(section.shortTitle)
                                .lineLimit(1)
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(
                            selectedSection == section
                                ? Color.white
                                : Color.primary
                        )
                        .padding(.horizontal, 13)
                        .padding(.vertical, 10)
                        .background {
                            Capsule()
                                .fill(
                                    selectedSection == section
                                        ? AppTheme.accent
                                        : Color(uiColor: .secondarySystemBackground)
                                )
                        }
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    selectedSection == section
                                        ? Color.clear
                                        : Color.primary.opacity(0.07),
                                    lineWidth: 1
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(section.rawValue)
                    .accessibilityAddTraits(
                        selectedSection == section ? .isSelected : []
                    )
                }
            }
            .padding(.horizontal, 1)
            .padding(.vertical, 2)
        }
    }

    // MARK: - Overview

    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                "What Is Space Sugar?",
                subtitle: "A transparent pathway from environment to molecular result.",
                icon: "sparkles"
            )

            informationCard(
                title: "The Big Idea",
                icon: "lightbulb.fill",
                text:
                    "Space Sugar models a proposed pathway in which an external environment supplies energy and molecular building blocks, while resonance and a proposed QRTL lattice are used as organizing mechanisms. The simulation follows the system from simple materials toward increasingly complex molecular structures."
            )

            informationCard(
                title: "Why a Frequency Cascade?",
                icon: "waveform.path.ecg",
                text:
                    "The model does not assume that every required frequency is available at the beginning. Each stage evaluates the spectrum produced by the previous stage and determines whether frequencies can be selected, coupled, transformed, or transferred into the next interaction."
            )

            informationCard(
                title: "The Central Principle",
                icon: "arrow.right.circle.fill",
                text:
                    "Space provides the environment and energy. Molecules provide the building blocks. Resonance provides frequency selectivity. The proposed QRTL lattice provides an organizing framework. Chemistry determines whether the desired molecular structure can actually form."
            )

            informationCard(
                title: "From Physics to Chemistry",
                icon: "atom",
                text:
                    "The pipeline connects multiple scales: space plasma, electromagnetic fields, frequency behavior, molecular spectroscopy, atomic organization, chemical bonding, molecular geometry, and molecular stability."
            )

            hypothesisNotice
        }
    }

    private var hypothesisNotice: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title3)
                .foregroundStyle(AppTheme.accent)

            VStack(alignment: .leading, spacing: 5) {
                Text("Model Scope")
                    .font(.subheadline.weight(.bold))

                Text(
                    "QRTL and its proposed assembly mechanism are hypotheses represented in this simulation. Physical validation requires mathematical constraints, measured inputs, and experimental evidence."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(15)
        .background(AppTheme.accent.opacity(0.09), in: roundedShape)
        .overlay {
            roundedShape
                .strokeBorder(AppTheme.accent.opacity(0.16), lineWidth: 1)
        }
    }

    // MARK: - Pipeline

    private var pipelineContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                "17-Stage Pipeline",
                subtitle: "Each stage produces inputs and constraints for the next.",
                icon: "point.3.connected.trianglepath.dotted"
            )

            pipelineSummary

            LazyVStack(spacing: 12) {
                ForEach(stages) { stage in
                    pipelineCard(stage)
                }
            }
        }
    }

    private var pipelineSummary: some View {
        HStack(spacing: 14) {
            summaryMetric(
                value: "17",
                label: "Stages",
                icon: "list.number"
            )

            Divider()
                .frame(height: 40)

            summaryMetric(
                value: "C₆H₁₂O₆",
                label: "Target Formula",
                icon: "hexagon.fill"
            )

            Divider()
                .frame(height: 40)

            summaryMetric(
                value: "QRTL",
                label: "Hypothesis",
                icon: "waveform"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.regularMaterial, in: roundedShape)
        .overlay {
            roundedShape
                .strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
        }
    }

    private func summaryMetric(
        value: String,
        label: String,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.accent)

            Text(value)
                .font(.subheadline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Frequency Cascade

    private var cascadeContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                "Frequency Cascade",
                subtitle: "A model of energy selection, transfer, and molecular response.",
                icon: "waveform.path.ecg"
            )

            informationCard(
                title: "Not a Fixed Frequency List",
                icon: "arrow.triangle.branch",
                text:
                    "The cascade treats frequency as a changing property of the system. A frequency should not simply appear because a later stage needs it. The model must determine whether it is already present or whether a recognized interaction could generate it."
            )

            informationCard(
                title: "Incoming Spectrum",
                icon: "chart.xyaxis.line",
                text:
                    "The space environment can contain many electromagnetic frequencies simultaneously. The model examines that spectrum rather than automatically selecting only the strongest component."
            )

            informationCard(
                title: "Resonance",
                icon: "dot.radiowaves.left.and.right",
                text:
                    "Resonance describes a stronger response when a driving frequency is compatible with a system's natural mode. In the proposed QRTL model, resonance is treated as a mechanism for selecting and organizing energy."
            )

            informationCard(
                title: "Nonlinear Interaction",
                icon: "waveform.badge.plus",
                text:
                    "Nonlinear processes can produce harmonics and frequency-mixing products under appropriate physical conditions. The model can therefore examine whether new frequency components can arise from existing components rather than inventing them."
            )

            informationCard(
                title: "Molecular Checkpoint",
                icon: "magnifyingglass",
                text:
                    "Generated or selected frequencies are compared with molecular modes. Frequency proximity alone is not treated as proof of interaction; coupling, bandwidth, phase, molecular orientation, transition strength, and other factors can influence the modeled response."
            )

            informationCard(
                title: "Energy Conservation",
                icon: "bolt.badge.checkmark",
                text:
                    "The cascade maintains an explicit energy budget. Resonance and frequency conversion can redistribute energy, but the model does not treat them as sources of energy from nothing."
            )

            cascadeDiagram
        }
    }

    private var cascadeDiagram: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("CASCADE FLOW", systemImage: "arrow.down.to.line.compact")
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(AppTheme.accent)

            ForEach(Array(cascadeSteps.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 13) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.14))
                            .frame(width: 34, height: 34)

                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.accent)
                    }

                    Text(item)
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    if index < cascadeSteps.count - 1 {
                        Image(systemName: "arrow.down")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.accent.opacity(0.70))
                    }
                }
            }
        }
        .padding(18)
        .background(AppTheme.accent.opacity(0.075), in: roundedShape)
        .overlay {
            roundedShape
                .strokeBorder(AppTheme.accent.opacity(0.14), lineWidth: 1)
        }
    }

    private var cascadeSteps: [String] {
        [
            "Space energy",
            "Available spectrum",
            "QRTL coupling",
            "Resonance",
            "Nonlinear interaction",
            "Molecular response",
            "Chemical organization",
            "Stabilized sugar state"
        ]
    }

    // MARK: - Musical Analogy

    private var analogyContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                "The Musical-Chord Analogy",
                subtitle: "An intuitive way to think about coordinated oscillations.",
                icon: "music.note.list"
            )

            informationCard(
                title: "One Note vs. a Chord",
                icon: "music.note",
                text:
                    "A single musical note is simple. A chord requires multiple notes with compatible frequency and phase relationships. When the relationships are favorable, the notes reinforce one another and create a recognizable pattern."
            )

            informationCard(
                title: "Atoms Are the Instruments",
                icon: "person.3.fill",
                text:
                    "Carbon, hydrogen, and oxygen can be imagined as different instruments. Each has its own electronic structure and possible energetic states."
            )

            informationCard(
                title: "Energy States Are the Notes",
                icon: "music.note",
                text:
                    "Molecular energy states can be imagined as musical notes. Different molecular modes respond to different frequency ranges."
            )

            informationCard(
                title: "QRTL Is the Acoustic Space",
                icon: "waveform",
                text:
                    "The proposed QRTL lattice can be imagined as the acoustic environment in which the instruments interact. It provides an organized resonant framework in the model."
            )

            informationCard(
                title: "Coherence Is Synchronization",
                icon: "person.2.wave.2.fill",
                text:
                    "Coherence represents organized relationships between oscillations. Like musicians staying synchronized, coherent oscillations maintain meaningful phase relationships."
            )

            informationCard(
                title: "Sugar Is the Completed Chord",
                icon: "checkmark.circle.fill",
                text:
                    "The desired molecular structure is analogous to the completed chord: a stable configuration produced by multiple interacting components. The analogy is useful for understanding organization, but it does not replace molecular physics or chemistry."
            )

            limitationNotice
        }
    }

    private var limitationNotice: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 5) {
                Text("Important Limitation")
                    .font(.subheadline.weight(.bold))

                Text(
                    "Playing one musical note does not automatically create a chord. Likewise, applying one electromagnetic frequency does not automatically create a molecule. Frequency relationships, energy, coupling, molecular states, geometry, and chemistry must all be evaluated."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(15)
        .background(Color.orange.opacity(0.10), in: roundedShape)
        .overlay {
            roundedShape
                .strokeBorder(Color.orange.opacity(0.20), lineWidth: 1)
        }
    }

    // MARK: - Chemistry

    private var chemistryContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                "The Chemical Bridge",
                subtitle: "Connecting simple carbon chemistry to a molecular target.",
                icon: "atom"
            )

            informationCard(
                title: "Simple Molecules → Complex Organics",
                icon: "arrow.right",
                text:
                    "The proposed chemical pathway begins with relatively simple carbon-containing molecules and explores how reaction networks could progress toward increasingly complex organic structures."
            )

            reactionCard

            informationCard(
                title: "Formaldehyde",
                icon: "circle.hexagongrid.fill",
                text:
                    "Formaldehyde, H₂CO, is an important intermediate in the modeled pathway. It represents a step between simple carbon chemistry and more complex carbon-containing molecules."
            )

            informationCard(
                title: "Glycolaldehyde",
                icon: "hexagon",
                text:
                    "Glycolaldehyde, HOCH₂CHO, represents a larger carbon-containing intermediate. In the proposed reaction network, such intermediates provide a conceptual bridge toward increasingly complex sugar chemistry."
            )

            informationCard(
                title: "Molecular Formula Is Not Molecular Identity",
                icon: "number.circle.fill",
                text:
                    "C₆H₁₂O₆ specifies six carbon atoms, twelve hydrogen atoms, and six oxygen atoms. It does not by itself establish the complete molecular structure. The model therefore needs to evaluate connectivity and three-dimensional geometry."
            )

            informationCard(
                title: "Bond Formation",
                icon: "link.circle.fill",
                text:
                    "Electromagnetic excitation can provide energy or influence molecular states, but excitation alone does not prove that a chemical bond forms. Bond formation requires a chemically meaningful pathway and energetically accessible molecular configuration."
            )

            informationCard(
                title: "Ring Closure",
                icon: "arrow.triangle.merge",
                text:
                    "A ring structure requires a specific arrangement of atoms and bonds. The simulation treats ring closure as a structural event requiring geometry, connectivity, and energetic compatibility."
            )
        }
    }

    private var reactionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("PROPOSED CHEMICAL BRIDGE", systemImage: "arrow.triangle.branch")
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(AppTheme.accent)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    reactionNode("CO")
                    reactionArrow
                    reactionNode("HCO")
                    reactionArrow
                    reactionNode("H₂CO")
                    reactionArrow
                    reactionNode("HOCH₂CHO")
                    reactionArrow
                    reactionNode("C₆H₁₂O₆")
                }

                VStack(spacing: 9) {
                    chemistryStep("CO", detail: "Carbon monoxide")
                    chemistryStep("HCO", detail: "Formyl intermediate")
                    chemistryStep("H₂CO", detail: "Formaldehyde")
                    chemistryStep("HOCH₂CHO", detail: "Glycolaldehyde")
                    chemistryStep("C₆H₁₂O₆", detail: "Target formula")
                }
            }

            Text(
                "Illustrative pathway only. Molecular identity, reaction conditions, energy constraints, and structural verification remain explicit requirements of the model."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(AppTheme.accent.opacity(0.075), in: roundedShape)
        .overlay {
            roundedShape
                .strokeBorder(AppTheme.accent.opacity(0.14), lineWidth: 1)
        }
    }

    private func reactionNode(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.bold))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(.background, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(AppTheme.accent.opacity(0.25), lineWidth: 1)
            }
    }

    private var reactionArrow: some View {
        Image(systemName: "arrow.right")
            .font(.caption.weight(.bold))
            .foregroundStyle(AppTheme.accent)
    }

    private func chemistryStep(
        _ formula: String,
        detail: String
    ) -> some View {
        HStack(spacing: 12) {
            Text(formula)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 90, alignment: .leading)

            Image(systemName: "arrow.down")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    // MARK: - Scientific Boundary

    private var scienceContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                "Scientific Boundary",
                subtitle: "Separating measured inputs from proposed mechanisms.",
                icon: "checkmark.seal"
            )

            informationCard(
                title: "What the Model Can Test",
                icon: "checkmark.circle.fill",
                text:
                    "The simulation can explore relationships between environmental conditions, frequency content, resonance, coupling, molecular modes, energy flow, reaction pathways, geometry, and stability."
            )

            informationCard(
                title: "Measured Physical Anchors",
                icon: "waveform.path.ecg.rectangle",
                text:
                    "Known molecular spectra, molecular structures, reaction information, and other experimentally measured quantities can provide checkpoints against which the computational model can be compared."
            )

            informationCard(
                title: "Proposed QRTL Mechanism",
                icon: "atom",
                text:
                    "The QRTL lattice, its proposed resonance behavior, its frequency-cascade mechanism, and its ability to guide molecular assembly are model hypotheses. They require mathematical development and experimental testing."
            )

            informationCard(
                title: "Failure Is a Valid Result",
                icon: "xmark.circle.fill",
                text:
                    "The strongest version of the simulation should be able to report failure. If a required frequency cannot be generated, coupling is insufficient, energy is unavailable, molecular excitation is forbidden, or the chemical pathway cannot proceed, the cascade should stop or report that limitation."
            )

            informationCard(
                title: "No Automatic Energy Creation",
                icon: "bolt.slash.fill",
                text:
                    "Resonance does not create energy from nothing. Energy must come from an explicitly defined source, and the simulation should maintain an accounting of energy entering, transferring, storing, and leaving the system."
            )

            informationCard(
                title: "Verification",
                icon: "checkmark.shield.fill",
                text:
                    "A successful computational state would still require physical verification. Molecular identity could ultimately be examined through structural analysis and experimental signatures such as infrared spectra, rotational spectra, and mass spectrometry."
            )

            finalStatement
        }
    }

    private var finalStatement: some View {
        VStack(alignment: .leading, spacing: 13) {
            Label("THE SPACE SUGAR CONCEPT", systemImage: "sparkles")
                .font(.caption.weight(.bold))
                .tracking(0.9)
                .foregroundStyle(AppTheme.accent)

            Text(
                "Space provides the environment and energy. Molecules provide the building blocks. Resonance provides frequency selectivity. The proposed QRTL lattice provides an organizing framework. Nonlinear interactions provide possible frequency transformation. Molecular spectroscopy provides physical checkpoints. Chemistry determines whether bonds and structures can form. Stability determines whether the resulting molecule survives."
            )
            .font(.body)

            Text(
                "The simulation's purpose is to calculate the conditions under which the proposed pathway could succeed—and to identify the precise stage at which it fails when those conditions are not satisfied."
            )
            .font(.body.weight(.semibold))
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.accent.opacity(0.14),
                    AppTheme.secondaryAccent.opacity(0.09)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: roundedShape
        )
        .overlay {
            roundedShape
                .strokeBorder(AppTheme.accent.opacity(0.17), lineWidth: 1)
        }
    }

    // MARK: - Reusable Components

    private func pipelineCard(
        _ stage: PipelineStage
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                stageNumber(stage.id)

                VStack(alignment: .leading, spacing: 4) {
                    Text(stage.title)
                        .font(.headline.weight(.semibold))

                    Text(stage.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Image(systemName: stage.icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 28)
                    .accessibilityHidden(true)
            }

            Text(stage.explanation)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            HStack(alignment: .top, spacing: 9) {
                Image(systemName: "scope")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Why it matters")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accent)

                    Text(stage.importance)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .cardSurface(cornerRadius: cardCornerRadius)
        .accessibilityElement(children: .combine)
    }

    private func stageNumber(_ value: Int) -> some View {
        ZStack {
            Circle()
                .fill(AppTheme.accent.opacity(0.13))
                .frame(width: 44, height: 44)

            Text("\(value)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.accent)
        }
        .accessibilityLabel("Stage \(value)")
    }

    private func informationCard(
        title: String,
        icon: String,
        text: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 24)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.headline.weight(.semibold))
            }

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .cardSurface(cornerRadius: cardCornerRadius)
        .accessibilityElement(children: .combine)
    }

    private func sectionHeader(
        _ title: String,
        subtitle: String,
        icon: String
    ) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.title3.weight(.bold))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 2)
    }

    private var roundedShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: cardCornerRadius,
            style: .continuous
        )
    }
}

// MARK: - Theme

private enum AppTheme {
    static let accent = Color(
        red: 0.18,
        green: 0.37,
        blue: 0.83
    )

    static let secondaryAccent = Color(
        red: 0.08,
        green: 0.67,
        blue: 0.74
    )

    static let heroStart = Color(
        red: 0.10,
        green: 0.18,
        blue: 0.50
    )

    static let heroEnd = Color(
        red: 0.08,
        green: 0.52,
        blue: 0.68
    )

    static let backgroundTop = Color(
        uiColor: .systemGroupedBackground
    )

    static let backgroundBottom = Color(
        uiColor: .secondarySystemGroupedBackground
    )
}

// MARK: - Card Surface

private extension View {
    func cardSurface(cornerRadius: CGFloat) -> some View {
        self
            .background(
                Color(uiColor: .secondarySystemGroupedBackground),
                in: RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .strokeBorder(
                    Color.primary.opacity(0.07),
                    lineWidth: 1
                )
            }
    }
}
