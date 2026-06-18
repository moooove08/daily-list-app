import UIKit

private let kCardCornerRadius: CGFloat = 12
private let kCardInset: CGFloat = 16
private let kTitleFontSize: CGFloat = 28
private let kHeaderHorizontalInset: CGFloat = 20
private let kHeaderTopPadding: CGFloat = 12
private let kHeaderBottomPadding: CGFloat = 8

final class MyListsViewController: UIViewController {

    private let onListsChanged: ([Checklist]) -> Void
    private let onAddList: () -> Void
    private let onDeleteList: (Int) -> Void
    private let onListCompleted: ((Int) -> Void)?
    var onOpenDetail: ((Int) -> Void)?

    private var lists: [Checklist] = []

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
        l.text = "My Lists"
        return l
    }()

    private let newListButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("New list", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        return b
    }()

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.separatorStyle = .none
        t.backgroundColor = .clear
        return t
    }()

    init(onListsChanged: @escaping ([Checklist]) -> Void, onAddList: @escaping () -> Void, onDeleteList: @escaping (Int) -> Void, onListCompleted: ((Int) -> Void)? = nil) {
        self.onListsChanged = onListsChanged
        self.onAddList = onAddList
        self.onDeleteList = onDeleteList
        self.onListCompleted = onListCompleted
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        titleLabel.textColor = theme.textPrimaryColor
        newListButton.tintColor = theme.accentColor
        newListButton.addTarget(self, action: #selector(newListTapped), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChecklistCardCell.self, forCellReuseIdentifier: ChecklistCardCell.reuseId)
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(newListButton)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: kHeaderHorizontalInset),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: newListButton.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: kHeaderTopPadding),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -kHeaderBottomPadding),
            newListButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -kHeaderHorizontalInset),
            newListButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func updateLists(_ newLists: [Checklist]) {
        lists = newLists
        tableView.reloadData()
    }

    /// Removes one row with animation and updates data source (e.g. after archiving). Reloads remaining rows so their listIndex is correct.
    func updateListsRemovingRow(at index: Int, newLists: [Checklist]) {
        let currentRowCount = tableView.numberOfRows(inSection: 0)
        guard index >= 0, index < currentRowCount else {
            updateLists(newLists)
            return
        }
        lists = newLists
        tableView.performBatchUpdates {
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        } completion: { [weak self] _ in
            guard let self = self, !self.lists.isEmpty else { return }
            let indexPaths = (0..<self.lists.count).map { IndexPath(row: $0, section: 0) }
            self.tableView.reloadRows(at: indexPaths, with: .none)
        }
    }

    @objc private func newListTapped() {
        onAddList()
    }

    func applyTheme() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        titleLabel.textColor = theme.textPrimaryColor
        newListButton.tintColor = theme.accentColor
        tableView.reloadData()
    }

    private func showIconPicker(for listIndex: Int) {
        guard listIndex >= 0, listIndex < lists.count else { return }
        let list = lists[listIndex]
        let listID = list.id
        let currentIcon = list.iconName.flatMap { $0.isEmpty ? nil : $0 } ?? kListDefaultIconName
        let picker = IconPickerViewController(icons: kListIconNames, selectedName: currentIcon, theme: ThemeManager.shared.currentTheme) { [weak self] name in
            guard let self = self,
                  let currentIndex = self.lists.firstIndex(where: { $0.id == listID }) else { return }
            self.lists[currentIndex].iconName = name
            self.onListsChanged(self.lists)
            self.reloadListRow(at: currentIndex)
        }
        let nav = UINavigationController(rootViewController: picker)
        present(nav, animated: true)
    }

    func openDetailForList(at index: Int) {
        guard index >= 0, index < lists.count else { return }
        onOpenDetail?(index)
    }

    private func listIndexPath(for cell: UITableViewCell) -> IndexPath? {
        guard let indexPath = tableView.indexPath(for: cell),
              indexPath.section == 0,
              lists.indices.contains(indexPath.row) else { return nil }
        return indexPath
    }

    private func reloadListRow(at index: Int) {
        guard index >= 0,
              tableView.numberOfSections > 0,
              index < tableView.numberOfRows(inSection: 0) else { return }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
}

