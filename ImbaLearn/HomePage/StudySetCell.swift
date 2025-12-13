import UIKit

class StudySetCell: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .text
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var questionsCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .greenButton
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        
        contentView.addSubviews(titleLabel, questionsCountLabel, continueButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title Label - top left
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Questions Count Label - under title
            questionsCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            questionsCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            questionsCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Continue Button - bottom, full width
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configure(with module: ModuleResponse, termsCount: Int = 0) { 
        titleLabel.text = module.title
        questionsCountLabel.text = "\(termsCount) questions"
        
        let hasProgress = (module.progress?.completed ?? 0) > 0
        
        if hasProgress {
            continueButton.setTitle("Continue", for: .normal)
            continueButton.backgroundColor = .greenButton
            continueButton.isEnabled = true
        } else {
            continueButton.setTitle("Start Learning", for: .normal)
            continueButton.backgroundColor = .greenButton
            continueButton.isEnabled = true
        }
    }
}
