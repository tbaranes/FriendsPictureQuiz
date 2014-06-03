//
//  FQHomeFooterReusableView.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "FQHomeFooterReusableView.h"
// Other
#import "FQFacebookHelper.h"
#import "FQTwitterHelper.h"

@implementation FQHomeFooterReusableView

#pragma mark - Life cycle

- (void)awakeFromNib {
	[super awakeFromNib];
	self.fbLoginView.readPermissions = @[@"public_profile", @"user_friends", @"read_friendlists"];
}

#pragma mark - Management data

- (void)configureFooter {
	
	NSString *key = [FBSession activeSession].isOpen ? @"home.facebook.logout" : @"home.facebook.login";
	[self.labelFacebookTitle setText:NSLocalizedString(key, nil)];
	[self.fbLoginView setDelegate:[FQFacebookHelper sharedAPI]];

	[self.labelTwitter setText:NSLocalizedString(@"home.twitter.msg", nil)];
	[self.btnTwitter setTitle:NSLocalizedString(@"home.twitter.title", nil) forState:UIControlStateNormal];
}

@end
