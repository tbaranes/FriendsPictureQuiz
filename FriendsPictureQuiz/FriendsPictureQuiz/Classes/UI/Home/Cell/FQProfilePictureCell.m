//
//  FQProfilePictureCell.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import "FQProfilePictureCell.h"
#import "FQFriendProfile.h"

@implementation FQProfilePictureCell

#pragma mark - 

- (void)awakeFromNib {
	[super awakeFromNib];
}

#pragma mark - Data management

- (void)configureCellWithModel:(FQFriendProfile *)item {
	[self setItem:item];
	[self.imageIsValid setHidden:![item isFound]];
	UIImage *profilePicture = [item fetchProfilePicture];
	if (![item isFound]) {
		profilePicture = [profilePicture boxblurImageWithBlur:IMAGE_BLUR];
	}
	[self.imageProfilePicture setImage:profilePicture];
}
								
@end
