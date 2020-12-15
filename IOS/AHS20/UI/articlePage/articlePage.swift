//
//  File.swift
//  AHS20
//
//  Created by Richard Wei on 4/21/20.
//  Copyright © 2020 AHS. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox
import youtube_ios_player_helper

class articlePageClass: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate{

    
    /*@IBOutlet weak var backButton: UIButton!
     @IBOutlet weak var articleText: UILabel!
     @IBOutlet weak var imageScrollView: UIScrollView!
     @IBOutlet weak var imagePageControl: UIPageControl!
     @IBOutlet weak var whiteBackground: UIImageView!*/    //@IBOutlet weak var notificationBellButton: UIButton!
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var bookmarkButton: CustomUIButton!
    
    @IBOutlet weak var articleCatagoryLabel: UILabel!
    
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet var gestureRecognizer: UIPanGestureRecognizer!
    
    var contentWidth: CGFloat = 0.0
    var imageFrame = CGRect(x: 0, y:0, width: 0, height: 0);
    var imageSize = 1;
    var videoSize = 1;
    var articleContent: articleData?;
    //var imageAvgColors = [Int:UIColor]();
    
    let imagePageControl = UIPageControl();
    let imageScrollView = UIScrollView();
    
    var passImageToZoomSegue: UIImage?;
    
    
    /// START DISMISS ON PAN
    //var interactor: Interactor? = nil;
    //let transition = CATransition();
    /// END DISMISS ON PAN

    
    override func viewDidLoad() {
        super.viewDidLoad();
        // NewYorkSmall-MediumItalic, NewYorkMedium-Bold
       // imageAvgColors = [Int:UIColor]();
        bookmarkButton.articleCompleteData = articleContent ?? articleData();
        
        bookmarkButton.tintColor = mainThemeColor;
        setBookmarkColor();
        
        //let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureAction));
        //gestureRecognizer.edges = .left;
        //gestureRecognizer.delegate = self;
        //view.addGestureRecognizer(gestureRecognizer);
        //mainScrollView.addGestureRecognizer(gestureRecognizer);
        
        gestureRecognizer.addTarget(self, action: #selector(self.handlePan));
        
        shadowView.layer.shadowColor = InverseBackgroundColor.cgColor;
        shadowView.layer.shadowOpacity = 0.05;
        shadowView.layer.shadowOffset = CGSize(width: 0 , height: 5);
        
        articleCatagoryLabel.text = articleContent?.articleCatagory ?? "NO Cata.";
        articleCatagoryLabel.setRoundedEdge(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 5);
        mainScrollView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 1).isActive = true;
        
        var nextY = CGFloat(10);
        let padding = CGFloat(15);
        let universalWidth = UIScreen.main.bounds.width - 2 * padding;
        
        //nextY += 7;
        let articleTitleText = articleContent?.articleTitle;
        let titleFont = UIFont(name: "NewYorkMedium-Bold", size: CGFloat(fontSize+8));
        let articleTitleFrame = CGRect(x: padding, y: nextY, width: universalWidth, height: articleTitleText?.getHeight(withConstrainedWidth: universalWidth, font: titleFont!) ?? 0);
        let articleTitle = UILabel(frame: articleTitleFrame);
        articleTitle.text = articleTitleText; // set article title here
        articleTitle.font = titleFont;
        articleTitle.textColor = InverseBackgroundColor;
        articleTitle.numberOfLines = 0;
        mainScrollView.addSubview(articleTitle);
        nextY += articleTitleFrame.height + 7;
        
        if ((articleContent?.articleVideoIDs?.count ?? 0) + (articleContent?.articleImages?.count ?? 0) > 0){ // bulletin
            let imageScrollViewFrame = CGRect(x: padding, y: nextY, width: universalWidth, height: 250);
            imageScrollView.frame = imageScrollViewFrame;
            
            imageSize = articleContent?.articleImages?.count ?? 0;
            videoSize = articleContent?.articleVideoIDs?.count ?? 0;
            imageScrollView.backgroundColor = UIColor.clear;
            
            imageFrame.size = imageScrollView.frame.size;
            var origX = CGFloat(0);
            for videoIndex in 0..<videoSize{
                imageFrame.origin.x = origX;
                let videoPlayer = YTPlayerView(frame: imageFrame);
                videoPlayer.load(withVideoId: articleContent?.articleVideoIDs?[videoIndex] ?? "");
                imageScrollView.addSubview(videoPlayer);
                origX += imageFrame.size.width;
            }
            for imageIndex in 0..<imageSize{
                imageFrame.origin.x = origX;
                let buttonImage = UIButton(frame: imageFrame);
                buttonImage.imgFromURL(sURL: articleContent?.articleImages?[imageIndex] ?? "");
                buttonImage.imageView?.contentMode = .scaleAspectFill;
                /*buttonImage.imageView?.image?.getColors({ (colors) -> Void in
                    self.imageAvgColors[imageIndex+self.videoSize] = colors?.primary ?? UIColor.lightGray;
                    if (imageIndex == 0){
                        self.imageScrollView.backgroundColor = self.imageAvgColors[self.videoSize];
                    }
                });*/
                buttonImage.addTarget(self, action: #selector(toggleZoom), for: .touchUpInside);
                imageScrollView.addSubview(buttonImage);
                origX += imageFrame.size.width;
            }
            imageScrollView.contentSize = CGSize(width: origX, height: imageScrollView.frame.size.height);
            imageScrollView.delegate = self;
            imageScrollView.layer.cornerRadius = 5;
            imageScrollView.layer.borderColor = BackgroundGrayColor.cgColor;
            imageScrollView.layer.borderWidth = 0.5;
            imageScrollView.isPagingEnabled = true;
            imageScrollView.showsHorizontalScrollIndicator = false;
            
            nextY += imageScrollViewFrame.size.height;
            
            if (imageSize + videoSize > 1){
                //print("got to image")
                imagePageControl.frame = CGRect(x: padding, y: nextY, width: UIScreen.main.bounds.width, height: 20);
                imagePageControl.currentPage = 0;
                imagePageControl.numberOfPages = imageSize+videoSize;
                //imagePageControl.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: nextY + 12);
                imagePageControl.tintColor = InverseBackgroundColor;
                imagePageControl.pageIndicatorTintColor = BackgroundGrayColor;
                imagePageControl.currentPageIndicatorTintColor = InverseBackgroundColor;
                imagePageControl.backgroundColor = BackgroundColor;
                imagePageControl.isUserInteractionEnabled = false;
                mainScrollView.addSubview(imagePageControl);
                nextY += imagePageControl.frame.height;
            }
            
            mainScrollView.addSubview(imageScrollView);
        }
        
        
        nextY += 7;
        if (articleContent?.articleAuthor != nil){
            let articleAuthorText = "By " + (articleContent?.articleAuthor ?? "No Author");
            let articleAuthorFont = UIFont(name: "NewYorkSmall-MediumItalic", size: CGFloat(fontSize-1));
            let articleAuthorFrame = CGRect(x: padding, y: nextY, width: universalWidth, height: articleAuthorText.getHeight(withConstrainedWidth: universalWidth, font: articleAuthorFont!))
            let articleAuthor = UILabel(frame: articleAuthorFrame);
            articleAuthor.text = articleAuthorText;
            articleAuthor.font = articleAuthorFont;
            articleAuthor.textColor = BackgroundGrayColor;
            articleAuthor.numberOfLines = 0;
            mainScrollView.addSubview(articleAuthor);
            nextY += articleAuthorFrame.size.height+3;
        }
        
        let articleDateText = epochClass.epochToFormatedDateString(epoch: articleContent?.articleUnixEpoch ?? -1);
        let articleDateFrame = CGRect(x: padding, y: nextY, width: universalWidth, height: articleDateText.getHeight(withConstrainedWidth: universalWidth, font: UIFont(name: "SFProDisplay-Regular", size: CGFloat(fontSize-3))!));
        let articleDate = UILabel(frame: articleDateFrame);
        articleDate.text = articleDateText;
        articleDate.font = UIFont(name: "SFProDisplay-Regular", size: CGFloat(fontSize-3));
        articleDate.textColor = BackgroundGrayColor;
        articleDate.numberOfLines = 0;
        mainScrollView.addSubview(articleDate);
        nextY += articleDateFrame.size.height;
        
        nextY += 7;
        let articleBodyText = (articleContent?.hasHTML == true ? parseHTML(s: articleContent?.articleBody ?? "") : NSAttributedString(string: articleContent?.articleBody ?? ""));
        let articleBodyFrame = CGRect(x: padding, y: nextY, width: universalWidth, height: articleBodyText.string.getHeight(withConstrainedWidth: universalWidth, font: UIFont(name: "SFProDisplay-Regular", size: CGFloat(fontSize))!));
        let articleBody = UITextView(frame: articleBodyFrame);
        articleBody.attributedText = articleBodyText;
        articleBody.font = UIFont(name: "SFProDisplay-Regular", size: CGFloat(fontSize));
        articleBody.textColor = InverseBackgroundColor;
        articleBody.backgroundColor = BackgroundColor;
        articleBody.isScrollEnabled = false;
        articleBody.isEditable = false;
        articleBody.tintColor = UIColor.systemBlue;
        articleBody.contentInset = UIEdgeInsets(top: -7, left: -5, bottom: 0, right: 0);
        articleBody.sizeToFit();
        mainScrollView.addSubview(articleBody);
        nextY += articleBody.frame.size.height;
        mainScrollView.contentSize = CGSize(width: universalWidth, height: nextY + 30);
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (articleContent?.articleAuthor != nil){
            imagePageControl.currentPage = Int(round(imageScrollView.contentOffset.x / imageFrame.size.width));
            //UIScrollView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {self.imageScrollView.backgroundColor = self.imageAvgColors[self.imagePageControl.currentPage] != nil ? self.imageAvgColors[self.imagePageControl.currentPage] : UIColor.lightGray;}, completion: nil);
        }
    }
}
