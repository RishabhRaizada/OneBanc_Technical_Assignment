import UIKit

class CuisineCell: UICollectionViewCell {

    private let cuisineImageView = UIImageView()
    private let cuisineNameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        cuisineImageView.contentMode = .scaleAspectFill
        cuisineImageView.layer.cornerRadius = 10
        cuisineImageView.clipsToBounds = true
        cuisineImageView.translatesAutoresizingMaskIntoConstraints = false

        cuisineNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        cuisineNameLabel.textAlignment = .center
        cuisineNameLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 6

        contentView.addSubview(cuisineImageView)
        contentView.addSubview(cuisineNameLabel)

        NSLayoutConstraint.activate([
            cuisineImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cuisineImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cuisineImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cuisineImageView.heightAnchor.constraint(equalToConstant: 100),

            cuisineNameLabel.topAnchor.constraint(equalTo: cuisineImageView.bottomAnchor, constant: 8),
            cuisineNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            cuisineNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
    }

    func configure(with cuisine: Cuisine) {
        cuisineNameLabel.text = cuisine.cuisineName
        if let url = URL(string: cuisine.cuisineImageUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.cuisineImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
