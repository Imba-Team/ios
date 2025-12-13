//

import UIKit

class AllModulesCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .greenButton
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardsCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(cardsCountLabel)
    }
    
    private func setupConstraints() {
        let horizontalPadding: CGFloat = 20 // Left and right padding for the cell
        
        NSLayoutConstraint.activate([
            // Container View - with padding
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0.5),
            
            // Icon Image View
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            
            // Cards Count Label
            cardsCountLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            cardsCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            cardsCountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            cardsCountLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    func configure(with module: ModuleResponse, termsCount: Int? = nil) {
        
        iconImageView.image = UIImage(systemName: "text.book.closed")

        nameLabel.text = module.title
        // Use the provided terms count or fall back to progress data
        if let termsCount = termsCount, termsCount > 0 {
            cardsCountLabel.text = "\(termsCount) term\(termsCount == 1 ? "" : "s")"
        } else {
            // Fall back to progress data if no terms count provided
            let total = module.progress?.total ?? 0
            cardsCountLabel.text = "\(total) term\(total == 1 ? "" : "s")"
        }
    }
}
