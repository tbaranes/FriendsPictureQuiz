//
//  FQGameViewController.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FQFriendProfile;
@interface FQGameViewController : UIViewController

@property (strong, nonatomic) FQFriendProfile *itemSelected;

@property (strong, nonatomic) IBOutlet UIImageView *imagePictureProfile;


@property (strong, nonatomic) IBOutlet UIView *viewFinalName;
@property (strong, nonatomic) IBOutlet UIView *viewLetterChoice;

@end
