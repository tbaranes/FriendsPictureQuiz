//
//  FQHomeFooterReusableView.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBLoginView;
@interface FQHomeFooterReusableView : UICollectionReusableView

@property (strong, nonatomic) IBOutlet UILabel *labelFacebookTitle;
@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (strong, nonatomic) IBOutlet UILabel *labelTwitter;
@property (strong, nonatomic) IBOutlet UIButton *btnTwitter;

- (void)configureFooter;

@end
