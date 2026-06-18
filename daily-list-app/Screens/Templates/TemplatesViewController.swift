import UIKit

private let kCardCornerRadius: CGFloat = 12
private let kCardInset: CGFloat = 16
private let kTitleFontSize: CGFloat = 28
private let kHeaderHorizontalInset: CGFloat = 20
private let kHeaderTopPadding: CGFloat = 12
private let kHeaderBottomPadding: CGFloat = 8

final class TemplatesViewController: UIViewController {

    var onSelectTemplate: ((Checklist) -> Void)?

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
        l.text = "Templates"
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
        tableView.register(TemplateCardCell.self, forCellReuseIdentifier: TemplateCardCell.reuseId)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func applyTheme() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        titleLabel.textColor = theme.textPrimaryColor
        tableView.reloadData()
    }
}

extension TemplatesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ChecklistTemplates.templates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard ChecklistTemplates.templates.indices.contains(indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: TemplateCardCell.reuseId, for: indexPath) as! TemplateCardCell
        let template = ChecklistTemplates.templates[indexPath.row]
        let templateID = template.id
        cell.configure(
            template: template,
            theme: ThemeManager.shared.currentTheme,
            showEditButton: true,
            onEdit: { [weak self] in
                self?.openTemplateEdit(templateID: templateID)
            }
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard ChecklistTemplates.templates.indices.contains(indexPath.row) else { return }
        onSelectTemplate?(ChecklistTemplates.templates[indexPath.row])
    }

    private func openTemplateEdit(templateID: UUID) {
        guard let template = ChecklistTemplates.templates.first(where: { $0.id == templateID }) else { return }
        let detail = ChecklistDetailViewController(
            checklist: template,
            onSave: { [weak self] updated in
                guard let currentIndex = ChecklistTemplates.templates.firstIndex(where: { $0.id == templateID }) else { return }
                ChecklistTemplates.templates[currentIndex] = updated
                ChecklistTemplates.saveTemplates()
                self?.tableView.reloadData()
                self?.dismiss(animated: false)
            },
            onDelete: { [weak self] in
                guard let currentIndex = ChecklistTemplates.templates.firstIndex(where: { $0.id == templateID }) else { return }
                ChecklistTemplates.templates.remove(at: currentIndex)
                ChecklistTemplates.saveTemplates()
                self?.tableView.reloadData()
            },
            hideSaveAsTemplate: true
        )
        let nav = UINavigationController(rootViewController: detail)
        present(nav, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
}

private final class TemplateCardCell: UITableViewCell {

    static let reuseId = "TemplateCardCell"

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = kCardCornerRadius
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        return l
    }()

    private let stackView: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 6
        return s
    }()

    private let editButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Edit", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(stackView)
        cardView.addSubview(editButton)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kCardInset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kCardInset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: editButton.leadingAnchor, constant: -8),
            editButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            editButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            editButton.heightAnchor.constraint(equalToConstant: 32),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var onEdit: (() -> Void)?

    @objc private func editTapped() {
        onEdit?()
    }

    func configure(template: Checklist, theme: AppTheme, showEditButton: Bool = true, onEdit: (() -> Void)? = nil) {
        self.onEdit = onEdit
        cardView.backgroundColor = theme.cardColor
        titleLabel.text = template.title
        titleLabel.textColor = theme.textPrimaryColor
        editButton.tintColor = theme.accentColor
        editButton.isHidden = !showEditButton
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in template.items {
            let label = UILabel()
            label.text = "  " + item.title
            label.font = .systemFont(ofSize: 15)
            label.textColor = theme.textSecondaryColor
            stackView.addArrangedSubview(label)
        }
    }
}
