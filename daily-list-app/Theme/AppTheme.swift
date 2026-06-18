import UIKit

enum AppTheme: Int, CaseIterable, Codable {
    case white = 0   // базовая
    case light = 1
    case gray = 2
    case sunny = 3
    case ocean = 4
    case berry = 5
    case mint = 6
    case night = 7

    var displayName: String {
        switch self {
        case .white: return "White"
        case .light: return "Light"
        case .gray: return "Gray"
        case .sunny: return "Sunny"
        case .ocean: return "Ocean"
        case .berry: return "Berry"
        case .mint: return "Mint"
        case .night: return "Night"
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .white: return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .light: return UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
        case .gray: return UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1)
        case .sunny: return UIColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 1)
        case .ocean: return UIColor(red: 0.88, green: 0.95, blue: 1.0, alpha: 1)
        case .berry: return UIColor(red: 1.0, green: 0.92, blue: 0.96, alpha: 1)
        case .mint: return UIColor(red: 0.9, green: 0.98, blue: 0.95, alpha: 1)
        case .night: return UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1)
        }
    }

    var cardColor: UIColor {
        switch self {
        case .white: return UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
        case .light: return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .gray: return UIColor(red: 0.65, green: 0.65, blue: 0.68, alpha: 1)
        case .sunny: return UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1)
        case .ocean: return UIColor(red: 0.75, green: 0.9, blue: 1.0, alpha: 1)
        case .berry: return UIColor(red: 1.0, green: 0.85, blue: 0.9, alpha: 1)
        case .mint: return UIColor(red: 0.8, green: 0.98, blue: 0.9, alpha: 1)
        case .night: return UIColor(red: 0.18, green: 0.18, blue: 0.24, alpha: 1)
        }
    }

    var accentColor: UIColor {
        switch self {
        case .white: return UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)
        case .light: return UIColor(red: 0.2, green: 0.45, blue: 0.9, alpha: 1)
        case .gray: return UIColor(red: 0.35, green: 0.78, blue: 1, alpha: 1)
        case .sunny: return UIColor(red: 0.95, green: 0.6, blue: 0.2, alpha: 1)
        case .ocean: return UIColor(red: 0.2, green: 0.5, blue: 0.85, alpha: 1)
        case .berry: return UIColor(red: 0.8, green: 0.25, blue: 0.5, alpha: 1)
        case .mint: return UIColor(red: 0.2, green: 0.7, blue: 0.5, alpha: 1)
        case .night: return UIColor(red: 0.5, green: 0.75, blue: 1.0, alpha: 1)
        }
    }

    var tabBarBackgroundColor: UIColor {
        switch self {
        case .white: return UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
        case .light: return UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
        case .gray: return UIColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1)
        case .sunny: return UIColor(red: 1.0, green: 0.92, blue: 0.75, alpha: 1)
        case .ocean: return UIColor(red: 0.7, green: 0.85, blue: 0.98, alpha: 1)
        case .berry: return UIColor(red: 0.98, green: 0.8, blue: 0.88, alpha: 1)
        case .mint: return UIColor(red: 0.75, green: 0.95, blue: 0.85, alpha: 1)
        case .night: return UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1)
        }
    }

    var tabHighlightColor: UIColor {
        switch self {
        case .white: return UIColor(red: 0.6, green: 0.8, blue: 1, alpha: 1)
        case .light: return UIColor(red: 0.5, green: 0.7, blue: 1, alpha: 1)
        case .gray: return UIColor(red: 0.5, green: 0.85, blue: 1, alpha: 1)
        case .sunny: return UIColor(red: 1.0, green: 0.85, blue: 0.5, alpha: 1)
        case .ocean: return UIColor(red: 0.5, green: 0.78, blue: 1.0, alpha: 1)
        case .berry: return UIColor(red: 1.0, green: 0.65, blue: 0.78, alpha: 1)
        case .mint: return UIColor(red: 0.5, green: 0.92, blue: 0.75, alpha: 1)
        case .night: return UIColor(red: 0.25, green: 0.35, blue: 0.5, alpha: 1)
        }
    }

    var textPrimaryColor: UIColor {
        switch self {
        case .white: return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        case .light: return UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1)
        case .gray: return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .sunny: return UIColor(red: 0.2, green: 0.15, blue: 0.1, alpha: 1)
        case .ocean: return UIColor(red: 0.1, green: 0.2, blue: 0.35, alpha: 1)
        case .berry: return UIColor(red: 0.35, green: 0.1, blue: 0.2, alpha: 1)
        case .mint: return UIColor(red: 0.1, green: 0.25, blue: 0.2, alpha: 1)
        case .night: return UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1)
        }
    }

    var textSecondaryColor: UIColor {
        switch self {
        case .white: return UIColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1)
        case .light: return UIColor(red: 0.35, green: 0.35, blue: 0.4, alpha: 1)
        case .gray: return UIColor(red: 0.85, green: 0.85, blue: 0.88, alpha: 1)
        case .sunny: return UIColor(red: 0.45, green: 0.4, blue: 0.35, alpha: 1)
        case .ocean: return UIColor(red: 0.35, green: 0.45, blue: 0.55, alpha: 1)
        case .berry: return UIColor(red: 0.55, green: 0.35, blue: 0.45, alpha: 1)
        case .mint: return UIColor(red: 0.35, green: 0.5, blue: 0.45, alpha: 1)
        case .night: return UIColor(red: 0.65, green: 0.68, blue: 0.75, alpha: 1)
        }
    }
}
