//
//  articlePageMisc.swift
//  AHS20
//
//  Created by Richard Wei on 12/4/20.
//  Copyright © 2020 AHS. All rights reserved.
//

import Foundation
import UIKit

extension articlePageClass{
    @IBAction internal func saveArticle(sender: CustomUIButton){
        if (sender.articleCompleteData.articleID != nil){
            if (sender.isSelected == false){
                savedArticleClass.saveCurrArticle(articleID: sender.articleCompleteData.articleID!, article: sender.articleCompleteData);
            }
            else{
                savedArticleClass.removeCurrArticle(articleID: sender.articleCompleteData.articleID!);
            }
            sender.isSelected = !sender.isSelected;
            setBookmarkColor();
            //resetUpArticles = true;
        }
    }
    
    @IBAction internal func exitArticle(_ sender: UIButton){
        // imageAvgColors = [Int:UIColor]();
        //transitionDismissal();
        self.dismiss(animated: true);
        //print("pressed")
        //self.view.frame = CGRect(x: self.view.frame.width/2, y: 0, width: self.view.frame.width, height: self.view.frame.height);
    }
    
    @IBAction internal func handlePan(_ gestureRecognizer: UIPanGestureRecognizer){
       //print("got pan")
        if (gestureRecognizer.state == .began || gestureRecognizer.state == .changed){
            let translation = gestureRecognizer.translation(in: self.view);
            //print("translation - \(translation)")
            
            self.view.frame = CGRect(x: max(self.view.frame.minX + translation.x, 0), y: 0, width: self.view.frame.width, height: self.view.frame.height);
            
            gestureRecognizer.setTranslation(.zero, in: self.view);
        }
        else if (gestureRecognizer.state == .ended){
            let thresholdPercent : CGFloat = 0.25; // if minx > thresholdPercent * uiscreen.main.bounds.width
            if (self.view.frame.minX >= thresholdPercent * UIScreen.main.bounds.width){
                dismiss(animated: true);
            }
            else{
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height);
            }
        }
    }
    
    internal func setBookmarkColor(){
        if (articleContent?.articleID != nil && savedArticleClass.isSavedCurrentArticle(articleID: (articleContent?.articleID)!)){
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal);
            
            bookmarkButton.isSelected = true;
        }
        else{
            bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal);
            bookmarkButton.isSelected = false;
        }
    }
    
    
    override internal func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "openImageZoomPage"){
            let vc = segue.destination as! zoomableImageViewController;
            vc.image = passImageToZoomSegue;
        }
    }
    
    @objc internal func toggleZoom(sender: UIButton){
        if (sender.imageView?.image != nil){
            UIImpactFeedbackGenerator(style: .light).impactOccurred();
            passImageToZoomSegue = sender.imageView?.image;
            performSegue(withIdentifier: "openImageZoomPage", sender: nil);
        }
    }
}
