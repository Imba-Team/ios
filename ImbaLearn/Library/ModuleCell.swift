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
    
    // MARK: - Container View for Shadow and Spacing
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.applyShadowForView()
        return view
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
        contentView.backgroundColor = .clear
        
        // Add container view to content view
        contentView.addSubview(containerView)
        
        // Add main stack to container view
        containerView.addSubview(mainStack)
    }
    
    private func setupConstraints() {
        let containerPadding: CGFloat = 4
        let contentPadding: CGFloat = 16
        
        NSLayoutConstraint.activate([
            // Container view constraints with spacing from cell edges
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerPadding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerPadding),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            
            // Main stack constraints inside container
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: contentPadding),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -contentPadding),
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // Private icon size constraints
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
        
        // Set background color on container view instead of contentView
        containerView.backgroundColor = backgroundColor
    }
    
    // MARK: - Prepare for Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset container view properties if needed
        containerView.backgroundColor = .white
        privateIcon.isHidden = true
    }
}
