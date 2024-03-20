//
//  ListViewPresenter.swift
//  CollectionSquare
//
//  Created by user on 20.03.2024.
//

import UIKit

protocol ListViewControllerOutput: AnyObject {
    func viewIsReady()
    func insertToVisibleSet(indexPath: IndexPath)
    func removeFromVisibleSet(indexPath: IndexPath)
}

final class ListViewPresenter {

    weak var view: ListViewControllerInput?

    private var sections = [MSection]()
    private var visibleCellsSet =  Set<IndexPath>()
    private var timer: Timer?

    private let maxRandomNumber = 100
    private let sectionsCount = 100
    private let itemsInRowCount = 20
}

extension ListViewPresenter: ListViewControllerOutput {
    func viewIsReady() {
        initialSetup()
        createTimer()
    }

    func insertToVisibleSet(indexPath: IndexPath) {
        visibleCellsSet.insert(indexPath)
    }

    func removeFromVisibleSet(indexPath: IndexPath) {
        visibleCellsSet.remove(indexPath)
    }
}

private extension ListViewPresenter {

    // MARK: create random Items

    func initialSetup() {
        for el in (0...sectionsCount) {
            var items = [MItem]()
            for _ in (0...itemsInRowCount) {
                items.append(MItem(id: UUID().uuidString, name: String(Int.random(in: 0...maxRandomNumber))))
            }
            sections.append(MSection(id: String(el), items: items))
        }
        view?.reloadData(sections: sections)
    }

    // MARK: - Timer

    func createTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateNewRandomNumbers),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc func updateNewRandomNumbers() {
        guard var minSection = visibleCellsSet.first?.section,
              var maxSection = visibleCellsSet.first?.section else { return }

        var changeSections = [MSection]()
        var arrayItemVis = [Int: (Int, Int)]()

        for index in visibleCellsSet {
            arrayItemVis[index.section] = (100,0)
            if index.section > maxSection { maxSection = index.section }
            if index.section < minSection { minSection = index.section }
        }

        for index in visibleCellsSet {
            guard let min = arrayItemVis[index.section]?.0 else { return }
            if index.item < min { arrayItemVis[index.section]?.0 = index.item }
            guard let max = arrayItemVis[index.section]?.1 else { return }
            if index.item > max { arrayItemVis[index.section]?.1 = index.item }
        }

        for sec in (minSection...maxSection) {
            guard let min = arrayItemVis[sec]?.0, let max = arrayItemVis[sec]?.1 else { return }
            let el = Int.random(in: min...max)
            sections[sec].items[el].name = String(Int.random(in: 0...maxRandomNumber))
            changeSections.append(sections[sec])
        }
        view?.replaceItems(in: changeSections)
    }
}
