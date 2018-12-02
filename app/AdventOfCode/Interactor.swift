import Foundation

class Interactor {
    private enum Constants {
        static let urlString = "https://adventofcode.com/2018/leaderboard/private/view/"
    }

    weak var output: InteractorOutput?

    func requestLeaderboard(key: String) {
        let urlString = Constants.urlString + key + ".json"
        guard let url = URL(string: urlString) else {
            print("Error creating url, got nil")
            return
        }

        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": "session=53616c7465645f5f74f8c214ee9d64ed0bc440a722234bc77fd78bcb6506e9c5dd23777f8cabe0fbe72ed929dc221824"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
        jar.setCookies(cookies, for: url, mainDocumentURL: url)

        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, networkError in

            if let networkError = networkError {
                print(networkError)
                DispatchQueue.main.async {
                    self.output?.failedFetchingLeaderboard(error: networkError)
                }
                return
            }

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let leaderboard = try
                    decoder.decode(Leaderboard.self, from: data)
                print(leaderboard.event)
                DispatchQueue.main.async {
                    self.output?.didFetchLeaderboard(leaderboard)
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    self.output?.failedFetchingLeaderboard(error: error)
                }
            }
        }
        task.resume()
    }
}

protocol InteractorOutput: class {
    func didFetchLeaderboard(_ leaderboard: Leaderboard)
    func failedFetchingLeaderboard(error: Error)
}
