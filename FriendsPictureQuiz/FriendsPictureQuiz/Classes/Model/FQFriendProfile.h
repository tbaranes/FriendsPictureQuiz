//
//  FQFriendProfile.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQFriendProfile : NSObject <NSCoding, NSCopying>

@property (nonatomic) NSInteger itemID;
@property (strong, nonatomic) NSString *pictureURL;
@property (strong, nonatomic) UIImage *profilePicture;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) BOOL isFound;

- (id)initWithDictionary:(NSDictionary *)dic;
- (UIImage *)fetchProfilePicture;

@end
