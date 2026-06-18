import UIKit

private let kCardCornerRadius: CGFloat = 12
private let kInset: CGFloat = 16

final class ChecklistDetailViewController: UIViewController {

    private var checklist: Checklist
    private let onSave: (Checklist) -> Void
    private let onDelete: () -> Void
    private let hideSaveAsTemplate: Bool

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = .clear
        return t
    }()

    init(checklist: Checklist, onSave: @escaping (Checklist) -> Void, onDelete: @escaping () -> Void, hideSaveAsTemplate: Bool = false) {
        self.checklist = checklist
        self.onSave = onSave
        self.onDelete = onDelete
        self.hideSaveAsTemplate = hideSaveAsTemplate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private lazy var doneButton: UIButton = makeThemedDoneButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        applyNavBarTheme()
        view.backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        view.tintColor = ThemeManager.shared.currentTheme.accentColor
        title = checklist.title
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TitleRowCell.self, forCellReuseIdentifier: TitleRowCell.reuseId)
        tableView.register(ItemEditCell.self, forCellReuseIdentifier: ItemEditCell.reuseId)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseId)
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
        applyTheme()
    }

    func applyTheme() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        view.tintColor = theme.accentColor
        applyNavBarTheme()
        tableView.reloadData()
    }

    private func applyNavBarTheme() {
        let theme = ThemeManager.shared.currentTheme
        guard let bar = navigationController?.navigationBar else { return }
        bar.tintColor = theme.accentColor
        let appearance = bar.standardAppearance
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
        onSave(checklist)
        dismiss(animated: false)
    }

    private func showAddItemAlert() {
        let theme = ThemeManager.shared.currentTheme
        let alert = UIAlertController(title: "New item", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Item title"
            textField.textColor = theme.textPrimaryColor
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self, let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else { return }
            self.checklist.items.append(ChecklistItem(id: UUID(), title: title, isChecked: false))
            self.tableView.reloadData()
        })
        present(alert, animated: false)
    }

    private func showSaveAsTemplateAlert() {
        let alert = UIAlertController(title: "Save as template", message: "This list will appear in Templates and can be reused.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            ChecklistTemplates.addUserTemplate(self.checklist)
            self.onSave(self.checklist)
            self.dismiss(animated: false)
        })
        present(alert, animated: false)
    }

    private func showDeleteListConfirm() {
        let alert = UIAlertController(title: "Delete list", message: "This list will be removed.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.onDelete()
            self?.dismiss(animated: false)
        })
        present(alert, animated: false)
    }

    private func showIconPicker() {
        let picker = IconPickerViewController(icons: kListIconNames, selectedName: checklist.iconName ?? kListDefaultIconName, theme: ThemeManager.shared.currentTheme) { [weak self] name in
            self?.checklist.iconName = name
            self?.reloadTitleRow()
        }
        let nav = UINavigationController(rootViewController: picker)
        present(nav, animated: true)
    }

    private func showColorPicker() {
        let sheet = UIAlertController(title: "List color", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Choose color…", style: .default) { [weak self] _ in
            self?.presentColorPicker()
        })
        sheet.addAction(UIAlertAction(title: "Use theme default", style: .default) { [weak self] _ in
            self?.checklist.accentColorHex = nil
            self?.reloadTitleRow()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(sheet, animated: true)
    }

    private func presentColorPicker() {
        let theme = ThemeManager.shared.currentTheme
        let initialColor = checklist.accentColorHex.flatMap { UIColor.from(hex: $0) } ?? theme.accentColor
        let picker = UIColorPickerViewController()
        picker.selectedColor = initialColor
        picker.delegate = self
        present(picker, animated: true)
    }

    private func reloadTitleRow() {
        let titleRow = IndexPath(row: 0, section: 0)
        guard tableView.numberOfSections > titleRow.section,
              tableView.numberOfRows(inSection: titleRow.section) > titleRow.row else { return }
        tableView.reloadRows(at: [titleRow], with: .none)
    }

    private func itemIndexPath(for cell: UITableViewCell) -> IndexPath? {
        guard let indexPath = tableView.indexPath(for: cell),
              indexPath.section == 1,
              checklist.items.indices.contains(indexPath.row) else { return nil }
        return indexPath
    }
}

