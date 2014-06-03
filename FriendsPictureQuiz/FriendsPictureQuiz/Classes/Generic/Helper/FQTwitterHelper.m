//
//  FQTwitterHelper.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 31/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "FQTwitterHelper.h"
#import "FQFriendProfile.h"

@interface FQTwitterHelper ()

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) NSString *nextCursor;

@end

@implementation FQTwitterHelper

static NSString *twitterURLFollowing = @"https://api.twitter.com/1.1/friends/list.json";

#pragma mark - Singleton

+ (id)sharedAPI {
    static dispatch_once_t onceQueue;
    static FQTwitterHelper *instance = nil;
    
    dispatch_once(&onceQueue, ^{ instance = [[self alloc] init]; });
    return instance;
}

#pragma mark - Helper

- (BOOL)isLogged {
	return self.account != nil;
}

#pragma marl - Login

- (void)loginWithCompletion:(void (^)())completion {
	[self getTwitterAccountsWithCompletion:^(ACAccount *account) {
		[self setAccount:account];
		completion();
	}];
}

- (void)getTwitterAccountsWithCompletion:(void (^)(ACAccount *account))completion {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    // let's request access and fetch the accounts
	[accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
		// check that the user granted us access and there were no errors (such as no accounts added on the users device)
		if (granted && !error) {
			NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			if ([accountsArray count] > 1) {
				// a user may have one or more accounts added to their device
				// you need to either show a prompt or a separate view to have a user select the account(s) you need to get the followers and friends for
			} else {
				completion([accountsArray firstObject]);
			}
		} else {
			[UIAlertView showTitle:NSLocalizedString(@"twitter.error.title", nil) message:NSLocalizedString(@"twitter.error.no_account", nil)];
		}
	}];
}

#pragma mark - Handler

- (void)fetchTwitterFollowingWithCompletion:(void (^)(NSArray *friends))completion {
	if (!self.account) {
		[UIAlertView showTitle:NSLocalizedString(@"twitter.error.title", nil) message:NSLocalizedString(@"twitter.error.no_account", nil)];		
		return;
	}
	
	ACAccount *account = self.account;
    NSMutableDictionary *accountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil];
    [accountDictionary setObject:[[[account dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]] objectForKey:@"properties"] objectForKey:@"user_id"] forKey:@"user_id"];
    NSURL *followingURL = [NSURL URLWithString:twitterURLFollowing];
    NSMutableDictionary *parameters = [@{@"screen_name": account.username, @"size": @"bigger"} mutableCopy];
	if (self.nextCursor) {
		[parameters setValue:self.nextCursor forKey:@"cursor"];
	}
	
    SLRequest *twitterRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:followingURL parameters:parameters];
    [twitterRequest setAccount:account];
    [twitterRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		if (error) {
			[UIAlertView showTitle:NSLocalizedString(@"generic.error.title", nil) message:NSLocalizedString(@"generic.error.msg", nil)];
			FSILogD(@"%@", [error localizedDescription]);
		}
		NSDictionary *twitterFriends = [NSJSONSerialization JSONObjectWithData:responseData options:(NSJSONReadingOptions)NSJSONWritingPrettyPrinted error:nil];
		self.nextCursor = [twitterFriends objectForKey:@"next_cursor_str"];
		
		NSArray *following = [self parseDataReceived:[twitterFriends objectForKey:@"users"]];
		completion(following);
    }];
}

- (NSArray *)parseDataReceived:(NSArray *)data {
	NSMutableArray *friends = [NSMutableArray array];
	for (NSDictionary *friend in data) {
		NSString *new = [[friend objectForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString: @"_normal" withString:@"_bigger"];
		[friend setValue:new forKey:@"profile_image_url"];
		[friends addObject:[[FQFriendProfile alloc] initWithDictionary:friend]];
	}
	return friends;
}


@end
