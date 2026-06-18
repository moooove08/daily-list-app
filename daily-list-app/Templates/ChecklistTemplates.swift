import Foundation

private let kTemplatesKey = "ChecklistTemplates.templates"
private let kUserTemplatesKeyLegacy = "ChecklistTemplates.userTemplates"

enum ChecklistTemplates {
    static var templates: [Checklist] = loadTemplates()

    private static func defaultTemplates() -> [Checklist] {
        [
            Checklist(
                id: UUID(),
                title: "Travel",
                items: [
                    ChecklistItem(id: UUID(), title: "Passport", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Tickets", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Hotel confirmation", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Phone charger", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Toiletries", isChecked: false)
                ]
            ),
            Checklist(
                id: UUID(),
                title: "Shopping",
                items: [
                    ChecklistItem(id: UUID(), title: "Milk", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Bread", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Eggs", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Fruits", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Vegetables", isChecked: false)
                ]
            ),
            Checklist(
                id: UUID(),
                title: "Game Launch",
                items: [
                    ChecklistItem(id: UUID(), title: "Pre-load game", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Update drivers", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Clear disk space", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Check server status", isChecked: false),
                    ChecklistItem(id: UUID(), title: "Snacks ready", isChecked: false)
                ]
            )
        ]
    }

    private static func loadTemplates() -> [Checklist] {
        if let data = UserDefaults.standard.data(forKey: kTemplatesKey),
           let decoded = try? JSONDecoder().decode([Checklist].self, from: data),
           !decoded.isEmpty {
            return decoded
        }
        if let data = UserDefaults.standard.data(forKey: kUserTemplatesKeyLegacy),
           let legacy = try? JSONDecoder().decode([Checklist].self, from: data),
           !legacy.isEmpty {
            let merged = defaultTemplates() + legacy
            if let encoded = try? JSONEncoder().encode(merged) {
                UserDefaults.standard.set(encoded, forKey: kTemplatesKey)
            }
            UserDefaults.standard.removeObject(forKey: kUserTemplatesKeyLegacy)
            return merged
        }
        return defaultTemplates()
    }

    static func saveTemplates() {
        guard let data = try? JSONEncoder().encode(templates) else { return }
        UserDefaults.standard.set(data, forKey: kTemplatesKey)
    }

    static func addUserTemplate(_ checklist: Checklist) {
        let copy = Checklist(
            id: UUID(),
            title: checklist.title,
            items: checklist.items.map { ChecklistItem(id: UUID(), title: $0.title, isChecked: false) },
            iconName: checklist.iconName,
            accentColorHex: checklist.accentColorHex
        )
        templates.append(copy)
        saveTemplates()
    }

    static var all: [Checklist] { templates }
}
