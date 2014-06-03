//
//  FQFriendProfile.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import "FQFriendProfile.h"

@implementation FQFriendProfile

#pragma mark - Init

- (id)initWithDictionary:(NSDictionary *)dic {
	self = [super init];
	if (self) {
		self.itemID = [[dic objectForKey:@"id"] intValue];
		self.name = [dic objectForKey:@"name"];
		self.pictureURL = [dic objectForKey:@"profile_image_url"];
		self.isFound = NO;
	}
	return self;
}

- (UIImage *)fetchProfilePicture {
	if (!self.profilePicture) {
		NSURL *url = [NSURL URLWithString:self.pictureURL];
		NSData *imageData = [NSData dataWithContentsOfURL:url];
		self.profilePicture = [UIImage imageWithData:imageData];
	}
	return self.profilePicture;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.itemID forKey:@"customitemID"];
    [encoder encodeObject:self.pictureURL forKey:@"customPictureURL"];
    [encoder encodeObject:self.name forKey:@"customName"];
    [encoder encodeBool:self.isFound forKey:@"customFound"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.itemID = [decoder decodeIntegerForKey:@"customitemID"];
        self.pictureURL = [decoder decodeObjectForKey:@"customPictureURL"];
        self.name = [decoder decodeObjectForKey:@"customName"];
        self.isFound = [decoder decodeBoolForKey:@"customFound"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    FQFriendProfile *copy = [[FQFriendProfile allocWithZone:zone] init];
    copy->_itemID = self.itemID;
    copy->_name = [self.name copy];
    copy->_pictureURL = [self.pictureURL copy];
    copy->_profilePicture = [self.profilePicture copy];
    copy->_isFound = self.isFound;
    return copy;
}

@end
