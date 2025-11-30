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
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .greenButton
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private lazy var percentageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .text
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var questionsDoneLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
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
        
        contentView.addSubviews(titleLabel, progressView, percentageLabel, questionsDoneLabel, continueButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title Label - top left
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Progress View - under title
            progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            // Percentage Label - under progress
            percentageLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            percentageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // Questions Done Label - next to percentage
            questionsDoneLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            questionsDoneLabel.leadingAnchor.constraint(equalTo: percentageLabel.trailingAnchor, constant: 4),
            questionsDoneLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            // Continue Button - bottom, full width
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configure(with studySet: StudySet) {
        titleLabel.text = studySet.name
        progressView.progress = studySet.progress
        
        let percentage = Int(studySet.progress * 100)
        percentageLabel.text = "\(percentage)%"
        
        let completedCards = Int(Float(studySet.cardCount) * studySet.progress)
        questionsDoneLabel.text = "\(completedCards) of \(studySet.cardCount) questions done"
        
        // Update button title based on progress
        if studySet.progress == 0 {
            continueButton.setTitle("Start Learning", for: .normal)
        } else if studySet.progress == 1.0 {
            continueButton.setTitle("Completed", for: .normal)
            continueButton.backgroundColor = .systemGray4
            continueButton.isEnabled = false
        } else {
            continueButton.setTitle("Continue", for: .normal)
        }
    }
}
