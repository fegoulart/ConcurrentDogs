//
//  DogsRepositoryTests.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import XCTest
import NetworkingImp
import NetworkingInterface
import Alamofire

final class DogsRepositoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(StubUrlProtocol.self)
    }

    override func tearDown() {
        super.tearDown()
        URLProtocol.unregisterClass(StubUrlProtocol.self)
    }

    func testExample() async throws {
        StubUrlProtocol.observer = { request -> (URLResponse?, Data?) in
            return (HTTPURLResponse(url: URL(string: "https://lalala.com")!, statusCode: 200, httpVersion: nil, headerFields: nil), "[ { \"id\": 1, \"name\": \"Beagle\", \"image\": {\"id\": \"lalala\", \"url\": \"https://hahaha.com\"}}, { \"id\": 2, \"name\": \"Doberman\", \"image\": {\"id\": \"lelele\", \"url\": \"https://hehehehe.com\"}}]".data(using: .utf8)!)
                }

        let sut = makeSUT(
            dogs: [
                DogDTO(
                    id: 1,
                    name: "Beagle",
                    image: DogImageDTO(
                        id: "lalala",
                        url: "https://hahaha.com"
                    )
                ),
                DogDTO(
                    id: 2,
                    name: "Doberman",
                    image: DogImageDTO(
                        id: "lelele",
                        url: "https://hehehehe.com"
                        )
                )

        ], 
            image: Data()
        )
        do {
            let dogs: [Dog] = try await sut.fetchDogs(limit: 20, page: 0)
            XCTAssertEqual(dogs, [Dog(breed: "Beagle", image: "https://hahaha.com"), Dog(breed: "Doberman", image: "https://hehehehe.com")])
        } catch {
            XCTFail("should not fail")
        }

    }

    private func makeSUT(
        dogs: [DogDTO],
        image: Data,
        file: StaticString = #file,
        line: UInt = #line
    ) -> DogsRepository {
        let configuration = URLSessionConfiguration.af.ephemeral
        configuration.protocolClasses = [StubUrlProtocol.self] + (configuration.protocolClasses ?? [])
        let session = Alamofire.Session(configuration: configuration)
        // let interceptor = Interceptor(adapter: MyAdapter(), retrier: MyRetrier())
        //let decodableNetworkService = AFDecodableNetworkService<[DogDTO]>(interceptor: interceptor)
        // let dataNetworkService = AFDataNetworkService(interceptor: interceptor)
        // let httpClient = AFNetworkService(dataService: dataNetworkService, decodableService: decodableNetworkService)
        let httpClient = TestHttpClient(dogs: dogs, data: image, session: session)
        let dogsRepository = DogsRepository(httpClient: httpClient)
        return dogsRepository
    }

    /*
     private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
         let configuration = URLSessionConfiguration.ephemeral
         configuration.protocolClasses = [URLProtocolStub.self]
         let session = URLSession(configuration: configuration)

         let sut = URLSessionHTTPClient(session: session)
         trackForMemoryLeaks(sut, file: file, line: line)
         return sut
     }
     */
}

class StubUrlProtocol: URLProtocol {
    static var observer: ((URLRequest) throws -> (URLResponse?, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            self.client?.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .allowed)

            guard let (response, data) = try Self.observer?(request) else {
                return
            }
            if let response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }
}

final class TestHttpClient: HTTPClient {
    var dataResponse: Data = Data()
    var dogsDTOResponse: [DogDTO] = []
    let session: Session

    init(dogs: [DogDTO], data: Data, session: Session) {
        dataResponse = data
        dogsDTOResponse = dogs
        self.session = session
    }

    func get<T>(url: String, parameters: [String : Any], _ type: T.Type) throws -> any HTTPClientTask {
        if type == Data.self {
            return session.request(url).serializingData()
        }
        if type == [DogDTO].self {
            return session.request(url).serializingDecodable() as DataTask<[DogDTO]>
        }
        // FIXME: Create proper error
        throw DogsError.invalidImageData
    }

}

struct TestDataTask<Value>: HTTPClientTask {

    let response: Value

    init(response: Value) {
        self.response = response
    }

    func getResponse() async throws -> Value {
        return response
    }
    
    typealias T = Value

    func cancel() {

    }
}
