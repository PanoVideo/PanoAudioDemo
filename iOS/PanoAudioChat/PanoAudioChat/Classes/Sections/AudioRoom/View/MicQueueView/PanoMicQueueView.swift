//
//  PanoMicQueueView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit


class PanoMicQueueView: PanoBaseView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let InteritemSpacing : CGFloat = 25

    let LineSpacing : CGFloat = 30
    
    let MarginSpacing : CGFloat = 30
    
    var data = [PanoMicInfo]();
    
    var collectionView: UICollectionView!
    
    var layout: UICollectionViewFlowLayout!
    
    weak var delegate: PanoMicCollectionCellDelegate?
    
    override func initViews() {
        
        layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.1
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
        collectionView.clipsToBounds = false
        collectionView.register(PanoMicCollectionCell.self, forCellWithReuseIdentifier: "cellID")
        self.addSubview(collectionView)
    }
    
    override func initConstraints() {
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: MarginSpacing, bottom: 0, right: MarginSpacing))
        }
    }
    
    func reloadData()  {
        collectionView.reloadData()
    }
    
    func cellSize() -> CGSize {
        var width = (PanoAppWidth - 3 * LineSpacing - 2 * MarginSpacing) / 4
        if width > 75 {
            width = 75
        }
        let height = width + 30;
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = data.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! PanoMicCollectionCell
        cell.delegate = delegate
        let info = data[indexPath.row]
        cell.updateMicInfo(info: info)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return LineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return MarginSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}


