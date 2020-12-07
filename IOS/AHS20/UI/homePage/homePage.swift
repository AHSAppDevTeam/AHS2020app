//
//  ViewController.swift
//  AHS20
//
//  Created by Richard Wei on 3/14/20.
//  Copyright © 2020 AHS. All rights reserved.
//


// ----- READ: Hello whomever might be reading this. I have many custom features added to this code that you won't find on stock swift projects. This is why I have included some notes that you might want to read below:
/*
- sharedFunc.swift includes the shared functions/classes between all swift files. You can access any of theses functions from any swift file
- CustomUIButton is a custom class that I created that is an extension of the regular UIButton class. The main different to this class is that there are extra data types that allow you allow you to pass data to a ".addTarget" @objc function that you normally wouldn't be able to do. The data types can be found in sharedFunc.swift
*/

//SFProText-Bold, SFProDisplay-Regular, SFProDisplay-Semibold, SFProDisplay-Black

import UIKit
import AudioToolbox
import Firebase
import FirebaseDatabase

class homeClass: UIViewController, UIScrollViewDelegate, UITabBarControllerDelegate {
	
	// link UI elements to swift via outlets
	
	@IBOutlet weak var mainScrollView: UIScrollView!
	
	@IBOutlet weak var featuredLabel: UILabel!
	@IBOutlet weak var featuredScrollView: UIScrollView!
	
	@IBOutlet weak var generalLabel: UILabel!
	@IBOutlet weak var generalInfoScrollView: UIScrollView!
	@IBOutlet weak var generalInfoPageControl: UIPageControl!
	@IBOutlet weak var loadingGeneralView: UIView!

	@IBOutlet weak var districtLabel: UILabel!
	@IBOutlet weak var districtNewsScrollView: UIScrollView!
	@IBOutlet weak var districtNewsPageControl: UIPageControl!
	@IBOutlet weak var loadingDistrictView: UIView!
	
	@IBOutlet weak var asbLabel: UILabel!
	@IBOutlet weak var asbNewsScrollView: UIScrollView!
	@IBOutlet weak var asbNewsPageControl: UIPageControl!
	@IBOutlet weak var loadingASBView: UIView!
	
	
	@IBOutlet weak var featuredMissingLabel: UILabel!
	
	let loading = "Loading...";
	
	let bookmarkImageVerticalInset = CGFloat(5);
	let bookmarkImageHorizontalInset = CGFloat(7);
	
	let bookmarkImageUI = UIImage(named: "invertedbookmark");
	//let bookmarkImageUI = UIImage(systemName: "bookmark");
	
	var refreshControl = UIRefreshControl();
	var featuredArticles = [articleData]();
	
	var featuredSize = 6;
	var featuredFrame = CGRect(x:0,y:0,width:0,height:0);
	var asbNewsSize = 1;
	var asbNewsFrame = CGRect(x:0,y:0,width:0,height:0);
	var	generalInfoSize = 1;
	var generalInfoFrame = CGRect(x:0,y:0,width:0,height:0);
	var districtNewsSize = 1;
	var districtNewsFrame = CGRect(x:0,y:0,width:0,height:0);
	
