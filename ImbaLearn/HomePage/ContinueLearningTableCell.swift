//
//  ContinueLearningTableCell.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 12.12.25.
//

import UIKit

// MARK: - ContinueLearningTableCell (Contains Collection View)
class ContinueLearningTableCell: UITableViewCell {
    
    var continueButtonTapped: ((Int) -> Void)?
    private var modules: [ModuleResponse] = []
    private var viewModel: HomeViewModel?
      
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
    
    func configure(with modules: [ModuleResponse], viewModel: HomeViewModel? = nil) {
            self.modules = modules
            self.viewModel = viewModel
            collectionView.reloadData()
        }
    }

// MARK: - ContinueLearningTableCell CollectionView Delegate
extension ContinueLearningTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudySetCell", for: indexPath) as! StudySetCell
          let module = modules[indexPath.item]
          let termsCount = viewModel?.getTermsCount(for: module.id) ?? 0
            
          cell.configure(with: module, termsCount: termsCount)
            
          cell.continueButton.tag = indexPath.item
          cell.continueButton.addTarget(self, action: #selector(continueButtonAction(_:)), for: .touchUpInside)
          
          return cell
      }
      
      @objc private func continueButtonAction(_ sender: UIButton) {
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
