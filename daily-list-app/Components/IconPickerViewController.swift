import UIKit

/// Default list icon: circle with + inside (tap to pick another)
let kListDefaultIconName = "plus.circle"

let kListIconNames: [String] = [
    "plus.circle", "list.bullet", "star.fill", "heart.fill", "cart.fill", "airplane",
    "leaf.fill", "book.fill", "gamecontroller.fill", "house.fill", "briefcase.fill",
    "gift.fill", "flag.fill", "bell.fill", "envelope.fill", "phone.fill",
    "calendar", "tag.fill", "pencil", "checkmark.circle.fill", "folder.fill",
    "tray.fill", "doc.fill", "note.text", "sportscourt.fill", "figure.walk"
]

final class IconPickerViewController: UIViewController {
    private let icons: [String]
    private let selectedName: String
    private let theme: AppTheme
    private let onSelect: (String) -> Void
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(icons: [String], selectedName: String, theme: AppTheme, onSelect: @escaping (String) -> Void) {
        self.icons = icons
        self.selectedName = selectedName
        self.theme = theme
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
        title = "List icon"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.backgroundColor
        navigationController?.navigationBar.tintColor = theme.accentColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: theme.textPrimaryColor]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func cancelTapped() { dismiss(animated: true) }
}

extension IconPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { icons.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard icons.indices.contains(indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let name = icons[indexPath.row]
        cell.textLabel?.text = name
        cell.textLabel?.textColor = theme.textPrimaryColor
        cell.imageView?.image = UIImage(systemName: name)
        cell.imageView?.tintColor = theme.accentColor
        cell.accessoryType = name == selectedName ? .checkmark : .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard icons.indices.contains(indexPath.row) else { return }
        onSelect(icons[indexPath.row])
        dismiss(animated: true)
    }
}
