import UIKit

class ViewController: UIViewController {
    let leaderboardKey = LeaderboardKey()

    let interactor = Interactor()

    let label = UILabel()
//    let boardLabel = UILabel()
    let nameStackView = UIStackView()
    let starsStackView = UIStackView()
    let scoreStackView = UIStackView()
    lazy var boardStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
                nameStackView,
                starsStackView,
                scoreStackView
            ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10)
        ])

        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Advent of Code"
        view.backgroundColor = .white
        configureLabel()

        interactor.output = self

        if let key = leaderboardKey.key {
            let item = UIBarButtonItem(title: "Change leaderboard", style: .plain, target: self, action: #selector(promptKey))
            navigationItem.setRightBarButton(item, animated: false)
            label.text = key

            interactor.requestLeaderboard(key: key)
        } else {
            promptKey()
        }
    }

    private func configureLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
        ])
    }

    @objc
    private func promptKey() {
        let alert = UIAlertController(
            title: "Please provide the private leaderboard key",
            message: nil,
            preferredStyle: .alert)

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let confirm = UIAlertAction(title: "Use", style: .default) { action in
            guard let key = alert.textFields?.first?.text else { return }
            self.leaderboardKey.key = key
            self.interactor.requestLeaderboard(key: key)
        }
        alert.addAction(cancel)
        alert.addAction(confirm)
        alert.preferredAction = confirm

        alert.addTextField { textField in
            textField.placeholder = "ENTER KEY HERE"
        }

        present(alert, animated: true)
    }

    private func showLeaderboard(_ leaderboard: Leaderboard) {
        label.text = "Event: \(leaderboard.event)"

        leaderboard.sortedMembers.forEach { member in
            let nameLabel = UILabel()
            nameLabel.text = member.name ?? member.id
            nameStackView.addArrangedSubview(nameLabel)

            let starsLabel = UILabel()
            starsLabel.text = String(repeating: "⭐️", count: member.stars)
            starsStackView.addArrangedSubview(starsLabel)

            let scoreLabel = UILabel()
            scoreLabel.text = String(member.localScore)
            scoreStackView.addArrangedSubview(scoreLabel)
        }
    }
}

extension ViewController: InteractorOutput {
    func didFetchLeaderboard(_ leaderboard: Leaderboard) {
        showLeaderboard(leaderboard)
    }

    func failedFetchingLeaderboard(error: Error) {
        //TODO
    }
}
