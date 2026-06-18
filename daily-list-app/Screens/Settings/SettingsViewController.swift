import UIKit

private let kCardCornerRadius: CGFloat = 12
private let kCardInset: CGFloat = 16
private let kTitleFontSize: CGFloat = 28
private let kHeaderHorizontalInset: CGFloat = 20
private let kHeaderTopPadding: CGFloat = 12
private let kHeaderBottomPadding: CGFloat = 8

final class SettingsViewController: UIViewController {

    var onOpenArchive: (() -> Void)?

    private let headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: kTitleFontSize, weight: .bold)
        l.text = "Settings"
        return l
    }()

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.separatorStyle = .none
        t.backgroundColor = .clear
        return t
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ThemeCell.self, forCellReuseIdentifier: ThemeCell.reuseId)
        tableView.register(ArchiveRowCell.self, forCellReuseIdentifier: ArchiveRowCell.reuseId)
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        view.addSubview(tableView)
        let theme = ThemeManager.shared.currentTheme
        titleLabel.textColor = theme.textPrimaryColor
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: kHeaderHorizontalInset),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -kHeaderHorizontalInset),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: kHeaderTopPadding),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -kHeaderBottomPadding),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func applyTheme() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        titleLabel.textColor = theme.textPrimaryColor
        tableView.reloadData()
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return AppTheme.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ArchiveRowCell.reuseId, for: indexPath) as! ArchiveRowCell
            cell.configure(theme: ThemeManager.shared.currentTheme)
            return cell
        }
        guard AppTheme.allCases.indices.contains(indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: ThemeCell.reuseId, for: indexPath) as! ThemeCell
        let theme = AppTheme.allCases[indexPath.row]
        cell.configure(theme: theme, isSelected: theme == ThemeManager.shared.currentTheme)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 {
            onOpenArchive?()
        } else {
            guard AppTheme.allCases.indices.contains(indexPath.row) else { return }
            ThemeManager.shared.currentTheme = AppTheme.allCases[indexPath.row]
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let theme = ThemeManager.shared.currentTheme
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = theme.textSecondaryColor
        label.text = section == 0 ? "Archive" : "Theme"
        let wrap = UIView()
        wrap.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: kCardInset),
            label.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -kCardInset),
            label.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -4)
        ])
        return wrap
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        28
    }
}

private final class ArchiveRowCell: UITableViewCell {
    static let reuseId = "ArchiveRowCell"
    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = kCardCornerRadius
        return v
    }()
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 17, weight: .regular)
        l.text = "Archive"
        return l
    }()
    private let iconView: UIImageView = {
        let i = UIImageView(image: UIImage(systemName: "archivebox"))
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    private let chevronView: UIImageView = {
        let i = UIImageView(image: UIImage(systemName: "chevron.right"))
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .default
        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(iconView)
        cardView.addSubview(chevronView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kCardInset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kCardInset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            chevronView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 14),
            chevronView.heightAnchor.constraint(equalToConstant: 14),
            iconView.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -8),
            iconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(theme: AppTheme) {
        cardView.backgroundColor = theme.cardColor
        titleLabel.textColor = theme.textPrimaryColor
        iconView.tintColor = theme.accentColor
        chevronView.tintColor = theme.textSecondaryColor
    }
}

private final class ThemeCell: UITableViewCell {

    static let reuseId = "ThemeCell"

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = kCardCornerRadius
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 17, weight: .regular)
        return l
    }()

    private let checkView: UIImageView = {
        let i = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(checkView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kCardInset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kCardInset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            checkView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            checkView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            checkView.widthAnchor.constraint(equalToConstant: 24),
            checkView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(theme: AppTheme, isSelected: Bool) {
        cardView.backgroundColor = theme.cardColor
        titleLabel.text = theme.displayName
        titleLabel.textColor = theme.textPrimaryColor
        checkView.tintColor = theme.accentColor
        checkView.isHidden = !isSelected
    }
}
