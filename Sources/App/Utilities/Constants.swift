import Foundation

let ROOT_URL: String = {
    switch DEV_CONFIG {
    case .dev:
        return "http://localhost:8080"
    case .product:
        return "https://atcoder-your-data.herokuapp.com"
    }
}()
