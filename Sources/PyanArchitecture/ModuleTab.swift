//
//  ModuleTabs.swift
//  pyan-architecture
//
//  Created by Perceval Archimbaud on 24/03/2026.
//

import SwiftUI

public struct ModuleTabs<Builder: ModuleBuilder>: View {
	private let builder: Builder
	private let tabs: [ModuleTab<Builder.ScreenKey>]

	@State private var selectedTab: ModuleTab<Builder.ScreenKey>

	public init(builder: Builder, tabs: [ModuleTab<Builder.ScreenKey>], initialIndex: Int = 0) {
		precondition(!tabs.isEmpty, "Unexpected empty tab list")
		precondition(tabs.count > initialIndex, "Initial tab index is out of range")

		self.builder = builder
		self.tabs = tabs
		self.selectedTab = tabs[initialIndex]
	}

	public var body: some View {
		TabView(selection: $selectedTab) {
			ForEach(tabs) { tab in
				Tab(value: tab, role: tab.role) {
					builder.root(for: tab.screen)
				} label: {
					tab.label()
				}

			}
		}
	}
}

public struct ModuleTab<ScreenKey: BuildableScreen>: Identifiable, Hashable {
	let label: () -> AnyView
	let role: TabRole?
	let screen: ScreenKey

	public init(screen: ScreenKey, role: TabRole? = nil, @ViewBuilder label: @escaping () -> some View) {
		self.label = { AnyView(label()) }
		self.role = role
		self.screen = screen
	}

	public init(screen: ScreenKey, title: any StringProtocol, systemImage: String, role: TabRole? = nil) {
		self.label = { AnyView(Label(title, systemImage: systemImage)) }
		self.role = role
		self.screen = screen
	}

	public init(screen: ScreenKey, title: LocalizedStringKey, systemImage: String, role: TabRole? = nil) {
		self.label = { AnyView(Label(title, systemImage: systemImage)) }
		self.role = role
		self.screen = screen
	}

	public init(screen: ScreenKey, title: any StringProtocol, image: String, role: TabRole? = nil) {
		self.label = { AnyView(Label(title, image: image)) }
		self.role = role
		self.screen = screen
	}

	public init(screen: ScreenKey, title: LocalizedStringKey, image: String, role: TabRole? = nil) {
		self.label = { AnyView(Label(title, image: image)) }
		self.role = role
		self.screen = screen
	}

	public var id: ScreenKey { screen }

	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.screen == rhs.screen
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(screen)
	}
}
