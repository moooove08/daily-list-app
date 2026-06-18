import UIKit

private let kCardCornerRadius: CGFloat = 12
private let kCardInset: CGFloat = 16

final class ArchiveViewController: UIViewController {

    private var archived: [Checklist] = []

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.separatorStyle = .none
        t.backgroundColor = .clear
        return t
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Archive"
        view.backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        applyNavBarTheme()
        archived = ChecklistArchive.archived
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArchiveCell.self, forCellReuseIdentifier: ArchiveCell.reuseId)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        archived = ChecklistArchive.archived
        applyNavBarTheme()
        tableView.reloadData()
    }

    @objc private func themeDidChange() { applyTheme() }

    private func applyNavBarTheme() {
        let theme = ThemeManager.shared.currentTheme
        guard let bar = navigationController?.navigationBar else { return }
        bar.tintColor = theme.accentColor
        bar.barTintColor = theme.backgroundColor
        bar.backgroundColor = theme.backgroundColor
        let appearance = bar.standardAppearance
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = theme.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: theme.textPrimaryColor]
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
    }

    func applyTheme() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        applyNavBarTheme()
        tableView.reloadData()
    }
}

extension ArchiveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        archived.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard archived.indices.contains(indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: ArchiveCell.reuseId, for: indexPath) as! ArchiveCell
        let list = archived[indexPath.row]
        let theme = ThemeManager.shared.currentTheme
        let accent = list.accentColorHex.flatMap { UIColor.from(hex: $0) } ?? theme.accentColor
        let iconName = list.iconName.flatMap { $0.isEmpty ? nil : $0 } ?? kListDefaultIconName
        cell.configure(title: list.title.isEmpty ? "Untitled" : list.title, iconName: iconName, accentColor: accent, theme: theme)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard archived.indices.contains(indexPath.row) else { return }
        let list = archived[indexPath.row]
        let detail = ArchiveDetailViewController(checklist: list)
        navigationController?.pushViewController(detail, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, archived.indices.contains(indexPath.row) {
            ChecklistArchive.remove(at: indexPath.row)
            archived = ChecklistArchive.archived
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
}

private final class ArchiveCell: UITableViewCell {
    static let reuseId = "ArchiveCell"
    private let cardView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .default
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = kCardCornerRadius
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        contentView.addSubview(cardView)
        cardView.addSubview(iconView)
        cardView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kCardInset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kCardInset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, iconName: String, accentColor: UIColor, theme: AppTheme) {
        cardView.backgroundColor = theme.cardColor
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = accentColor
        titleLabel.text = title
        titleLabel.textColor = theme.textPrimaryColor
    }
}

final class ArchiveDetailViewController: UIViewController {
    private let checklist: Checklist
    private lazy var doneButton: UIButton = makeThemedDoneButton()
    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = .clear
        return t
    }()

    init(checklist: Checklist) {
        self.checklist = checklist
        super.init(nibName: nil, bundle: nil)
        title = checklist.title.isEmpty ? "Untitled" : checklist.title
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        let bgView = UIView()
        bgView.backgroundColor = theme.backgroundColor
        tableView.backgroundView = bgView
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        applyNavBarTheme()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyNavBarTheme()
    }

    private func applyNavBarTheme() {
        let theme = ThemeManager.shared.currentTheme
        guard let bar = navigationController?.navigationBar else { return }
        bar.tintColor = theme.accentColor
        bar.barTintColor = theme.backgroundColor
        let appearance = bar.standardAppearance
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = theme.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: theme.textPrimaryColor]
        bar.standardAppearance = appearance
        doneButton.configuration = doneButtonConfiguration(theme: theme)
    }

    private func makeThemedDoneButton() -> UIButton {
        UIButton(configuration: doneButtonConfiguration(theme: ThemeManager.shared.currentTheme))
    }

    private func doneButtonConfiguration(theme: AppTheme) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Done"
        configuration.baseBackgroundColor = theme.accentColor
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        return configuration
    }

    @objc private func doneTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension ArchiveDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checklist.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard checklist.items.indices.contains(indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = checklist.items[indexPath.row]
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.cardColor
        cell.contentView.backgroundColor = theme.cardColor
        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = theme.textPrimaryColor
        cell.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
        cell.imageView?.tintColor = theme.accentColor
        cell.selectionStyle = .none
        return cell
    }
}