	internal func getHomeArticleData(){
		setUpConnection();
		if (internetConnected){
			featuredArticles = [articleData]();
			homeArticleList = [[articleData]](repeating: [articleData](), count: 3);
			
			for i in 0...2{
				var s: String; // path inside homepage
				switch i {
				case 0: // general info
					s = "General_Info";
					break;
				case 1: // district
					s = "District";
					break;
				case 2: // asb
					s = "ASB";
					break;
				default:
					s = "";
					break;
				}
				
				ref.child("homepage").child(s).observeSingleEvent(of: .value) { (snapshot) in
					let enumerator = snapshot.children;
					var temp = [articleData](); // temporary array
					while let article = enumerator.nextObject() as? DataSnapshot{ // each article
						
						let enumerator = article.children;
						var singleArticle = articleData();
						
						singleArticle.articleID = article.key;
						
						
						while let articleContent = enumerator.nextObject() as? DataSnapshot{ // data inside article
							
							
							if (articleContent.key == "articleAuthor"){
								singleArticle.articleAuthor = articleContent.value as? String;
							}
							else if (articleContent.key == "articleBody"){
								singleArticle.articleBody = articleContent.value as? String;
							}
							else if (articleContent.key == "articleUnixEpoch"){
								singleArticle.articleUnixEpoch = articleContent.value as? Int64;
							}
							else if (articleContent.key == "articleImages"){
								
								var tempImage = [String]();
								let imageIt = articleContent.children;
								while let image = imageIt.nextObject() as? DataSnapshot{
									tempImage.append(image.value as! String);
								}
								singleArticle.articleImages = tempImage;
							}
							else if (articleContent.key == "articleVideoIDs"){
								var tempArr = [String]();
								let idIt = articleContent.children;
								while let id = idIt.nextObject() as? DataSnapshot{
									tempArr.append(id.value as! String);
								}
								singleArticle.articleVideoIDs = tempArr;
							}
							else if (articleContent.key == "articleTitle"){
								
								singleArticle.articleTitle = articleContent.value as? String;
							}
							else if (articleContent.key == "isFeatured"){
								singleArticle.isFeatured = (articleContent.value as? Int == 0 ? false : true);
							}
							else if (articleContent.key == "hasHTML"){
								singleArticle.hasHTML = (articleContent.value as? Int == 0 ? false : true);
							}
							
							
						}
						singleArticle.articleCatagory = i == 0 ? "General Info" : s;
						temp.append(singleArticle);
						//print(singleArticle.isFeatured);
						if (singleArticle.isFeatured == true){
							self.featuredArticles.append(singleArticle);
						}
					}
					self.loadingASBView.isHidden = true;
					self.loadingDistrictView.isHidden = true;
					self.loadingGeneralView.isHidden = true;
					homeArticleList[i] = temp;
					self.setUpAllViews();
					self.refreshControl.endRefreshing();
				};
			}
		}
		else{
			featuredLabel.text = "No Connection";
			let infoPopup = UIAlertController(title: "No internet connection detected", message: "No articles were loaded", preferredStyle: UIAlertController.Style.alert);
			infoPopup.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
				self.refreshControl.endRefreshing();
			}));
			present(infoPopup, animated: true, completion: nil);
		}
	}
	
	private func getScrollViewFromPageControl(with tag: Int) -> UIScrollView{
		switch tag {
		case 0:
			return generalInfoScrollView;
		case 1:
			return districtNewsScrollView;
		case 2:
			return asbNewsScrollView;
		default:
			return UIScrollView();
		}
	}
	
	@IBAction internal func pageControlSelectionAction(_ sender: UIPageControl){
		let page = sender.currentPage;
		let scrollview = getScrollViewFromPageControl(with: sender.tag);
		var frame = scrollview.frame;
		frame.origin.x = frame.size.width * CGFloat(page);
		frame.origin.y = 0;
		scrollview.scrollRectToVisible(frame, animated: true);
	}
	
	private func smallArticle(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, articleSingle: articleData) -> CustomUIButton{//TODO: find out a way to separate article from top and bottom
		
		let mainArticleFrame = CGRect(x: x, y: y, width: width, height: height);
		let mainArticleView = CustomUIButton(frame: mainArticleFrame);
		
		
		let articleTextWidth = (width/2) + 10;
		
		
		let articleImageViewFrame = CGRect(x: 0, y: 5, width: width - articleTextWidth, height: height - 10);
		let articleImageView = UIImageView(frame: articleImageViewFrame);
		if (articleSingle.articleImages?.count ?? 0 >= 1){
			articleImageView.imgFromURL(sURL: articleSingle.articleImages?[0] ?? "");
			articleImageView.contentMode = .scaleAspectFill;
		}
		articleImageView.backgroundColor = BackgroundColor;
		//articleImageView.setRoundedEdge(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10);
		articleImageView.layer.borderColor = BackgroundGrayColor.cgColor;
		articleImageView.layer.borderWidth = 0.5;
		articleImageView.layer.cornerRadius = 7;
		articleImageView.clipsToBounds = true;
		
		let spacing = CGFloat(10);
		
		let articleTitleFrame = CGRect(x: articleImageViewFrame.size.width + spacing, y: 0, width: articleTextWidth-spacing, height: min(articleSingle.articleTitle?.getHeight(withConstrainedWidth: articleTextWidth-spacing, font: UIFont(name: "SFProDisplay-Semibold", size: 18)!) ?? 50, 50));
		let articleTitle = UILabel(frame: articleTitleFrame);
		articleTitle.text = articleSingle.articleTitle ?? "";
		articleTitle.textAlignment = .left;
		articleTitle.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
		articleTitle.numberOfLines = 0;
		articleTitle.textColor = InverseBackgroundColor;
		
		var text = "";
		if (articleSingle.hasHTML){
			text = parseHTML(s: articleSingle.articleBody ?? "").string;
		}
		else{
			text = (articleSingle.articleBody ?? "");
		}
		let articleBodyFrame = CGRect(x: articleImageViewFrame.size.width + spacing, y: articleTitleFrame.maxY, width: articleTextWidth-spacing, height: mainArticleView.frame.height - articleTitleFrame.maxY - 5);
		let articleBody = UITextView(frame: articleBodyFrame);
		articleBody.text = text;
		articleBody.textAlignment = .left;
		articleBody.font = UIFont(name: "SFProDisplay-Regular", size: 14);
		articleBody.isEditable = false;
		articleBody.isSelectable = false;
		articleBody.isUserInteractionEnabled = false;
		articleBody.isScrollEnabled = false;
		articleBody.textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0);
		articleBody.textContainer.lineBreakMode = .byTruncatingTail;
		articleBody.textColor = InverseBackgroundColor;
		
		
		let timeStampText = epochClass.epochToString(epoch: articleSingle.articleUnixEpoch ?? -1);
		let timeStampFrame = CGRect(x: 7, y: height - 25, width: timeStampText.getWidth(withConstrainedHeight: 15, font: UIFont(name: "SFProDisplay-Semibold", size: 8)!) + 10, height: 15);
		let timeStamp = UILabel(frame: timeStampFrame);
		timeStamp.text = timeStampText;
		//timeStamp.text = "12 months ago";
		timeStamp.textAlignment = .center;
		timeStamp.textColor = UIColor.gray;
		timeStamp.font = UIFont(name: "SFProDisplay-Semibold", size: 8);
		timeStamp.backgroundColor = UIColor.white;
		//timeStamp.setRoundedEdge(corners: [.bottomRight, .bottomLeft, .topRight, .topLeft], radius: 3);
		timeStamp.layer.borderColor = UIColor.gray.cgColor;
		timeStamp.layer.borderWidth = 0.5;
		timeStamp.layer.cornerRadius = 3;
		timeStamp.clipsToBounds = true;
		timeStamp.textColor = InverseBackgroundColor;
		timeStamp.backgroundColor = BackgroundColor;
		
		
		mainArticleView.addSubview(articleImageView);
		mainArticleView.addSubview(articleTitle);
		mainArticleView.addSubview(articleBody);
		mainArticleView.addSubview(timeStamp);
		
		//articleImageView.layer.cornerRadius = 10;
		mainArticleView.addTarget(self, action: #selector(self.openArticle), for: .touchUpInside);
		
		//mainArticleView.backgroundColor = UIColor.lightGray;
		mainArticleView.articleCompleteData = articleSingle;
		
		return mainArticleView;
	}
	
	private func setUpAllViews(){
		
		setUpConnection();
		if (internetConnected && (homeArticleList[0].count > 0 || homeArticleList[1].count > 0 || homeArticleList[2].count > 0)){
			
			featuredLabel.text = "Featured";
			asbLabel.text = "ASB News";
			generalLabel.text = "General Info";
			districtLabel.text = "District News";
	  
			
			let generalInfoArticlePairs = arrayToPairs(a: homeArticleList[0]);
			let districtArticlePairs = arrayToPairs(a: homeArticleList[1]);
			let asbArticlePairs = arrayToPairs(a: homeArticleList[2]);
			featuredSize = featuredArticles.count;
			asbNewsSize = asbArticlePairs.count;
			generalInfoSize = generalInfoArticlePairs.count;
			districtNewsSize = districtArticlePairs.count;
			
			// scrollview variables
			let scrollViewHorizontalConstraints = CGFloat(38);
			
			for view in featuredScrollView.subviews{
				if (view.tag == 1){
					view.removeFromSuperview();
				}
			}
			for view in asbNewsScrollView.subviews{
				view.removeFromSuperview();
			}
			for view in generalInfoScrollView.subviews{
				view.removeFromSuperview();
			}
			for view in districtNewsScrollView.subviews{
				view.removeFromSuperview();
			}
			
			if (featuredSize > 0){
				// Featured News ----- NOTE - article is not created by smallArticle() func
				
				featuredArticles.sort(by: sortArticlesByTime);
				
				featuredScrollView.flashScrollIndicators();
				featuredMissingLabel.isHidden = true;
				featuredScrollView.isHidden = false;
				featuredFrame.size = featuredScrollView.frame.size;
				featuredFrame.size.height -= 15;
				featuredFrame.size.width = UIScreen.main.bounds.size.width;
				featuredScrollView.contentSize = CGSize(width: (featuredFrame.size.width * CGFloat(featuredSize)), height: featuredScrollView.frame.size.height);
				for aIndex in 0..<featuredSize{
					featuredFrame.origin.x = (featuredFrame.size.width * CGFloat(aIndex));
					
					let currArticle = featuredArticles[aIndex];
					
					let outerContentView = CustomUIButton(frame: featuredFrame);
					
					let innerContentViewContraint = CGFloat(20);
					let contentViewFrame = CGRect(x: innerContentViewContraint, y: 0, width: featuredFrame.size.width - (2*innerContentViewContraint), height: featuredFrame.size.height);
					let contentView = CustomUIButton(frame: contentViewFrame);
					
					
					let articleCatagorytext = (currArticle.articleCatagory ?? "No Cata.") + (currArticle.articleCatagory == "General Info" ? "" : " News");
					let articleCatagoryFrame = CGRect(x: 0, y: contentViewFrame.size.height - 20, width: articleCatagorytext.getWidth(withConstrainedHeight: 20, font: UIFont(name: "SFProText-Bold", size: 12)!) + 12, height: 20);
					let articleCatagory = UILabel(frame: articleCatagoryFrame);
					articleCatagory.text = articleCatagorytext;
					articleCatagory.textAlignment = .center;
					articleCatagory.textColor = .white;
					articleCatagory.backgroundColor = mainThemeColor;
					articleCatagory.font = UIFont(name: "SFProText-Bold", size: 12);
					articleCatagory.setRoundedEdge(corners: [.bottomRight, .bottomLeft, .topRight, .topLeft], radius: 5);
					
					let timeStampFrame = CGRect(x: articleCatagoryFrame.size.width, y: contentViewFrame.size.height - 20, width: 120, height: 20);
					let timeStamp = UILabel(frame: timeStampFrame);
					timeStamp.text = "   ∙   " + epochClass.epochToString(epoch: currArticle.articleUnixEpoch ?? -1);
					timeStamp.textAlignment = .left;
					timeStamp.textColor = UIColor.lightGray;
					timeStamp.font = UIFont(name: "SFProDisplay-Semibold", size: 12);
					
					let title = currArticle.articleTitle ?? "";
					let height = min(53, title.getHeight(withConstrainedWidth: contentViewFrame.size.width, font: UIFont(name: "SFProDisplay-Semibold", size: 22)!))+5;
					let titleLabelFrame = CGRect(x: 0, y: contentViewFrame.size.height-20-height, width: contentViewFrame.size.width, height: height);
					let titleLabel = UILabel(frame: titleLabelFrame);
					titleLabel.text = title;
					titleLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 22);
					titleLabel.textAlignment = .left;
					titleLabel.textColor = InverseBackgroundColor;
					titleLabel.numberOfLines = 2;
					//SFProText-Bold, SFProDisplay-Regular, SFProDisplay-Semibold, SFProDisplay-Black
					
					let imageViewFrame = CGRect(x: 0, y: 0, width: contentViewFrame.size.width, height: titleLabelFrame.minY);
					let imageView = UIImageView(frame: imageViewFrame);
					imageView.imgFromURL(sURL: currArticle.articleImages?[0] ?? "");
					imageView.contentMode = .scaleAspectFill;
					imageView.setRoundedEdge(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 5);
					imageView.clipsToBounds = true;
					imageView.layer.borderColor = UIColor.gray.cgColor;
					imageView.layer.borderWidth = 0.5;
					imageView.layer.cornerRadius = 5;
					imageView.backgroundColor = BackgroundColor;
					
					contentView.addSubview(timeStamp);
					contentView.addSubview(articleCatagory);
					contentView.addSubview(titleLabel);
					contentView.addSubview(imageView);
					
					outerContentView.articleCompleteData = currArticle;
					contentView.articleCompleteData = currArticle;
					
					contentView.addTarget(self, action: #selector(openArticle), for: .touchUpInside);
					
					
					outerContentView.addSubview(contentView);
					
					outerContentView.addTarget(self, action: #selector(openArticle), for: .touchUpInside);
					
					outerContentView.tag = 1;
					
					self.featuredScrollView.addSubview(outerContentView);
				}
				// change horizontal size of scrollview
				featuredScrollView.delegate = self;
				featuredScrollView.showsHorizontalScrollIndicator = true;
				featuredScrollView.backgroundColor = BackgroundColor;
				
			}
			else{
				featuredMissingLabel.isHidden = false;
				featuredScrollView.isHidden = true;
			}
			
			
			// Sports News -----
			generalInfoPageControl.numberOfPages = generalInfoSize;
			generalInfoFrame.size = generalInfoScrollView.frame.size;
			generalInfoFrame.size.width = UIScreen.main.bounds.size.width - scrollViewHorizontalConstraints;
			for aIndex in 0..<generalInfoSize{
				generalInfoFrame.origin.x = (generalInfoFrame.size.width * CGFloat(aIndex));
				
				
				
				// create content in scrollview
				let contentView = UIView(frame: generalInfoFrame); // wrapper for article
				
				contentView.addSubview(smallArticle(x: 0, y: 0, width: generalInfoFrame.size.width, height: 120, articleSingle: generalInfoArticlePairs[aIndex][0]));
				
				if (generalInfoArticlePairs[aIndex].count == 2){
					// B button
					contentView.addSubview(smallArticle(x: 0, y: 120, width: generalInfoFrame.size.width, height: 120, articleSingle: generalInfoArticlePairs[aIndex][1]));
				}
				
				self.generalInfoScrollView.addSubview(contentView);
			}
			// change horizontal size of scrollview
			generalInfoScrollView.contentSize = CGSize(width: (generalInfoFrame.size.width * CGFloat(generalInfoSize)), height: generalInfoScrollView.frame.size.height);
			generalInfoScrollView.delegate = self;
			
			
			// District News -----
			districtNewsPageControl.numberOfPages = districtNewsSize;
			districtNewsFrame.size = districtNewsScrollView.frame.size;
			districtNewsFrame.size.width = UIScreen.main.bounds.size.width - scrollViewHorizontalConstraints;
			for aIndex in 0..<districtNewsSize{
				districtNewsFrame.origin.x = (districtNewsFrame.size.width * CGFloat(aIndex));
				
				// create content in scrollview
				let contentView = UIView(frame: districtNewsFrame); // wrapper for article
				contentView.addSubview(smallArticle(x: 0, y: 0, width: districtNewsFrame.size.width, height: 120, articleSingle: districtArticlePairs[aIndex][0]));
				
				if (districtArticlePairs[aIndex].count == 2){
					// B button
					contentView.addSubview(smallArticle(x: 0, y: 120, width: districtNewsFrame.size.width, height: 120, articleSingle: districtArticlePairs[aIndex][1]));
				}
				
				self.districtNewsScrollView.addSubview(contentView);
			}
			// change horizontal size of scrollview
			districtNewsScrollView.contentSize = CGSize(width: (districtNewsFrame.size.width * CGFloat(districtNewsSize)), height: districtNewsScrollView.frame.size.height);
			districtNewsScrollView.delegate = self;
			
			// ASB News -----
			asbNewsPageControl.numberOfPages = asbNewsSize;
			asbNewsFrame.size = asbNewsScrollView.frame.size;
			asbNewsFrame.size.width = UIScreen.main.bounds.width - scrollViewHorizontalConstraints;
			for aIndex in 0..<asbNewsSize{
				asbNewsFrame.origin.x = (asbNewsFrame.size.width * CGFloat(aIndex));
				
				
				// create content in scrollview
				let contentView = UIView(frame: asbNewsFrame); // wrapper for article
				//contentView.backgroundColor = UIColor.gray;
				
				contentView.addSubview(smallArticle(x: 0, y: 0, width: asbNewsFrame.size.width, height: 120, articleSingle: asbArticlePairs[aIndex][0]));
				if (asbArticlePairs[aIndex].count == 2){
					// B button
					contentView.addSubview(smallArticle(x: 0, y: 120, width: asbNewsFrame.size.width, height: 120, articleSingle: asbArticlePairs[aIndex][1]));
				}
				
				self.asbNewsScrollView.addSubview(contentView);
			}
			// change horizontal size of scrollview
			asbNewsScrollView.contentSize = CGSize(width: (asbNewsFrame.size.width * CGFloat(asbNewsSize)) , height: asbNewsScrollView.frame.size.height);
			asbNewsScrollView.delegate = self;
			
		}
	}
	
	override func viewDidLoad() { // setup function
		super.viewDidLoad();
		
		featuredLabel.text = loading;
		asbLabel.text = loading;
		generalLabel.text = loading;
		districtLabel.text = loading;
		
		mainScrollView.alwaysBounceVertical = true;
		getHomeArticleData();
		refreshControl.addTarget(self, action: #selector(refreshAllArticles), for: UIControl.Event.valueChanged);
		mainScrollView.addSubview(refreshControl);
		mainScrollView.delegate = self;
	}
	
	override func viewDidAppear(_ animated: Bool) {
		refreshControl.didMoveToSuperview();
	}
	
	internal func  scrollViewDidScroll(_ scrollView: UIScrollView) {
		if (scrollView.tag != -1){
			
			asbNewsPageControl.currentPage = Int(round(asbNewsScrollView.contentOffset.x / asbNewsFrame.size.width));
			
			generalInfoPageControl.currentPage = Int(round(generalInfoScrollView.contentOffset.x / generalInfoFrame.size.width));
			
			districtNewsPageControl.currentPage = Int(round(districtNewsScrollView.contentOffset.x / districtNewsFrame.size.width));
		}
	}
	
	
}

