import Foundation

private let kArchiveKey = "ChecklistArchive.lists"

enum ChecklistArchive {
    static var archived: [Checklist] = loadArchive()

    private static func loadArchive() -> [Checklist] {
        guard let data = UserDefaults.standard.data(forKey: kArchiveKey),
              let decoded = try? JSONDecoder().decode([Checklist].self, from: data) else { return [] }
        return decoded
    }

    static func saveArchive() {
        guard let data = try? JSONEncoder().encode(archived) else { return }
        UserDefaults.standard.set(data, forKey: kArchiveKey)
    }

    static func add(_ checklist: Checklist) {
        archived.insert(checklist, at: 0)
        saveArchive()
    }

    static func remove(at index: Int) {
        guard index >= 0, index < archived.count else { return }
        archived.remove(at: index)
        saveArchive()
    }
}
