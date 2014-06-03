//
//  FQFacebookHelper.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 31/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import "FQFacebookHelper.h"
#import "FQFriendProfile.h"

@interface FQFacebookHelper ()

@property (strong, nonatomic) FBFriendsFetchedBlock friendsFetchedBlock;

@end

@implementation FQFacebookHelper

#pragma mark - Singleton

+ (id)sharedAPI {
    static dispatch_once_t onceQueue;
    static FQFacebookHelper *instance = nil;
    
    dispatch_once(&onceQueue, ^{ instance = [[self alloc] init]; });
    return instance;
}

#pragma mark - Setup

- (void)setupHelperWithFriendsFetchedBlock:(FBFriendsFetchedBlock)friendsFetchedBlock {
	self.friendsFetchedBlock = friendsFetchedBlock;
}

#pragma mark - Facebook delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
	if ([FBSession activeSession].isOpen) {
		[self fetchUserData];
	}
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
	NSString *alertMessage, *alertTitle;
	
	if ([FBErrorUtility shouldNotifyUserForError:error]) {
		alertTitle = NSLocalizedString(@"facebook.error.title", nil);
		alertMessage = [FBErrorUtility userMessageForError:error];
	} else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
		alertTitle = NSLocalizedString(@"facebook.session_error.title", nil);
		alertMessage = NSLocalizedString(@"facebook.error_session_expired", nil);
		
	} else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
		FSILogD(@"user cancelled login");
	} else {
		alertTitle  = NSLocalizedString(@"generic.error.title", nil);
		alertMessage = NSLocalizedString(@"generic.error.msg", nil);
	}
	
	if (alertMessage) {
		[[[UIAlertView alloc] initWithTitle:alertTitle
									message:alertMessage
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
}

- (void)fetchUserData {
	[FBRequestConnection startWithGraphPath:@"/me/friends" parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		if (error) {
			FSILogD(@"%@", [error localizedDescription]);
		} else {
			NSArray *friends = [result objectForKey:@"data"];
			FSILogD(@"Found: %i friends", friends.count);
			NSMutableArray *myFriends = [NSMutableArray array];
			for (NSDictionary<FBGraphUser> *friend in friends) {
				NSString *pictureURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal", friend.objectID];
				NSDictionary *dic = @{@"id": friend.name, @"name":friend.objectID, @"profile_image_url": pictureURL};
				[myFriends addObject:[[FQFriendProfile alloc] initWithDictionary:dic]];
			}			
			self.friendsFetchedBlock(myFriends);
		}
	}];
}

@end
