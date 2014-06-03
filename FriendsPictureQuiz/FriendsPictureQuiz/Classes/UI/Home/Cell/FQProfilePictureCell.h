//
//  FQProfilePictureCell.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FQFriendProfile;
@interface FQProfilePictureCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet FQFriendProfile *item;
@property (strong, nonatomic) IBOutlet UIImageView *imageProfilePicture;
@property (strong, nonatomic) IBOutlet UIImageView *imageIsValid;

- (void)configureCellWithModel:(FQFriendProfile *)facebookProfile;

@end
