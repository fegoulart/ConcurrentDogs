//
//  DogsSequence.swift
//  Concurrent Dogs
//
//  Created by Fernando Goulart on 3/4/24.
//

import Foundation
import NetworkingInterface

struct DogsSequence: AsyncSequence, AsyncIteratorProtocol, Sendable {

    typealias Element = [Dog]
    var page: Int = 0
    let fetchDogsUseCase: any FetchDogsUseCaseProtocol
    var lastPageReached: Bool = false

    init(fetchDogsUseCase: any FetchDogsUseCaseProtocol) {
        self.fetchDogsUseCase = fetchDogsUseCase
    }

    mutating func next() async throws -> Element? {
        guard !lastPageReached else { return nil }
        page += 1
        let currentPageDogs = try await fetchDogs(page)
        if currentPageDogs.isEmpty {
            lastPageReached = true
            return nil
        }
        return currentPageDogs
    }

    private func fetchDogs(_ page: Int) async throws -> Element {
        return try await fetchDogsUseCase.execute(limit: 20, page: page)
    }

    func makeAsyncIterator() -> DogsSequence {
        self
    }
}
