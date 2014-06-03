//
//  FQFacebookHelper.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 31/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FQFacebookHelper : NSObject <FBLoginViewDelegate>

typedef void (^FBFriendsFetchedBlock)(NSArray *);

+ (id)sharedAPI;
- (void)setupHelperWithFriendsFetchedBlock:(FBFriendsFetchedBlock)friendsFetchedBlock;

@end