extension ChecklistDetailViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        checklist.accentColorHex = color.hexString
        reloadTitleRow()
    }
}

extension ChecklistDetailViewController: UITableViewDelegate, UITableViewDataSource {

    private var saveAsTemplateSection: Int { hideSaveAsTemplate ? -1 : 3 }
    private var deleteSection: Int { hideSaveAsTemplate ? 3 : 4 }

    func numberOfSections(in tableView: UITableView) -> Int {
        hideSaveAsTemplate ? 4 : 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return checklist.items.count
        case 2: return 1
        case 3: return 1
        case 4: return hideSaveAsTemplate ? 0 : 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theme = ThemeManager.shared.currentTheme
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: TitleRowCell.reuseId, for: indexPath) as! TitleRowCell
            let listAccent = checklist.accentColorHex.flatMap { UIColor.from(hex: $0) } ?? theme.accentColor
            cell.configure(
                title: checklist.title,
                iconName: checklist.iconName ?? kListDefaultIconName,
                accentColor: listAccent,
                theme: theme,
                onTitleChange: { [weak self] newTitle in self?.checklist.title = newTitle },
                onIconTap: { [weak self] in self?.showIconPicker() },
                onColorTap: { [weak self] in self?.showColorPicker() }
            )
            return cell
        case 1:
            guard checklist.items.indices.contains(indexPath.row) else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemEditCell.reuseId, for: indexPath) as! ItemEditCell
            let item = checklist.items[indexPath.row]
            let listAccent = checklist.accentColorHex.flatMap { UIColor.from(hex: $0) } ?? theme.accentColor
            cell.configure(item: item, theme: theme, accentColor: listAccent, onToggle: { [weak self, weak cell] in
                guard let self = self, let cell = cell, let currentIndexPath = self.itemIndexPath(for: cell) else { return }
                self.checklist.items[currentIndexPath.row].isChecked.toggle()
                self.tableView.reloadRows(at: [currentIndexPath], with: .none)
            }, onTextChange: { [weak self, weak cell] text in
                guard let self = self, let cell = cell, let cellIndexPath = self.itemIndexPath(for: cell) else { return }
                self.checklist.items[cellIndexPath.row].title = text
            }, onDelete: { [weak self, weak cell] in
                guard let self = self, let cell = cell, let currentIndexPath = self.itemIndexPath(for: cell) else { return }
                self.checklist.items.remove(at: currentIndexPath.row)
                self.tableView.deleteRows(at: [currentIndexPath], with: .none)
            })
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseId, for: indexPath) as! ButtonCell
            cell.configure(title: "Add item", icon: "plus.circle.fill", theme: theme)
            return cell
        case 3:
            if hideSaveAsTemplate {
                let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseId, for: indexPath) as! ButtonCell
                cell.configure(title: "Delete list", icon: "trash", theme: theme, destructive: true)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseId, for: indexPath) as! ButtonCell
                cell.configure(title: "Save as template", icon: "square.and.arrow.down", theme: theme)
                return cell
            }
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseId, for: indexPath) as! ButtonCell
            cell.configure(title: "Delete list", icon: "trash", theme: theme, destructive: true)
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 2 { showAddItemAlert() }
        if indexPath.section == saveAsTemplateSection { showSaveAsTemplateAlert() }
        if indexPath.section == deleteSection { showDeleteListConfirm() }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

private final class TitleRowCell: UITableViewCell {
    static let reuseId = "TitleRowCell"
    private var onTextChange: ((String) -> Void)?
    private var onIconTap: (() -> Void)?
    private var onColorTap: (() -> Void)?

