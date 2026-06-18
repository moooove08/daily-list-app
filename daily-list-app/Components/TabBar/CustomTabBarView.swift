import UIKit

private let kTabBarHeight: CGFloat = 56
private let kHighlightCornerRadius: CGFloat = 18
private let kHighlightPadding: CGFloat = 8

protocol CustomTabBarViewDelegate: AnyObject {
    func customTabBarView(_ view: CustomTabBarView, didSelectIndex index: Int)
}

final class CustomTabBarView: UIView {

    weak var delegate: CustomTabBarViewDelegate?

    var selectedIndex: Int = 0 {
        didSet {
            setNeedsDisplay()
            refreshTabItemColors()
        }
    }

    var tabBarBackgroundColor: UIColor = .systemGray6 {
        didSet { setNeedsDisplay() }
    }

    var tabHighlightColor: UIColor = .systemBlue {
        didSet { setNeedsDisplay() }
    }

    var textPrimaryColor: UIColor = .label
    var textSecondaryColor: UIColor = .secondaryLabel
    var accentColor: UIColor = .systemBlue

    private let tabCount = 3
    private let iconNames = ["list.bullet", "square.stack", "gearshape"]
    private let tabTitles = ["My Lists", "Templates", "Settings"]
    private var itemContainers: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        setupTabItems()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isOpaque = false
        backgroundColor = .clear
        setupTabItems()
    }

    override func draw(_ rect: CGRect) {
        let backgroundPath = UIBezierPath(rect: rect)
        tabBarBackgroundColor.setFill()
        backgroundPath.fill()

        let segmentWidth = rect.width / CGFloat(tabCount)
        let centerX = segmentWidth * (CGFloat(selectedIndex) + 0.5)
        let highlightWidth = segmentWidth - kHighlightPadding * 2
        let highlightHeight: CGFloat = 48
        let highlightRect = CGRect(
            x: centerX - highlightWidth / 2,
            y: rect.midY - highlightHeight / 2,
            width: highlightWidth,
            height: highlightHeight
        )
        let highlightPath = UIBezierPath(roundedRect: highlightRect, cornerRadius: kHighlightCornerRadius)
        tabHighlightColor.setFill()
        highlightPath.fill()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width / CGFloat(tabCount)
        for (i, container) in itemContainers.enumerated() {
            container.frame = CGRect(x: CGFloat(i) * w, y: 0, width: w, height: bounds.height)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x
        let segmentWidth = bounds.width / CGFloat(tabCount)
        let index = min(Int(x / segmentWidth), tabCount - 1)
        let clamped = max(0, index)
        if clamped != selectedIndex {
            selectedIndex = clamped
            delegate?.customTabBarView(self, didSelectIndex: clamped)
        }
    }

    private func setupTabItems() {
        for i in 0..<tabCount {
            let container = UIView()
            container.isUserInteractionEnabled = false

            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
            let imageView = UIImageView(image: UIImage(systemName: iconNames[i], withConfiguration: config))
            imageView.tintColor = textSecondaryColor
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = tabTitles[i]
            label.font = .systemFont(ofSize: 10, weight: .regular)
            label.textColor = textSecondaryColor
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(imageView)
            container.addSubview(label)
            addSubview(container)
            itemContainers.append(container)

            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4)
            ])
        }
    }

    func updateAppearance(theme: AppTheme) {
        textPrimaryColor = theme.textPrimaryColor
        textSecondaryColor = theme.textSecondaryColor
        accentColor = theme.accentColor
        tabBarBackgroundColor = theme.tabBarBackgroundColor
        tabHighlightColor = theme.tabHighlightColor
        refreshTabItemColors()
        setNeedsDisplay()
    }

    private func refreshTabItemColors() {
        for (i, container) in itemContainers.enumerated() {
            let imageView = container.subviews.compactMap { $0 as? UIImageView }.first
            let label = container.subviews.compactMap { $0 as? UILabel }.first
            let active = (i == selectedIndex)
            imageView?.tintColor = active ? accentColor : textSecondaryColor
            label?.textColor = active ? accentColor : textSecondaryColor
        }
    }
}
