import UIKit
import Combine

final class UserViewController: UIViewController {
    let id: User.ID
    let uvs: UserViewState
    
    private let iconImageView: UIImageView = .init()
    private let nameLabel: UILabel = .init()
    private var cancellables: Set<AnyCancellable> = []

    init(id: User.ID) {
        self.id = id
        self.uvs = UserViewState(id: id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let task = Task { [weak self] in
                guard let uvs = self?.uvs else { return }
                for await value in await uvs.$user.values {
                    guard let self = self else { return }
                    self.nameLabel.text = value?.name
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
        do {
            let task = Task { [weak self] in
                guard let uvs = self?.uvs else { return }
                for await value in await uvs.$iconImage.values {
                    guard let self = self else { return }
                    self.iconImageView.image = value
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
        
        // レイアウト
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 40
        iconImageView.layer.borderWidth = 4
        iconImageView.layer.borderColor = UIColor.systemGray3.cgColor
        iconImageView.clipsToBounds = true
        view.addSubview(iconImageView)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            await uvs.loadUser()
        }
    }
}

extension Published.Publisher: @unchecked Sendable where Output: Sendable {}
extension UIImage: @unchecked Sendable {}