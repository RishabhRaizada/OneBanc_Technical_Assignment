import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var cuisines: [Cuisine] = []
    private var filteredCuisines: [Cuisine] = []
    private var currentLanguage: String = "en" // Default Language is English
    
    private let filterSegment: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All", "Indian", "Chinese", "Italian", "Mexican", "South Indian"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .white
        control.selectedSegmentTintColor = .systemBlue
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        return control
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 250, height: 150)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    private let languageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🌍 Language: English", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(languageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLanguageSetting()
        setupViews()
        fetchData()
    }
    
    // ✅ Setup UI Elements
    private func setupViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cart", style: .plain, target: self, action: #selector(openCart))
        
        view.addSubview(filterSegment)
        view.addSubview(collectionView)
        view.addSubview(languageButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CuisineCell.self, forCellWithReuseIdentifier: "CuisineCell")
        
        NSLayoutConstraint.activate([
            filterSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            filterSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterSegment.heightAnchor.constraint(equalToConstant: 40),
            
            collectionView.topAnchor.constraint(equalTo: filterSegment.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 160),
            
            languageButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            languageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // ✅ Load Language Setting
    private func loadLanguageSetting() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") {
            currentLanguage = savedLanguage
        } else {
            currentLanguage = "en"
        }
        updateLanguage()
    }
    
    // ✅ Handle Language Button Tap
    @objc private func languageButtonTapped() {
        if currentLanguage == "en" {
            currentLanguage = "hi"
            UserDefaults.standard.set("hi", forKey: "appLanguage")
        } else {
            currentLanguage = "en"
            UserDefaults.standard.set("en", forKey: "appLanguage")
        }
        updateLanguage()
    }
    
    // ✅ Update Language Based on Selection
    private func updateLanguage() {
        if currentLanguage == "en" {
            languageButton.setTitle("🌍 Language: English", for: .normal)
            filterSegment.setTitle("All", forSegmentAt: 0)
            filterSegment.setTitle("Indian", forSegmentAt: 1)
            filterSegment.setTitle("Chinese", forSegmentAt: 2)
            filterSegment.setTitle("Italian", forSegmentAt: 3)
            filterSegment.setTitle("Mexican", forSegmentAt: 4)
            filterSegment.setTitle("South Indian", forSegmentAt: 5)
        } else {
            languageButton.setTitle("🌍 भाषा: हिंदी", for: .normal)
            filterSegment.setTitle("सभी", forSegmentAt: 0)
            filterSegment.setTitle("भारतीय", forSegmentAt: 1)
            filterSegment.setTitle("चीनी", forSegmentAt: 2)
            filterSegment.setTitle("इतालवी", forSegmentAt: 3)
            filterSegment.setTitle("मैक्सिकन", forSegmentAt: 4)
            filterSegment.setTitle("दक्षिण भारतीय", forSegmentAt: 5)
        }
    }
    
    @objc private func openCart() {
        let vc = CartViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // ✅ Fetch Data from API
    private func fetchData() {
        ApiManager.shared.fetchItemList { [weak self] result in
            switch result {
            case .success(let cuisines):
                self?.cuisines = cuisines
                self?.filteredCuisines = cuisines
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print("Failed to load data: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func filterChanged() {
        let selectedIndex = filterSegment.selectedSegmentIndex
        switch selectedIndex {
        case 0:
            filteredCuisines = cuisines
        case 1:
            filteredCuisines = cuisines.filter { $0.cuisineName.contains("Indian") }
        case 2:
            filteredCuisines = cuisines.filter { $0.cuisineName.contains("Chinese") }
        case 3:
            filteredCuisines = cuisines.filter { $0.cuisineName.contains("Italian") }
        case 4:
            filteredCuisines = cuisines.filter { $0.cuisineName.contains("Mexican") }
        case 5:
            filteredCuisines = cuisines.filter { $0.cuisineName.contains("South Indian") }
        default:
            filteredCuisines = cuisines
        }
        collectionView.reloadData()
    }
    
    // ✅ Infinite Scroll
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentWidth = scrollView.contentSize.width
        let offsetX = scrollView.contentOffset.x
        
        if offsetX <= 0 {
            scrollView.contentOffset.x = contentWidth - scrollView.bounds.width
        } else if offsetX >= contentWidth - scrollView.bounds.width {
            scrollView.contentOffset.x = 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCuisines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CuisineCell", for: indexPath) as! CuisineCell
        let cuisine = filteredCuisines[indexPath.row]
        cell.configure(with: cuisine)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCuisine = filteredCuisines[indexPath.row]
        let vc = CuisineDetailViewController(cuisine: selectedCuisine)
        navigationController?.pushViewController(vc, animated: true)
    }
}
