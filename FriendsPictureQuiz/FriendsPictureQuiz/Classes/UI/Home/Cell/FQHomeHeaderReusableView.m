//
//  FQHomeHeaderReusableView.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import "FQHomeHeaderReusableView.h"

@implementation FQHomeHeaderReusableView

#pragma mark - 

- (void)awakeFromNib {
	[super awakeFromNib];
}

#pragma mark -

- (void)configureHomeWithNbFriendsFound:(NSInteger)nbFriendsFounds totFriends:(NSInteger)totFriends {
	NSString *title = [NSString stringWithFormat:@"%@ %ld/%ld %@", NSLocalizedString(@"home.friends_found.message", nil), (long)nbFriendsFounds, (long)totFriends, NSLocalizedString(@"generic.word.friends", nil)];
	[self.labelTitle setText:title];	
	[self.progressView setProgress:(CGFloat)nbFriendsFounds / totFriends];
}

@end
