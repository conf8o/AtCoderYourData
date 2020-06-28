import Foundation

let ROOT_URL: String = {
    switch DEV_CONFIG {
    case .dev:
        return "http://localhost:8080"
    case .product:
        return "http://localhost:8080"
    }
}()
