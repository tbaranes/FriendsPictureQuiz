//
//  FQLetter.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 03/06/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FQLetter : NSObject

@property (nonatomic, strong) NSString *character;
@property (nonatomic) NSInteger positionOnKeyboard;
@property (nonatomic) NSInteger alpha;

@property (nonatomic) BOOL isFix;
@property (nonatomic) BOOL onKeyboard;
@property (nonatomic) BOOL shouldDidAnAnimation;

@end
