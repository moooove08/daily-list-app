import Foundation

struct Checklist: Codable {
    let id: UUID
    var title: String
    var items: [ChecklistItem]
    var iconName: String?
    var accentColorHex: String?

    enum CodingKeys: String, CodingKey {
        case id, title, items, iconName, accentColorHex
    }

    init(id: UUID, title: String, items: [ChecklistItem], iconName: String? = nil, accentColorHex: String? = nil) {
        self.id = id
        self.title = title
        self.items = items
        self.iconName = iconName
        self.accentColorHex = accentColorHex
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        items = try c.decode([ChecklistItem].self, forKey: .items)
        iconName = try c.decodeIfPresent(String.self, forKey: .iconName)
        accentColorHex = try c.decodeIfPresent(String.self, forKey: .accentColorHex)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(items, forKey: .items)
        try c.encodeIfPresent(iconName, forKey: .iconName)
        try c.encodeIfPresent(accentColorHex, forKey: .accentColorHex)
    }
}

struct ChecklistItem: Codable {
    let id: UUID
    var title: String
    var isChecked: Bool
}
