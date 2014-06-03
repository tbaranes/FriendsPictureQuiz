//
//  FQGameViewController.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import "FQGameViewController.h"
#import "FQFriendProfile.h"

@interface FQGameViewController ()

@property (strong, nonatomic) NSMutableArray *lettersChoice;
@property (strong, nonatomic) NSMutableArray *finalName;

@end

@implementation FQGameViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.imagePictureProfile setImage:[self.itemSelected fetchProfilePicture]];
	
	self.lettersChoice = 
}

- (void)setupLetterChoiceView {
	
}

- (void)setupFinalNameView {
	
}

#pragma mark - IBAction

- (IBAction)resetPressed:(id)sender {
}


@end
