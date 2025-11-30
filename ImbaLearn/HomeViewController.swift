import UIKit

struct StudySet {
    let id: String
    let name: String
    let iconName: String
    let progress: Float // 0.0 to 1.0
    let lastAccessed: Date?
    let isStarted: Bool
    let cardCount: Int
}

class HomeViewController: BaseViewController {
    
    // MARK: - Sample Data
    private var continueLearningSets: [StudySet] = [
        StudySet(id: "1", name: "Spanish Vocabulary", iconName: "book.fill", progress: 0.75, lastAccessed: Date(), isStarted: true, cardCount: 12),
        StudySet(id: "2", name: "Math Formulas", iconName: "function", progress: 0.4, lastAccessed: Date().addingTimeInterval(-86400), isStarted: true, cardCount: 22),
        StudySet(id: "3", name: "Biology Terms", iconName: "leaf.fill", progress: 0.2, lastAccessed: Date().addingTimeInterval(-172800), isStarted: true, cardCount: 33)
    ]
    
    private var allModules: [StudySet] = [
        StudySet(id: "5", name: "Chemistry Basics", iconName: "text.book.closed", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 9),
        StudySet(id: "6", name: "French Verbs", iconName: "text.book.closed", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 12),
        StudySet(id: "7", name: "Physics Laws", iconName: "text.book.closed", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 11),
        StudySet(id: "8", name: "Literature Terms", iconName: "text.book.closed", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 15),
        StudySet(id: "9", name: "Geography", iconName: "text.book.closed", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 22),
        StudySet(id: "10", name: "Programming", iconName: "text.book.closed", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 10)
    ]
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ContinueLearningCell.self, forCellReuseIdentifier: "ContinueLearningCell")
        tableView.register(AllModulesCell.self, forCellReuseIdentifier: "AllModulesCell")
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "SectionHeaderView")
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        filterContinueLearningSets()
    }
    
    private func filterContinueLearningSets() {
        let startedSets = continueLearningSets.filter { $0.isStarted }
        if startedSets.isEmpty {
            continueLearningSets = []
        } else {
            continueLearningSets = startedSets
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        title = "Home"
        
        tableView.delegate = self
        tableView.dataSource = self
    
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func continueButtonTapped(_ sender: UIButton) {
        print("Continue button tapped for set at index: \(sender.tag)")
    }
}

// MARK: - UITableView DataSource & Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Section 0: Continue Learning
        // Sections 1 to N: Each All Module is in its own section
        return 1 + allModules.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // Continue Learning section
            return continueLearningSets.isEmpty ? 0 : 1
        } else { // All Modules sections (each module gets its own section)
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // Continue Learning section
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContinueLearningCell", for: indexPath) as! ContinueLearningCell
            cell.configure(with: continueLearningSets)
            cell.continueButtonTapped = { [weak self] index in
                self?.continueButtonTappedForSet(at: index)
            }
            return cell
            
        } else { // All Modules sections
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllModulesCell", for: indexPath) as! AllModulesCell
            let studySet = allModules[indexPath.section - 1] // Subtract 1 because section 0 is Continue Learning
            cell.configure(with: studySet)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return continueLearningSets.isEmpty ? 0 : 260
        } else {
            return 90 // Height for each module cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderView") as? SectionHeaderView else {
            return nil
        }
        
        if section == 0 {
            header.configure(title: "Continue Learning", isHidden: continueLearningSets.isEmpty)
        } else if section == 1 { // Only show "All Modules" header once
            header.configure(title: "All Modules")
        } else {
            header.configure(title: "") // Empty header for other module sections
            header.isHidden = true
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return continueLearningSets.isEmpty ? 0 : 60
        } else if section == 1 {
            return 60 // Height for "All Modules" header
        } else {
            return 2 // SPACE BETWEEN CELLS - This is the key change!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section > 0 { // All Modules sections
            let studySet = allModules[indexPath.section - 1]
            print("Selected module: \(studySet.name)")
            // TODO: Navigate to module detail
        }
    }
    
    private func continueButtonTappedForSet(at index: Int) {
        guard index < continueLearningSets.count else { return }
        let studySet = continueLearningSets[index]
        print("Continue button tapped for: \(studySet.name)")
    }
}

// MARK: - ContinueLearningCell (Contains Collection View)
class ContinueLearningCell: UITableViewCell {
    
    private var studySets: [StudySet] = []
    var continueButtonTapped: ((Int) -> Void)?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 380, height: 200)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(StudySetCell.self, forCellWithReuseIdentifier: "StudySetCell")
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        contentView.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configure(with studySets: [StudySet]) {
        self.studySets = studySets
        collectionView.reloadData()
    }
}

// MARK: - ContinueLearningCell CollectionView Delegate
extension ContinueLearningCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return studySets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudySetCell", for: indexPath) as? StudySetCell else {
            return UICollectionViewCell()
        }
        
        let studySet = studySets[indexPath.item]
        cell.configure(with: studySet)
        cell.continueButton.tag = indexPath.item
        cell.continueButton.addTarget(self, action: #selector(continueButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc private func continueButtonTapped(_ sender: UIButton) {
        continueButtonTapped?(sender.tag)
    }
    
    // Snap to center when scrolling stops
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}

// MARK: - SectionHeaderView
class SectionHeaderView: UITableViewHeaderFooterView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .text
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .background
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(title: String, isHidden: Bool = false) {
        titleLabel.text = title
        contentView.isHidden = isHidden
    }
}
