import UIKit
import PhotosUI

protocol ProfileImagePickerDelegate: AnyObject {
    func didSelectImage(_ image: UIImage)
    func didRemoveImage()
}

class ProfileImagePickerViewController: UIViewController {
    
    weak var delegate: ProfileImagePickerDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile Photo"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose from Gallery", for: .normal)
        button.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        button.tintColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Remove Photo", for: .normal)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Add property to track if user has a profile photo
    var hasExistingPhoto: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupGesture()
        updateRemoveButtonVisibility()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(galleryButton)
        containerView.addSubview(removeButton)
        containerView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            galleryButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            galleryButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            galleryButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            galleryButton.heightAnchor.constraint(equalToConstant: 44),
            
            removeButton.topAnchor.constraint(equalTo: galleryButton.bottomAnchor, constant: 16),
            removeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            removeButton.heightAnchor.constraint(equalToConstant: 44),
            
            cancelButton.topAnchor.constraint(equalTo: removeButton.bottomAnchor, constant: 24),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupActions() {
        galleryButton.addTarget(self, action: #selector(galleryTapped), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    private func updateRemoveButtonVisibility() {
        // Show remove button only if user has an existing photo
        removeButton.isHidden = !hasExistingPhoto
        
        // Update constraints based on visibility
        if hasExistingPhoto {
            cancelButton.topAnchor.constraint(equalTo: removeButton.bottomAnchor, constant: 24).isActive = true
        } else {
            cancelButton.topAnchor.constraint(equalTo: galleryButton.bottomAnchor, constant: 24).isActive = true
        }
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func galleryTapped() {
        presentPhotoPicker()
    }
    
    @objc private func removeTapped() {
        delegate?.didRemoveImage()
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ProfileImagePickerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    self?.processSelectedImage(image)
                } else if let error = error {
                    print("❌ Error loading image: \(error)")
                }
            }
        }
    }
    
    private func processSelectedImage(_ image: UIImage) {
        // Resize/crop the image if needed
        let resizedImage = resizeImage(image, targetSize: CGSize(width: 400, height: 400))
        delegate?.didSelectImage(resizedImage)
        dismiss(animated: true)
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ProfileImagePickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
}
