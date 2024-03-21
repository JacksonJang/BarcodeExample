import UIKit

class ViewController: UIViewController {
    let barcodeView = BarcodeView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        barcodeView.translatesAutoresizingMaskIntoConstraints = false
        barcodeView.delegate = self
        
        setupUI()
    
        DispatchQueue.global(qos: .userInitiated).async {
            self.barcodeView.start()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        barcodeView.updateUI()
    }
    
    private func setupUI() {
        view.addSubview(barcodeView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            barcodeView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            barcodeView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            barcodeView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            barcodeView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension ViewController: BarcodeViewDelegate {
    func complete(status: BarcodeViewStatus) {
        switch status {
        case .success(let code):
            let alert = UIAlertController(title: "알림", message: code, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: {_ in 
                self.barcodeView.start()
            }))
            self.present(alert, animated: true, completion: nil)
        case .error:
            fatalError("에러 발생")
        }
    }
}
