//
//  FQGameViewController.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import "FQGameViewController.h"
// View
#import "FQLetterCell.h"
// Model
#import "FQFriendProfile.h"
#import "FQLetter.h"
// Other
#import "FQGameManager.h"

@interface FQGameViewController ()

#define SIZE_CELL_KEYBOARD CGSizeMake(39.f, 39.f)
#define NUMBER_CHARACTER_MAX_TO_HIDE 16

#define NB_MIN_LETTER_PER_LINE 1
#define NB_MAX_LETTER_PER_LINE 12

#define INSET_SECTION 5.f
#define SECTION_TO_FILL 0
#define SECTION_KEYBOARD 1

@property (strong, nonatomic) FQGameManager *gameManager;
@property (nonatomic) CGSize sizeCharacter;

@end

@implementation FQGameViewController

static NSString *cellIdentifier = @"FQLetterdentifier";

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view convertLocalizebleStrings];
	
	self.gameManager = [[FQGameManager alloc] initWithName:[self.itemSelected name]];
	[self.gameManager setupManager];
	[self setupImageToFind];
	[self calcCharacterSizeWithNbMaxElementPerLine:NB_MIN_LETTER_PER_LINE];
}

- (void)calcCharacterSizeWithNbMaxElementPerLine:(NSInteger)nbMaxElementPerLine {
	NSInteger nbMaxPerLine = [self getNbCharactersFilled] > nbMaxElementPerLine ? nbMaxElementPerLine : [self getNbCharactersFilled];
	NSInteger width = floor(CGRectGetWidth([self.collectionView bounds]));
	NSInteger sizeElement = width / nbMaxPerLine - 1;
	
	self.sizeCharacter = CGSizeMake(sizeElement, sizeElement);
	NSInteger heightKeyboard = [self heightKeyboard];
	NSInteger freeBottomPlace = [self calcFreeBottomPlace];
	if (heightKeyboard >= freeBottomPlace && [self getNbCharactersFilled] >= nbMaxElementPerLine && nbMaxElementPerLine <= NB_MAX_LETTER_PER_LINE) {
		[self calcCharacterSizeWithNbMaxElementPerLine:nbMaxPerLine + 1];
	}
}


#pragma mark - Setup UI

- (void)setupImageToFind {
	[self.imageIsFound setHidden:![self.itemSelected isFound]];

	UIImage *profilePicture = [self.itemSelected fetchProfilePicture];
	if (![self.itemSelected isFound]) {
		profilePicture = [profilePicture boxblurImageWithBlur:IMAGE_BLUR];
	}
	[self.imagePictureProfile setImage:profilePicture];
}

#pragma mark - IBAction

- (IBAction)resetPressed:(id)sender {
	[self.gameManager resetLettersWithIndexPathPerLetter:^(FQLetter *letter, NSIndexPath *indexPath) {
		[self moveLetterSelectedOnKeyboard:letter atIndexPath:indexPath];
	}];
}

#pragma mark - End game

- (void)isKeyboardFilled {
	if (![self.gameManager isKeyboardToFillFull]) {
		return;
	}
	
	if ([self.gameManager isGameEnd]) {
		[UIAlertView showTitle:NSLocalizedString(@"game.end_game.title", nil) message:NSLocalizedString(@"game.end_game.win", nil)];
		self.friendIsFoundBlock();
		[self.imageIsFound setHidden:NO];
		[self.imagePictureProfile setImage:[self.itemSelected fetchProfilePicture]];
	} else {
		[UIAlertView showTitle:NSLocalizedString(@"game.end_game.title", nil) message:NSLocalizedString(@"game.end_game.lose", nil)];
	}
}

#pragma mark - Helper

- (NSInteger)getNbCharactersFilled {
	return [self.gameManager.charactersToFill count] + 1;
}

- (FQLetter *)letterAtIndexPath:(NSIndexPath *)indexPath {
	return [self.gameManager letterAtIndexPath:indexPath];
}

- (NSInteger)heightKeyboardTofill {
	NSInteger nbCharacterPerLine = floorf(CGRectGetWidth([self.collectionView bounds])) / (self.sizeCharacter.width + 1);
	NSInteger nbLines = ([self getNbCharactersFilled] / nbCharacterPerLine) + 1;
	NSInteger heightKeyboardToFill = ((self.sizeCharacter.height + 1) * nbLines) + (INSET_SECTION * 2);
	return heightKeyboardToFill;
}

- (NSInteger)heightKeyboard {
	return (SIZE_CELL_KEYBOARD.height + 1 + INSET_SECTION) * 2;
}

- (NSInteger)calcFreeBottomPlace {
	NSInteger heightKeyboardToFill = [self heightKeyboardTofill];
	NSInteger height = floorf(CGRectGetHeight([self.collectionView bounds]));
	NSInteger bottomMarginFree =  height - heightKeyboardToFill;
	return bottomMarginFree;
}

#pragma mark - UICollectionView datasource & delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return section == SECTION_TO_FILL ? [self getNbCharactersFilled] : [self.gameManager.charactersKeyboard count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FQLetterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
	FQLetter *model = [self letterAtIndexPath:indexPath];
	[cell configureCellWithModel:model];
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == SECTION_TO_FILL) {
		return self.sizeCharacter;
	}
	return SIZE_CELL_KEYBOARD;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	FQLetter *letterSelected = [self letterAtIndexPath:indexPath];
	if (letterSelected && ![letterSelected isFix]) {
		if (indexPath.section == SECTION_KEYBOARD) {
			[self moveLecterSelectedFromKeyboard:letterSelected atIndexPath:indexPath];
		} else {
			[self moveLetterSelectedOnKeyboard:letterSelected atIndexPath:indexPath];
		}
		[self isKeyboardFilled];
	}
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	if (section == SECTION_TO_FILL) {
		NSInteger bottomInset = [self calcFreeBottomPlace] - [self heightKeyboard];
		return UIEdgeInsetsMake(INSET_SECTION, 0, bottomInset > 0 ? bottomInset : INSET_SECTION, 0);
	}
	return UIEdgeInsetsMake(INSET_SECTION, 0, INSET_SECTION, 0);
}

#pragma mark - Letters movement

- (void)moveLecterSelectedFromKeyboard:(FQLetter *)letterSelected atIndexPath:(NSIndexPath *)indexPath {
	[self.gameManager moveLecterSelectedFromKeyboard:letterSelected atIndexPath:indexPath completion:^(NSArray *indexPaths) {
		[self.collectionView reloadItemsAtIndexPaths:indexPaths];
	}];
}

- (void)moveLetterSelectedOnKeyboard:(FQLetter *)letterSelected atIndexPath:(NSIndexPath *)indexPath {
	[self.gameManager moveLetterSelectedOnKeyboard:letterSelected atIndexPath:indexPath completion:^(NSArray *indexPaths) {
		[self.collectionView reloadItemsAtIndexPaths:indexPaths];
	}];
}

@end
