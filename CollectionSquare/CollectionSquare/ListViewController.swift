//
//  ViewController.swift
//  CollectionSquare
//
//  Created by user on 14.03.2024.
//

import UIKit

class ListViewController: UIViewController {

    var visibleSet =  Set<IndexPath>()
    typealias Snapshot = NSDiffableDataSourceSnapshot<MSection, MItem>

    var sections = [MSection]()

    var timer: Timer?
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource <MSection, MItem>?

    //MARK: create random Items

    var tmpName = 0
    func randElem() {
        for el in (0...20) {
            var myItem = [MItem]()
            for _ in (0...10) {
                myItem.append(MItem(id: String(tmpName), name: String(Int.random(in: 0...100))))
                tmpName += 1
            }
            sections.append(MSection(id: String(el), number: el, items: myItem))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        randElem()
        setupCollectionView()
        createTimer()
        createDataSource()
        reloadData()
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)

        collectionView.register(RedCell.self, forCellWithReuseIdentifier: RedCell.reuseId)

            collectionView.delegate = self
//            collectionView.dataSource = self

    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            return self?.createSections()
        }
        return layout
    }

    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource <MSection, MItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RedCell.reuseId, for: indexPath) as? RedCell
            cell?.configure(with: item)
            return cell
        }
    }

    func reloadData() {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)

        sections.forEach {
            snapshot.appendItems($0.items, toSection: $0)
        }

        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    func replaceItems(item: MItem, section: MSection) {
        guard var snapshot = dataSource?.snapshot() else { return }
        print(item)
        snapshot.deleteItems([item])
        snapshot.appendItems([item])
       // snapshot.reloadItems([item])
        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    func createSections() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(86), heightDimension: .absolute(86))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(3), heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 4, bottom: 0, trailing: 4)

        section.orthogonalScrollingBehavior = .continuous
        return section
    }

    func updateNewRandomNumbers() {
        guard var minSection = visibleSet.first?.section else { return }
        guard var maxSection = visibleSet.first?.section else { return }

        var arrayItemVis = [Int: (Int, Int)]()

        for index in visibleSet {
            arrayItemVis[index.section] = (100,0)
            if index.section > maxSection { maxSection = index.section }
            if index.section < minSection { minSection = index.section }
        }

        for index in visibleSet {
            if index.item < arrayItemVis[index.section]!.0 { arrayItemVis[index.section]?.0 = index.item }
            if index.item > arrayItemVis[index.section]!.1 { arrayItemVis[index.section]?.1 = index.item }
        }

//        print(arrayItemVis)

        for sec in (minSection...maxSection) {
            let el = Int.random(in: arrayItemVis[sec]!.0...arrayItemVis[sec]!.1)
//            sections[sec].items[el].name = String(Int.random(in: 0...100))
//            sections[sec].items[el].id = UUID().uuidString
            let newItem = MItem(id: sections[sec].items[el].id, name: "-")//String(Int.random(in: 0...100)))
            sections[sec].items[el] = newItem
            replaceItems(item: newItem, section: sections[sec])
        }
    }
}

//extension ListViewController: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return sections.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return sections[section].items.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RedCell.reuseId, for: indexPath) as! RedCell
//        cell.configure(with: sections[indexPath.section].items[indexPath.row])
//        return cell
//    }
//}


extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        visibleSet.insert(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        visibleSet.remove(indexPath)
    }
}

// MARK: - Timer

private extension ListViewController {
    func createTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc func updateTimer() {
        updateNewRandomNumbers()
       // collectionView.reloadData()
       // reloadData()

    }
}

//MARK: SwiftUI for presentation

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

