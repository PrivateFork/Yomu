//
//  SearchedMangaCollectionViewController.swift
//  Yomu
//
//  Created by Sendy Halim on 7/29/16.
//  Copyright © 2016 Sendy Halim. All rights reserved.
//

import AppKit
import RxSwift

protocol SearchedMangaDelegate: class {
  func searchedMangaDidSelected(_ viewModel: SearchedMangaViewModel)
  func closeView(_ sender: AnyObject?)
}

class SearchedMangaCollectionViewController: NSViewController {
  @IBOutlet weak var collectionView: NSCollectionView!
  @IBOutlet weak var mangaTitle: NSTextField!
  @IBOutlet weak var mangaTitleContainer: NSBox!
  @IBOutlet weak var progressIndicator: NSProgressIndicator!
  @IBOutlet weak var backButton: NSButton!

  weak var delegate: SearchedMangaDelegate?

  var collectionViewModel: SearchedMangaCollectionViewModel

  let disposeBag = DisposeBag()

  init(viewModel: SearchedMangaCollectionViewModel) {
    collectionViewModel = viewModel

    super.init(nibName: "SearchedMangaCollection", bundle: nil)!
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.dataSource = self
    collectionView.delegate = self

    mangaTitle
      .rx.text.orEmpty
      .filter {
        $0.characters.count > 2
      }
      .throttle(1.0, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] in
        guard let `self` = self else {
          return
        }

        // Cancel previous request
        self.collectionViewModel.disposeBag = DisposeBag()
        self.collectionViewModel.search(term: $0) ==> self.collectionViewModel.disposeBag
      }) ==> disposeBag

    collectionViewModel.reload ~~> collectionView.reloadData ==> disposeBag
    collectionViewModel.fetching ~~> progressIndicator.animating ==> disposeBag

    backButton
      .rx.tap
      .subscribe(onNext: { [weak self] in
        self?.delegate?.closeView(self)
      }) ==> disposeBag
  }

  override func viewWillLayout() {
    super.viewWillLayout()
    collectionView.collectionViewLayout?.invalidateLayout()
  }

  @IBAction func closeView(_ sender: NSButton) {
    delegate?.closeView(self)
  }
}

extension SearchedMangaCollectionViewController: NSCollectionViewDataSource {
  func numberOfSections(in collectionView: NSCollectionView) -> Int {
    return 1
  }

  func collectionView(
    _ collectionView: NSCollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return collectionViewModel.count
  }

  func collectionView(
    _ collectionView: NSCollectionView,
    itemForRepresentedObjectAt indexPath: IndexPath
  ) -> NSCollectionViewItem {
    let cell = collectionView.makeItem(
      withIdentifier: "SearchedMangaItem",
      for: indexPath
    ) as! SearchedMangaItem

    let vm = collectionViewModel[(indexPath as NSIndexPath).item]

    vm.title ~~> cell.titleTextField.rx.text.orEmpty ==> cell.disposeBag
    vm.previewUrl ~~> cell.mangaImageView.setImageWithUrl ==> cell.disposeBag
    cell.accessoryButton.image = Config.icon.pin

    return cell
  }
}

extension SearchedMangaCollectionViewController: NSCollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: NSCollectionView,
    didSelectItemsAt indexPaths: Set<IndexPath>
  ) {
    let index = (indexPaths.first! as NSIndexPath).item

    delegate?.searchedMangaDidSelected(collectionViewModel[index])
  }
}
