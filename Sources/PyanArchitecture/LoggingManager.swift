//
//  LoggingManager.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 02/03/2026.
//

import Foundation

/// Manages the logging system bootstrap and provides categorized loggers.
///
/// `LoggingManager` wraps PyanLogging's ``LoggerFactory`` and
/// ``MetadataContainer`` into a single entry point. Call ``boostrap(_:)`` early
/// in your app's lifecycle to configure the log handler; if you call
/// ``logger(for:)`` before bootstrapping, a default `OSLogHandler` is used
/// automatically.
///
/// ```swift
/// enum AppLogCategory: String, LogCategory { case network, ui }
/// enum AppMetadata: MetadataKey { case userId }
///
/// let logging = LoggingManager<AppLogCategory, AppMetadata>()
///     .boostrap { label, provider in
///         OSLogHandler(label: label, category: "App", metadataProvider: provider)
///     }
///
/// let logger = logging.logger(for: .network)
/// ```
public final class LoggingManager<Category: LogCategory, AppMetadataKey: MetadataKey> {
	/// A convenience alias for the metadata container parameterized with the app's metadata key type.
	public typealias MetadataContainer = PyanLogging.MetadataContainer<AppMetadataKey>

	private var isBootstrapped: Bool = false
	private var isAutoBootstrapped: Bool = false
	private let factory: LoggerFactory<Category>

	/// The metadata container used to attach global metadata to every log message.
	public let metadataContainer: MetadataContainer = .init()

	private static var label: String { Bundle.main.bundleIdentifier ?? "PyanLogger" }

	/// Creates a new logging manager.
	public init() {
		self.factory = .init(label: Self.label)
	}

	/// Returns a logger for the given category.
	/// 
	/// - Parameter category: The log category to use.
	/// - Returns: A configured `Logger` instance.
	public func logger(for category: Category) -> Logger {
		if !isBootstrapped {
			defaultBootstrap()
		}

		return factory.logger(for: category)
	}

	/// Bootstraps the logging system with the given log handler factory.
	///
	/// - Parameter factory: A closure that creates a log handler for the given label and metadata provider.
	/// - Returns: The logging manager instance for method chaining.
	@discardableResult
	public func boostrap(
		_ factory: @Sendable @escaping (String, Logger.MetadataProvider?) -> any LogHandler
	) -> Self {
		return boostrap({ label, provider in factory(label, provider) }, metadataProvider: nil)
	}

	/// Bootstraps the logging system with the given log handler factory and a custom metadata provider.
	///
	/// The ``metadataContainer``'s provider is automatically multiplexed with
	/// the supplied `metadataProvider`, taking precedence.
	///
	/// - Parameters:
	///   - factory: A closure that creates a log handler for the given label and metadata provider.
	///   - metadataProvider: An additional metadata provider to merge.
	/// - Returns: The logging manager instance for method chaining.
	@discardableResult
	public func boostrap(
		_ factory: @Sendable @escaping (String, Logger.MetadataProvider?) -> any LogHandler,
		metadataProvider: Logger.MetadataProvider?
	) -> Self {
		guard !isBootstrapped else {
			let logger = Logger(label: Self.label)
			if isAutoBootstrapped {
				assertionFailure("`logger(for:)` has already been called, triggering an automatic bootstrap. Ignoring.")
				logger.error("`logger(for:)` has already been called, triggering an automatic bootstrap. Ignoring.")
			} else {
				assertionFailure("LoggingSystem has already been bootstrapped. Ignoring.")
				logger.error("LoggingSystem has already been bootstrapped. Ignoring.")
			}
			return self
		}

		isBootstrapped = true

		let provider: Logger.MetadataProvider?
		if let metadataProvider {
			provider = .multiplex([
				metadataProvider,
				metadataContainer.provider // Takes precedence
			])
		} else {
			provider = metadataContainer.provider
		}

		LoggingSystem.bootstrap(factory, metadataProvider: provider)

		return self
	}
}

extension LoggingManager {
	private func defaultBootstrap() {
		isAutoBootstrapped = true

		boostrap({ label, provider in
			OSLogHandler(label: label, category: "Uncategorized", metadataProvider: provider)
		}, metadataProvider: nil)
	}
}
