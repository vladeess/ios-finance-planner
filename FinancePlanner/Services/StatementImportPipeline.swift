import Foundation
import Combine
import SwiftData

public struct RawStatementItem: Codable {
    public let id: String
    public let mcc: Int
    public let amount: Double
    public let isoDate: String
    public let accountName: String
    public let note: String?
}

public struct ParsedRecord {
    public let id: UUID
    public let mcc: Int
    public let category: String
    public let amount: Double
    public let date: Date
    public let accountName: String
    public let note: String
}

public enum ImportError: LocalizedError {
    case invalidFile
    case parsingFailed
    case emptyData
    
    public var errorDescription: String? {
        switch self {
        case .invalidFile: return "Не удалось прочитать выбранный файл."
        case .parsingFailed: return "Ошибка разбора схемы данных банковской выписки."
        case .emptyData: return "В файле выписки отсутствуют операции."
        }
    }
}

public final class StatementImportPipeline {
    private let mccService = MCCDirectoryService.shared
    
    public init() {}
    
    public func processFile(at url: URL) -> AnyPublisher<[ParsedRecord], ImportError> {
        return Just(url)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .tryMap { fileURL -> Data in
                let canAccess = fileURL.startAccessingSecurityScopedResource()
                defer {
                    if canAccess { fileURL.stopAccessingSecurityScopedResource() }
                }
                return try Data(contentsOf: fileURL)
            }
            .mapError { _ in ImportError.invalidFile }
            .flatMap { [weak self] rawData -> AnyPublisher<[ParsedRecord], ImportError> in
                guard let self = self else {
                    return Fail(error: ImportError.parsingFailed).eraseToAnyPublisher()
                }
                return self.decodeAndTransform(data: rawData)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func decodeAndTransform(data: Data) -> AnyPublisher<[ParsedRecord], ImportError> {
        return Just(data)
            .decode(type: [RawStatementItem].self, decoder: JSONDecoder())
            .mapError { _ in ImportError.parsingFailed }
            .flatMap { [weak self] items -> AnyPublisher<[ParsedRecord], ImportError> in
                guard let self = self else {
                    return Fail(error: ImportError.parsingFailed).eraseToAnyPublisher()
                }
                guard !items.isEmpty else {
                    return Fail(error: ImportError.emptyData).eraseToAnyPublisher()
                }
                
                let isoFormatter = ISO8601DateFormatter()
                let records: [ParsedRecord] = items.compactMap { raw in
                    guard let uuid = UUID(uuidString: raw.id), raw.amount > 0 else { return nil }
                    let txDate = isoFormatter.date(from: raw.isoDate) ?? Date()
                    let resolved = self.mccService.resolveCategory(for: raw.mcc)
                    return ParsedRecord(
                        id: uuid,
                        mcc: raw.mcc,
                        category: resolved.category,
                        amount: raw.amount,
                        date: txDate,
                        accountName: raw.accountName,
                        note: raw.note ?? ""
                    )
                }
                return Just(records)
                    .setFailureType(to: ImportError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
