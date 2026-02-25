//
//  FeatureSwitcher+LoggerAttachable.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 06/03/2026.
//

extension FileSwitcher: @retroactive LoggerAttachable {}
extension FileSwitcher.Options: @retroactive LoggerAttachable {}
extension MultiplexSwitcher: @retroactive LoggerAttachable {}
extension RandomSwitcher: @retroactive LoggerAttachable {}

extension FeatureManager: @retroactive LoggerAttachable {}
