import UIKit

private let kThemeKey = "ThemeManager.currentTheme"
private let kThemeMigrationKey = "ThemeManager.themeMigrationV1"

extension Notification.Name {
    static let themeDidChange = Notification.Name("ThemeManager.themeDidChange")
}

final class ThemeManager {
    static let shared = ThemeManager()

    var currentTheme: AppTheme {
        didSet {
            if currentTheme != oldValue {
                UserDefaults.standard.set(currentTheme.rawValue, forKey: kThemeKey)
                NotificationCenter.default.post(name: .themeDidChange, object: self)
            }
        }
    }

    private init() {
        let raw = UserDefaults.standard.integer(forKey: kThemeKey)
        if UserDefaults.standard.object(forKey: kThemeKey) == nil {
            currentTheme = .white
            return
        }
        if !UserDefaults.standard.bool(forKey: kThemeMigrationKey) {
            UserDefaults.standard.set(true, forKey: kThemeMigrationKey)
            let oldToNew: [Int: AppTheme] = [0: .sunny, 1: .ocean, 2: .berry, 3: .mint, 4: .night]
            if let theme = oldToNew[raw] {
                currentTheme = theme
                UserDefaults.standard.set(theme.rawValue, forKey: kThemeKey)
                return
            }
        }
        self.currentTheme = AppTheme(rawValue: raw) ?? .white
    }
}
