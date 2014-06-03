//
//  FQHomeHeaderReusableView.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQHomeHeaderReusableView : UICollectionReusableView

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

- (void)configureHomeWithNbFriendsFound:(NSInteger)nbFriendsFounds totFriends:(NSInteger)totFriends;

@end
