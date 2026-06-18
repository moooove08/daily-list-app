import UIKit

enum AppTab: Int, CaseIterable {
    case myLists = 0
    case templates = 1
    case settings = 2
}

private let kTabBarHeight: CGFloat = 56
private let kSavedListsKey = "RootViewController.savedLists"

final class RootViewController: UIViewController {

    var lists: [Checklist] = loadSavedLists() {
        didSet { saveLists() }
    }
    var selectedTab: AppTab = .myLists {
        didSet {
            if selectedTab != oldValue {
                switchToTab(selectedTab)
            }
        }
    }

    private let containerView = UIView()
    private let customTabBar = CustomTabBarView()
    private lazy var myListsVC: MyListsViewController = {
        let vc = MyListsViewController(
            onListsChanged: { [weak self] newLists in self?.lists = newLists },
            onAddList: { [weak self] in self?.showAddListAlert() },
            onDeleteList: { [weak self] index in
                guard let self = self, index >= 0, index < self.lists.count else { return }
                self.lists.remove(at: index)
                self.saveLists()
                self.myListsVC.updateLists(self.lists)
            },
            onListCompleted: { [weak self] index in
                self?.archiveCompletedList(at: index)
            }
        )
        vc.onOpenDetail = { [weak self] index in self?.openDetailForList(at: index) }
        return vc
    }()
    private let templatesVC = TemplatesViewController()
    private let settingsVC = SettingsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.currentTheme.backgroundColor

        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.delegate = self
        customTabBar.selectedIndex = selectedTab.rawValue
        customTabBar.updateAppearance(theme: ThemeManager.shared.currentTheme)
        view.addSubview(customTabBar)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: customTabBar.topAnchor),
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: kTabBarHeight)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
        switchToTab(selectedTab)
    }

    private static func loadSavedLists() -> [Checklist] {
        guard let data = UserDefaults.standard.data(forKey: kSavedListsKey),
              let decoded = try? JSONDecoder().decode([Checklist].self, from: data) else { return [] }
        return decoded
    }

    private func saveLists() {
        guard let data = try? JSONEncoder().encode(lists) else { return }
        UserDefaults.standard.set(data, forKey: kSavedListsKey)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }

    @objc private func themeDidChange() {
        view.backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        customTabBar.updateAppearance(theme: ThemeManager.shared.currentTheme)
        myListsVC.applyTheme()
        templatesVC.applyTheme()
        settingsVC.applyTheme()
    }

    private func switchToTab(_ tab: AppTab) {
        customTabBar.selectedIndex = tab.rawValue
        let child: UIViewController
        switch tab {
        case .myLists:
            myListsVC.updateLists(lists)
            child = myListsVC
        case .templates:
            templatesVC.onSelectTemplate = { [weak self] (template: Checklist) in
                guard let self = self else { return }
                let copy = Checklist(
                    id: UUID(),
                    title: template.title,
                    items: template.items.map { ChecklistItem(id: UUID(), title: $0.title, isChecked: false) },
                    iconName: template.iconName,
                    accentColorHex: template.accentColorHex
                )
                self.lists.append(copy)
                self.myListsVC.updateLists(self.lists)
                self.selectedTab = .myLists
            }
            child = templatesVC
        case .settings:
            settingsVC.onOpenArchive = { [weak self] in self?.showArchive() }
            child = settingsVC
        }
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        addChild(child)
        child.view.frame = containerView.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }

    private func showAddListAlert() {
        let alert = UIAlertController(title: "New List", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "List title"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self, let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else { return }
            self.lists.append(Checklist(id: UUID(), title: title, items: []))
            self.saveLists()
            self.myListsVC.updateLists(self.lists)
            self.myListsVC.openDetailForList(at: self.lists.count - 1)
        })
        present(alert, animated: false)
    }

    private func archiveCompletedList(at index: Int) {
        guard index >= 0, index < lists.count else { return }
        let list = lists[index]
        ChecklistArchive.add(list)
        lists.remove(at: index)
        saveLists()
        myListsVC.updateListsRemovingRow(at: index, newLists: lists)
    }

    private func showArchive() {
        let archive = ArchiveViewController()
        let nav = UINavigationController(rootViewController: archive)
        present(nav, animated: true)
    }

    private func openDetailForList(at index: Int) {
        guard index >= 0, index < lists.count else { return }
        let selectedList = lists[index]
        let selectedListID = selectedList.id
        let detail = ChecklistDetailViewController(
            checklist: selectedList,
            onSave: { [weak self] updated in
                guard let self = self,
                      let currentIndex = self.lists.firstIndex(where: { $0.id == selectedListID }) else { return }
                self.lists[currentIndex] = updated
                self.saveLists()
                self.myListsVC.updateLists(self.lists)
            },
            onDelete: { [weak self] in
                guard let self = self,
                      let currentIndex = self.lists.firstIndex(where: { $0.id == selectedListID }) else { return }
                self.lists.remove(at: currentIndex)
                self.myListsVC.updateLists(self.lists)
            }
        )
        let nav = UINavigationController(rootViewController: detail)
        present(nav, animated: false)
    }
}

extension RootViewController: CustomTabBarViewDelegate {
    func customTabBarView(_ view: CustomTabBarView, didSelectIndex index: Int) {
        guard let tab = AppTab(rawValue: index) else { return }
        selectedTab = tab
    }
}
