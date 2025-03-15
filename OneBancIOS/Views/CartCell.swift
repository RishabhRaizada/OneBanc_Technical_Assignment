import UIKit

class CartCell: UITableViewCell {
    static let identifier = "CartCell"
    
    var removeHandler: (() -> Void)?
    
    private let itemNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Remove", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    // ✅ Configure Cell
    func configure(with item: Item) {
        itemNameLabel.text = item.name
        priceLabel.text = "₹\(item.price)"
        
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        
        setupLayout()
    }
    
    @objc private func removeTapped() {
        removeHandler?()
    }
    
    private func setupLayout() {
        contentView.addSubview(itemNameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(removeButton)
        
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            itemNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            priceLabel.leadingAnchor.constraint(equalTo: itemNameLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: itemNameLabel.bottomAnchor, constant: 4),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
