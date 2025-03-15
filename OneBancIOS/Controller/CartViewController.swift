import UIKit

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView()
    private let totalLabel = UILabel()
    private let taxLabel = UILabel()
    private let grandTotalLabel = UILabel()
    private let checkoutButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "🛒 Cart"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupFooterView()
        calculateTotal()
    }
    
    // ✅ Setup TableView
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CartCell.self, forCellReuseIdentifier: "CartCell")
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        ])
    }
    
    // ✅ Setup Footer View (Total + Checkout Button)
    private func setupFooterView() {
        let footerView = UIView()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .white
        footerView.layer.shadowColor = UIColor.black.cgColor
        footerView.layer.shadowOpacity = 0.1
        footerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        footerView.layer.shadowRadius = 4
        
        totalLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        taxLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        grandTotalLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        grandTotalLabel.textColor = .systemGreen
        
        checkoutButton.setTitle("✅ Checkout", for: .normal)
        checkoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        checkoutButton.backgroundColor = .systemBlue
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.layer.cornerRadius = 8
        checkoutButton.addTarget(self, action: #selector(placeOrder), for: .touchUpInside)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(totalLabel)
        footerView.addSubview(taxLabel)
        footerView.addSubview(grandTotalLabel)
        footerView.addSubview(checkoutButton)
        view.addSubview(footerView)
        
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 120),
            
            totalLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10),
            totalLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            
            taxLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 4),
            taxLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            
            grandTotalLabel.topAnchor.constraint(equalTo: taxLabel.bottomAnchor, constant: 4),
            grandTotalLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            
            checkoutButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            checkoutButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            checkoutButton.widthAnchor.constraint(equalToConstant: 140),
            checkoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // ✅ Calculate Total + Tax + Grand Total
    private func calculateTotal() {
        let items = CartManager.shared.getItems()
        
        let total = items.map { Double($0.price) ?? 0 }.reduce(0, +)
        let cgst = total * 0.025
        let sgst = total * 0.025
        let grandTotal = total + cgst + sgst
        
        totalLabel.text = "Total: ₹\(String(format: "%.2f", total))"
        taxLabel.text = "CGST: ₹\(String(format: "%.2f", cgst)), SGST: ₹\(String(format: "%.2f", sgst))"
        grandTotalLabel.text = "Grand Total: ₹\(String(format: "%.2f", grandTotal))"
    }
    
    // ✅ Place Order Using API
    @objc private func placeOrder() {
        let items = CartManager.shared.getItems()
        ApiManager.shared.placeOrder(items: items) { result in
            switch result {
            case .success(let message):
                print(message)
                DispatchQueue.main.async {
                    self.showToast(message: "Order placed successfully ✅")
                    CartManager.shared.clearCart()
                    self.tableView.reloadData()
                    self.calculateTotal()
                }
            case .failure(let error):
                print("Failed to place order: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToast(message: "Order failed ❌")
                }
            }
        }
    }
    
    // ✅ TableView Data Source + Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CartManager.shared.getItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        let item = CartManager.shared.getItems()[indexPath.row]
        cell.configure(with: item)
        
        // ✅ Pass item directly to removeHandler
        cell.removeHandler = { [weak self] in
            CartManager.shared.removeItem(item)
            self?.tableView.reloadData()
            self?.calculateTotal()
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
