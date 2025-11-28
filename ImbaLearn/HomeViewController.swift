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
        StudySet(id: "3", name: "Biology Terms", iconName: "leaf.fill", progress: 0.2, lastAccessed: Date().addingTimeInterval(-172800), isStarted: true, cardCount: 33),
        StudySet(id: "4", name: "History Dates", iconName: "clock.fill", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 11)
    ]
    
    private var allModules: [StudySet] = [
        StudySet(id: "5", name: "Chemistry Basics", iconName: "atom", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 9),
        StudySet(id: "6", name: "French Verbs", iconName: "text.book.closed", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 12),
        StudySet(id: "7", name: "Physics Laws", iconName: "bolt.fill", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 11),
        StudySet(id: "8", name: "Literature Terms", iconName: "bookmark.fill", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 15),
        StudySet(id: "9", name: "Geography", iconName: "globe", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 22),
        StudySet(id: "10", name: "Programming", iconName: "laptopcomputer", progress: 0.0, lastAccessed: nil, isStarted: false, cardCount: 10)
    ]
    
    // MARK: - UI Elements
    
    private lazy var continueLearningLabel: UILabel = {
        let label = UILabel()
        label.text = "Continue Learning"
        label.textColor = .color1
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var continueLearningCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 380, height: 200)
        layout.minimumLineSpacing = 16
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(StudySetCell.self, forCellWithReuseIdentifier: "StudySetCell")
        return collectionView
    }()
    
    private lazy var allModulesLabel: UILabel = {
        let label = UILabel()
        label.text = "All Modules"
        label.textColor = .color1
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var allModulesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // Changed to horizontal
        layout.itemSize = CGSize(width: 380, height: 80) // Small height, wider for horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(AllModulesCell.self, forCellWithReuseIdentifier: "AllModulesCell")
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        filterContinueLearningSets()
    }
    
    private func filterContinueLearningSets() {
        // Filter only started sets for continue learning
        let startedSets = continueLearningSets.filter { $0.isStarted }
        if startedSets.isEmpty {
            // If no started sets, hide the continue learning section
            continueLearningLabel.isHidden = true
            continueLearningCollectionView.isHidden = true
        } else {
            continueLearningSets = startedSets
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        title = "Home"
        
        continueLearningCollectionView.delegate = self
        continueLearningCollectionView.dataSource = self
        allModulesCollectionView.delegate = self
        allModulesCollectionView.dataSource = self
        
        view.addSubviews(continueLearningLabel, continueLearningCollectionView, allModulesLabel, allModulesCollectionView)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            // Continue Learning Label
            continueLearningLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            continueLearningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            continueLearningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Continue Learning Collection View
            continueLearningCollectionView.topAnchor.constraint(equalTo: continueLearningLabel.bottomAnchor, constant: 16),
            continueLearningCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            continueLearningCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            continueLearningCollectionView.heightAnchor.constraint(equalToConstant: 220),
            
            // All Modules Label
            allModulesLabel.topAnchor.constraint(equalTo: continueLearningCollectionView.bottomAnchor, constant: 32),
            allModulesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            allModulesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // All Modules Collection View
            allModulesCollectionView.topAnchor.constraint(equalTo: allModulesLabel.bottomAnchor, constant: 16),
            allModulesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            allModulesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            allModulesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == continueLearningCollectionView {
            return continueLearningSets.count
        } else {
            return allModules.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == continueLearningCollectionView {
            // Use StudySetCell for Continue Learning section
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudySetCell", for: indexPath) as? StudySetCell else {
                return UICollectionViewCell()
            }
            
            let studySet = continueLearningSets[indexPath.item]
            cell.configure(with: studySet)
            cell.continueButton.tag = indexPath.item
            cell.continueButton.addTarget(self, action: #selector(continueButtonTapped(_:)), for: .touchUpInside)
            
            return cell
            
        } else {
            // Use AllModulesCell for All Modules section
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllModulesCell", for: indexPath) as? AllModulesCell else {
                return UICollectionViewCell()
            }
            
            let studySet = allModules[indexPath.item]
            cell.configure(with: studySet)
            
            return cell
        }
    }
    
    @objc private func continueButtonTapped(_ sender: UIButton) {
        // TODO: Navigate to learning page with cards
        print("Continue button tapped for set at index: \(sender.tag)")
        // You would navigate to your card learning view controller here
    }
}
