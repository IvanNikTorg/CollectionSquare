//
//  ViewController.swift
//  CollectionSquare
//
//  Created by user on 14.03.2024.
//

import UIKit

protocol ListViewControllerInput: AnyObject {
    func reloadData()
}

class ListViewController: UIViewController {

    var collectionView: UICollectionView!
    var presenter: ListViewControllerOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        presenter?.viewIsReady()
    }

    // MARK: - Private

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)

        collectionView.register(RedCell.self, forCellWithReuseIdentifier: RedCell.reuseId)

        collectionView.delegate = self
        collectionView.dataSource = self

    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            return self?.createSections()
        }
        return layout
    }

    private func createSections() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(86), heightDimension: .absolute(86))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(300), heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 4, bottom: 0, trailing: 4)

        section.orthogonalScrollingBehavior = .continuous
        return section
    }
}

// MARK: - UICollectionViewDataSource

extension ListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter?.dataSource.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.dataSource[section].items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RedCell.reuseId,
                                                            for: indexPath) as? RedCell,
              let output = presenter else { return UICollectionViewCell() }

        cell.configure(with: output.dataSource[indexPath.section].items[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        presenter?.insertToVisibleSet(indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        presenter?.removeFromVisibleSet(indexPath: indexPath)
    }
}

// MARK: - ListViewControllerInput

extension ListViewController: ListViewControllerInput {
    func reloadData() {
        collectionView.reloadData()
    }
}