extension MyListsViewController {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, indexPath.section == 0, indexPath.row < lists.count {
            onDeleteList(indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        indexPath.section == 0 ? .delete : .none
    }
}

extension MyListsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard lists.indices.contains(indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: ChecklistCardCell.reuseId, for: indexPath) as! ChecklistCardCell
        let listIndex = indexPath.row
        cell.configure(
            checklist: lists[listIndex],
            listIndex: listIndex,
            theme: ThemeManager.shared.currentTheme,
            onToggle: { [weak self, weak cell] _, itemIndex in
                guard let self = self,
                      let cell = cell,
                      let currentIndexPath = self.listIndexPath(for: cell),
                      self.lists[currentIndexPath.row].items.indices.contains(itemIndex) else { return }
                let idx = currentIndexPath.row
                self.lists[idx].items[itemIndex].isChecked.toggle()
                let list = self.lists[idx]
                let allChecked = !list.items.isEmpty && list.items.allSatisfy(\.isChecked)
                if allChecked, let onCompleted = self.onListCompleted {
                    onCompleted(idx)
                    return
                }
                self.onListsChanged(self.lists)
                let path = IndexPath(row: idx, section: 0)
                let visibleCell = self.tableView.cellForRow(at: path) as? ChecklistCardCell
                visibleCell?.setItemChecked(itemIndex: itemIndex, checked: self.lists[idx].items[itemIndex].isChecked)
                visibleCell?.updateProgress(checked: list.items.filter(\.isChecked).count, total: list.items.count)
            },
            onEdit: { [weak self, weak cell] in
                guard let self = self, let cell = cell, let currentIndexPath = self.listIndexPath(for: cell) else { return }
                self.onOpenDetail?(currentIndexPath.row)
            },
            onTitleChange: { [weak self, weak cell] _, newTitle in
                guard let self = self, let cell = cell, let currentIndexPath = self.listIndexPath(for: cell) else { return }
                let idx = currentIndexPath.row
                self.lists[idx].title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                self.onListsChanged(self.lists)
            },
            onIconTap: { [weak self, weak cell] in
                guard let self = self, let cell = cell, let currentIndexPath = self.listIndexPath(for: cell) else { return }
                self.showIconPicker(for: currentIndexPath.row)
            }
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        // Переход на редактирование только по кнопке Edit в ячейке
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

private let kTitleRowHeight: CGFloat = 32
private let kProgressHeight: CGFloat = 4

private final class ChecklistCardCell: UITableViewCell {

    static let reuseId = "ChecklistCardCell"
    private var onToggle: ((Int, Int) -> Void)?
    private var onTitleChange: ((Int, String) -> Void)?
    private var listIndex: Int = 0
    private var itemRows: [ItemRowView] = []

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = kCardCornerRadius
        return v
    }()

    private let titleRowView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let listIconButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        return l
    }()