    private let iconButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private let textField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.font = .systemFont(ofSize: 17)
        t.borderStyle = .none
        return t
    }()
    private let colorCircleView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.cgColor
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(iconButton)
        contentView.addSubview(textField)
        contentView.addSubview(colorCircleView)
        NSLayoutConstraint.activate([
            iconButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kInset),
            iconButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconButton.widthAnchor.constraint(equalToConstant: 32),
            iconButton.heightAnchor.constraint(equalToConstant: 32),
            textField.leadingAnchor.constraint(equalTo: iconButton.trailingAnchor, constant: 10),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: colorCircleView.leadingAnchor, constant: -12),
            colorCircleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kInset),
            colorCircleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorCircleView.widthAnchor.constraint(equalToConstant: 32),
            colorCircleView.heightAnchor.constraint(equalToConstant: 32),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])
        iconButton.addTarget(self, action: #selector(iconTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        colorCircleView.isUserInteractionEnabled = true
        colorCircleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(colorTapped)))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, iconName: String, accentColor: UIColor, theme: AppTheme, onTitleChange: @escaping (String) -> Void, onIconTap: @escaping () -> Void, onColorTap: @escaping () -> Void) {
        self.onTextChange = onTitleChange
        self.onIconTap = onIconTap
        self.onColorTap = onColorTap
        textField.text = title
        textField.placeholder = "List title"
        textField.textColor = theme.textPrimaryColor
        textField.tintColor = accentColor
        iconButton.setImage(UIImage(systemName: iconName), for: .normal)
        iconButton.tintColor = accentColor
        colorCircleView.backgroundColor = accentColor
    }

    @objc private func editingChanged() { onTextChange?(textField.text ?? "") }
    @objc private func iconTapped() { onIconTap?() }
    @objc private func colorTapped() { onColorTap?() }
}

private final class ItemEditCell: UITableViewCell {
    static let reuseId = "ItemEditCell"
    private let checkButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private let textField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.font = .systemFont(ofSize: 16)
        t.borderStyle = .none
        return t
    }()
    private let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private var onToggle: (() -> Void)?
    private var onTextChange: ((String) -> Void)?
    private var onDelete: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(checkButton)
        contentView.addSubview(textField)
        contentView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kInset),
            checkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: 28),
            checkButton.heightAnchor.constraint(equalToConstant: 28),
            textField.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kInset),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 28),
            deleteButton.heightAnchor.constraint(equalToConstant: 28),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        checkButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(item: ChecklistItem, theme: AppTheme, accentColor: UIColor, onToggle: @escaping () -> Void, onTextChange: @escaping (String) -> Void, onDelete: @escaping () -> Void) {
        self.onToggle = onToggle
        self.onTextChange = onTextChange
        self.onDelete = onDelete
        checkButton.setImage(UIImage(systemName: item.isChecked ? "checkmark.circle.fill" : "circle"), for: .normal)
        checkButton.tintColor = accentColor
        textField.text = item.title
        textField.textColor = item.isChecked ? theme.textSecondaryColor : theme.textPrimaryColor
        deleteButton.tintColor = theme.textSecondaryColor
    }
    @objc private func toggleTapped() { onToggle?() }
    @objc private func editingChanged() { onTextChange?(textField.text ?? "") }
    @objc private func deleteTapped() { onDelete?() }
}

private final class ButtonCell: UITableViewCell {
    static let reuseId = "ButtonCell"
    private let iconView = UIImageView()
    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .default
        iconView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconView)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kInset),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(title: String, icon: String, theme: AppTheme, destructive: Bool = false) {
        label.text = title
        iconView.image = UIImage(systemName: icon)
        label.textColor = destructive ? .systemRed : theme.accentColor
        iconView.tintColor = destructive ? .systemRed : theme.accentColor
    }
}
