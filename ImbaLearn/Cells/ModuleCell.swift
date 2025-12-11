import UIKit

class ModuleCell: UITableViewCell {
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var privateIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "lock.fill")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, cardCountLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [labelsStack, privateIcon])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(mainStack)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 16
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            privateIcon.widthAnchor.constraint(equalToConstant: 20),
            privateIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Configuration
    func configure(with module: ModuleResponse, backgroundColor: UIColor, termsCount: Int? = nil) {
        titleLabel.text = module.title
        
        // Use the provided terms count or fall back to progress data
        if let termsCount = termsCount, termsCount > 0 {
            cardCountLabel.text = "\(termsCount) term\(termsCount == 1 ? "" : "s")"
        } else {
            // Fall back to progress data if no terms count provided
            let total = module.progress?.total ?? 0
            cardCountLabel.text = "\(total) term\(total == 1 ? "" : "s")"
        }
        
        // Show lock icon for private modules
        privateIcon.isHidden = !module.isPrivate
        
        contentView.backgroundColor = backgroundColor
    }
}
