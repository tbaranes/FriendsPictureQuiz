//
//  FQTwitterHelper.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 31/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQTwitterHelper : NSObject

+ (id)sharedAPI;
- (BOOL)isLogged;
- (void)loginWithCompletion:(void (^)())completion;

- (void)fetchTwitterFollowingWithCompletion:(void (^)(NSArray *friends))completion;

@end