    private let titleTextField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.font = .systemFont(ofSize: 20, weight: .semibold)
        t.borderStyle = .none
        t.returnKeyType = .done
        t.isHidden = true
        return t
    }()

    private let editButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Edit", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let progressView: UIProgressView = {
        let p = UIProgressView(progressViewStyle: .default)
        p.translatesAutoresizingMaskIntoConstraints = false
        p.layer.cornerRadius = kProgressHeight / 2
        p.clipsToBounds = true
        return p
    }()

    private let progressCountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.text = "0/0"
        return l
    }()

    private let stackView: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 6
        return s
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardView)
        cardView.addSubview(titleRowView)
        titleRowView.addSubview(listIconButton)
        titleRowView.addSubview(titleLabel)
        titleRowView.addSubview(titleTextField)
        titleRowView.addSubview(editButton)
        cardView.addSubview(progressView)
        cardView.addSubview(progressCountLabel)
        cardView.addSubview(stackView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kCardInset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kCardInset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            titleRowView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleRowView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleRowView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleRowView.heightAnchor.constraint(equalToConstant: kTitleRowHeight),
            listIconButton.leadingAnchor.constraint(equalTo: titleRowView.leadingAnchor),
            listIconButton.centerYAnchor.constraint(equalTo: titleRowView.centerYAnchor),
            listIconButton.widthAnchor.constraint(equalToConstant: 28),
            listIconButton.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: listIconButton.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: titleRowView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: editButton.leadingAnchor, constant: -8),
            titleTextField.leadingAnchor.constraint(equalTo: listIconButton.trailingAnchor, constant: 10),
            titleTextField.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -8),
            titleTextField.centerYAnchor.constraint(equalTo: titleRowView.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: titleRowView.trailingAnchor),
            editButton.centerYAnchor.constraint(equalTo: titleRowView.centerYAnchor),
            editButton.heightAnchor.constraint(equalToConstant: kTitleRowHeight),
            progressView.topAnchor.constraint(equalTo: titleRowView.bottomAnchor, constant: 6),
            progressView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            progressView.trailingAnchor.constraint(equalTo: progressCountLabel.leadingAnchor, constant: -8),
            progressView.heightAnchor.constraint(equalToConstant: kProgressHeight),
            progressCountLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            progressCountLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            stackView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        listIconButton.addTarget(self, action: #selector(iconTapped), for: .touchUpInside)
        titleRowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTapped)))
        titleTextField.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var onEdit: (() -> Void)?
    private var onIconTap: (() -> Void)?
    @objc private func editTapped() { onEdit?() }
    @objc private func iconTapped() { onIconTap?() }

    @objc private func titleTapped() {
        guard titleTextField.isHidden else { return }
        titleTextField.text = titleLabel.text == " " ? "" : titleLabel.text
        titleLabel.isHidden = true
        titleTextField.isHidden = false
        titleTextField.becomeFirstResponder()
    }

    func configure(checklist: Checklist, listIndex: Int, theme: AppTheme, onToggle: @escaping (Int, Int) -> Void, onEdit: @escaping () -> Void, onTitleChange: @escaping (Int, String) -> Void, onIconTap: @escaping () -> Void) {
        self.onToggle = onToggle
        self.onEdit = onEdit
        self.onTitleChange = onTitleChange
        self.onIconTap = onIconTap
        self.listIndex = listIndex
        let listAccent = checklist.accentColorHex.flatMap { UIColor.from(hex: $0) } ?? theme.accentColor
        if checklist.accentColorHex != nil {
            cardView.backgroundColor = listAccent.withAlphaComponent(0.25)
        } else {
            cardView.backgroundColor = theme.cardColor
        }
        let iconName = checklist.iconName.flatMap { $0.isEmpty ? nil : $0 } ?? kListDefaultIconName
        listIconButton.setImage(UIImage(systemName: iconName), for: .normal)
        listIconButton.tintColor = listAccent
        titleLabel.text = checklist.title.isEmpty ? " " : checklist.title
        titleLabel.textColor = theme.textPrimaryColor
        titleTextField.textColor = theme.textPrimaryColor
        titleTextField.tintColor = listAccent
        editButton.tintColor = listAccent
        progressView.progressTintColor = listAccent
        progressView.trackTintColor = theme.textSecondaryColor.withAlphaComponent(0.3)
        progressCountLabel.textColor = theme.textSecondaryColor
        let total = max(1, checklist.items.count)
        let done = checklist.items.filter(\.isChecked).count
        progressView.setProgress(Float(done) / Float(total), animated: false)
        progressCountLabel.text = "\(done)/\(checklist.items.count)"
        titleLabel.isHidden = false
        titleTextField.isHidden = true
        itemRows = []
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (itemIndex, item) in checklist.items.enumerated() {
            let idx = listIndex
            let row = ItemRowView(item: item, theme: theme, accentColor: listAccent) { [weak self] in
                self?.onToggle?(idx, itemIndex)
            }
            itemRows.append(row)
            stackView.addArrangedSubview(row)
        }
    }

    func setItemChecked(itemIndex: Int, checked: Bool) {
        guard itemIndex >= 0, itemIndex < itemRows.count else { return }
        itemRows[itemIndex].setChecked(checked)
    }

    func updateProgress(checked: Int, total: Int) {
        let t = max(1, total)
        progressView.setProgress(Float(checked) / Float(t), animated: false)
        progressCountLabel.text = "\(checked)/\(total)"
    }
}

extension ChecklistCardCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let newTitle = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        titleLabel.text = newTitle.isEmpty ? " " : newTitle
        titleLabel.isHidden = false
        textField.isHidden = true
        onTitleChange?(listIndex, newTitle)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

private final class ItemRowView: UIView {
        private let iconView: UIImageView = {
            let i = UIImageView()
            i.translatesAutoresizingMaskIntoConstraints = false
            i.contentMode = .scaleAspectFit
            return i
        }()

        init(item: ChecklistItem, theme: AppTheme, accentColor: UIColor, onTap: @escaping () -> Void) {
            super.init(frame: .zero)
            iconView.image = UIImage(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
            iconView.tintColor = accentColor
            let label = UILabel()
            label.text = item.title
            label.font = .systemFont(ofSize: 15)
            label.textColor = theme.textSecondaryColor
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iconView)
            addSubview(label)
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
                iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 22),
                iconView.heightAnchor.constraint(equalToConstant: 22),
                label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                heightAnchor.constraint(equalToConstant: 28)
            ])
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
            addGestureRecognizer(tap)
            isUserInteractionEnabled = true
            self.onTap = onTap
        }
        private var onTap: (() -> Void)?
        @objc private func tapped() { onTap?() }
        func setChecked(_ checked: Bool) {
            iconView.image = UIImage(systemName: checked ? "checkmark.circle.fill" : "circle")
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
