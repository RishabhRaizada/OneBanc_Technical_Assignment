//
//  CuisineDetailViewController.swift
//  OneBancIOS
//
//  Created by Rishabh Raizada on 15/03/25.
//

import UIKit

class CuisineDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var cuisine: Cuisine
    private var items: [Item] = []
    private var collectionView: UICollectionView!

    init(cuisine: Cuisine) {
        self.cuisine = cuisine
        super.init(nibName: nil, bundle: nil)
        self.items = cuisine.items
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = cuisine.cuisineName
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupCartButton()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.width - 40) / 2, height: 240)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DishCell.self, forCellWithReuseIdentifier: "DishCell")

        view.addSubview(collectionView)
    }

    // ✅ "Go to Cart" Button
    private func setupCartButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "🛒 Go to Cart",
            style: .plain,
            target: self,
            action: #selector(openCart)
        )
    }

    @objc private func openCart() {
        let vc = CartViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // ✅ Fetch Filtered Data Using API
    private func fetchFilteredData(minPrice: String?, maxPrice: String?, minRating: String?) {
        ApiManager.shared.fetchFilteredItems(
            cuisineType: cuisine.cuisineName,
            priceRange: minPrice != nil && maxPrice != nil ? "\(minPrice!)-\(maxPrice!)" : nil,
            minRating: minRating
        ) { [weak self] result in
            switch result {
            case .success(let items):
                self?.items = items
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print("Failed to load items: \(error.localizedDescription)")
            }
        }
    }

    // ✅ Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DishCell", for: indexPath) as! DishCell
        let item = items[indexPath.row]
        cell.configure(with: item)
        cell.addToCartHandler = { [weak self] in
            CartManager.shared.addItem(item: item)
            self?.showToast(message: "\(item.name) added to cart! ✅")
        }
        return cell
    }

    // ✅ Toast Notification for Feedback
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 8
        toastLabel.clipsToBounds = true
        toastLabel.frame = CGRect(x: 20, y: view.frame.height - 100, width: view.frame.width - 40, height: 40)

        view.addSubview(toastLabel)

        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
}
