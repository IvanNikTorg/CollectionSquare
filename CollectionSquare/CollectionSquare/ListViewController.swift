//
//  ViewController.swift
//  CollectionSquare
//
//  Created by user on 14.03.2024.
//

import UIKit

protocol ListViewControllerInput: AnyObject {
    func reloadData(sections: [MSection])
    func replaceItems(in sections: [MSection])
}

class ListViewController: UIViewController {

    typealias Snapshot = NSDiffableDataSourceSnapshot<MSection, MItem>

    weak var presenter: ListViewControllerOutput?

    var collectionView: UICollectionView?
    var dataSource: UICollectionViewDiffableDataSource <MSection, MItem>?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        createDataSource()
        presenter?.viewIsReady()
    }
}

// MARK: Collection and DataSource initial setup

private extension ListViewController {
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())

        guard let collectionView = collectionView else { return }
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.register(RedCell.self, forCellWithReuseIdentifier: RedCell.reuseId)
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    func createDataSource() {
        guard let collectionView = collectionView else { return }
        dataSource = UICollectionViewDiffableDataSource <MSection, MItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RedCell.reuseId, for: indexPath) as? RedCell
            cell?.configure(with: item)
            return cell
        }
    }

    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            return self?.createSections()
        }
        return layout
    }

    func createSections() -> NSCollectionLayoutSection {
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

// MARK: UICollectionViewDelegate

extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        presenter?.insertToVisibleSet(indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        presenter?.removeFromVisibleSet(indexPath: indexPath)
    }
}

// MARK: ListViewControllerInput

extension ListViewController: ListViewControllerInput {
    func reloadData(sections: [MSection]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        sections.forEach {
            snapshot.appendItems($0.items, toSection: $0)
        }
        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    func replaceItems(in sections: [MSection]) {
        guard var snapshot = dataSource?.snapshot() else { return }

        let itemIdent = sections.map {
            snapshot.itemIdentifiers(inSection: $0)
        }
        itemIdent.forEach {
            snapshot.deleteItems($0)
        }
        sections.forEach {
            snapshot.appendItems($0.items, toSection: $0)
            snapshot.reloadItems($0.items)
        }
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}


// MARK: SwiftUI for presentation

import SwiftUI

struct ListProvider: PreviewProvider {
    static var previews: some View {
        CointainerView().edgesIgnoringSafeArea(.all)
    }

    struct CointainerView: UIViewControllerRepresentable {
        let listVC = ListViewController()

        func makeUIViewController(context: UIViewControllerRepresentableContext<ListProvider.CointainerView>) -> ListViewController {
            return listVC
        }

        func updateUIViewController(_ uiViewController: ListProvider.CointainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ListProvider.CointainerView>) {
        }
    }
}
