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

@interface FQGameViewController ()

#define NUMBER_CHARACTER_MAX_TO_HIDE 15
#define SIZE_CELL_KEYBOARD CGSizeMake(39.f, 39.f)
#define TAG_INC 100

@property (strong, nonatomic) NSMutableArray *charactersToFill;
@property (strong, nonatomic) NSMutableArray *charactersKeyboard;
@property (nonatomic) NSInteger nbCharactersFound;
@property (nonatomic) CGSize sizeCharacter;

@end

@implementation FQGameViewController

static NSString *cellIdentifier = @"FQLetterdentifier";

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view convertLocalizebleStrings];
	
	[self initializeCharactersToFill];
	[self initializeKeyboard];
	[self setupImageToFind];
	[self calcCharacterSize];
}

#pragma mark - Initialize virtual keyboard

- (void)initializeCharactersToFill {
	self.charactersKeyboard = [NSMutableArray array];
	self.charactersToFill = [NSMutableArray array];
	NSString *name = [self.itemSelected name];
	NSInteger characterHidden = 0;
	
	for (int i = 0; i < [name length]; i++) {
		NSString *ichar  = [NSString stringWithFormat:@"%c", [name characterAtIndex:i]];
		FQLetter *letter = [FQLetter new];
		[letter setCharacter:ichar];
		if (i % 3 && ![self.charactersToFill containsObject:ichar]) {
			[letter setIsFix:YES];
			self.nbCharactersFound++;
			[self.charactersToFill addObject:letter];
		} else {
			characterHidden++;
			[letter setIsFix:NO];
			[letter setPositionOnKeyboard:[self.charactersKeyboard count]];
			[self.charactersKeyboard addObject:letter];
			
			letter = [FQLetter new];
			[letter setCharacter:@""];
			[self.charactersToFill addObject:letter];
		}
	}
}

- (void)initializeKeyboard {
	NSInteger nbMaxCharactersOnKeyboard = 16;
	while ([self.charactersKeyboard count] < nbMaxCharactersOnKeyboard) {
		char c = (char)('a' + arc4random_uniform(25));
		FQLetter *letter = [FQLetter new];
		[letter setCharacter:[NSString stringWithFormat:@"%c", c]];
		[letter setIsFix:NO];
		[self.charactersKeyboard addObject:letter];
	}
	
	NSUInteger count = [self.charactersKeyboard count];
	for (uint i = 0; i < count; ++i) {
		NSInteger nElements = (NSInteger)count - i;
		NSInteger n = arc4random_uniform((u_int32_t)nElements) + i;
		FQLetter *letterN = [self.charactersKeyboard objectAtIndex:n];
		[letterN setPositionOnKeyboard:i];
		FQLetter *letterI = [self.charactersKeyboard objectAtIndex:i];
		[letterI setPositionOnKeyboard:n];
		[self.charactersKeyboard exchangeObjectAtIndex:i withObjectAtIndex:n];
	}
}

- (void)calcCharacterSize {
	NSInteger nbMaxPerLine = 20;
	NSInteger height = floor(CGRectGetHeight([self.collectionView bounds])) - SIZE_CELL_KEYBOARD.width * 2;
	NSInteger width = floor(CGRectGetWidth([self.collectionView bounds]));
	NSInteger nbElements = [self.charactersToFill count];
	
	self.sizeCharacter = CGSizeMake(52.f, 52.f);
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
	for (FQLetter *letter in self.charactersToFill) {
		if (![letter isFix] && ![[letter character] isEqualToString:@""]) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.charactersToFill indexOfObject:letter] inSection:0];
			[self moveLetterSelectedOnKeyboard:letter atIndexPath:indexPath];
		}
	}
}

#pragma mark - End game

- (BOOL)isKeyboardToFillIsFull {
	for (FQLetter *letter in self.charactersToFill) {
		if ([[letter character] isEqualToString:@""]) {
			return NO;
		}
	}
	return YES;
}

- (void)isKeyboardFilled {
	if (![self isKeyboardToFillIsFull]) {
		return;
	}
	
	if (self.nbCharactersFound == [[self.itemSelected name] length]) {
		[UIAlertView showTitle:NSLocalizedString(@"game.end_game.title", nil) message:NSLocalizedString(@"game.end_game.win", nil)];
		self.friendIsFoundBlock();
		[self.imageIsFound setAlpha:NO];
		[self.imagePictureProfile setImage:[self.itemSelected fetchProfilePicture]];
	} else {
		[UIAlertView showTitle:NSLocalizedString(@"game.end_game.title", nil) message:NSLocalizedString(@"game.end_game.lose", nil)];
	}
}

#pragma mark - Helper

- (FQLetter *)letterAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return [self.charactersToFill objectAtIndex:indexPath.row];
	}
	return [self.charactersKeyboard objectAtIndex:indexPath.row];
}

- (BOOL)isCharacterPositionRight:(FQLetter *)letter {
	NSInteger idx = [self.charactersToFill indexOfObject:letter];
	NSString *goodCharac = [NSString stringWithFormat:@"%c", [[self.itemSelected name] characterAtIndex:idx]];
	return [goodCharac isEqualToString:[letter character]];
}

- (FQLetter *)findCellReadyToBeFilled {
	for (FQLetter *letter in self.charactersToFill) {
		if ([[letter character] isEqualToString:@""]) {
			return letter;
		}
	}
	return nil;
}

#pragma mark - UICollectionView datasource & delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return section == 0 ? [self.charactersToFill count] : [self.charactersKeyboard count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FQLetterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
	FQLetter *model = [self letterAtIndexPath:indexPath];
	[cell configureCellWithModel:model];
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return self.sizeCharacter;
	}
	return SIZE_CELL_KEYBOARD;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	FQLetter *letterSelected = [self letterAtIndexPath:indexPath];
	if (![letterSelected isFix]) {
		if (indexPath.section == 1) {
			[self moveLecterSelectedFromKeyboard:letterSelected atIndexPath:indexPath];
		} else {
			[self moveLetterSelectedOnKeyboard:letterSelected atIndexPath:indexPath];
		}
		[self isKeyboardFilled];
	}
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
//	if (section == 1) {
		return UIEdgeInsetsZero;
//	}
}

#pragma mark - Letters movement

- (void)moveLecterSelectedFromKeyboard:(FQLetter *)letterSelected atIndexPath:(NSIndexPath *)indexPath {
	FQLetter *newLetter = [self findCellReadyToBeFilled];
	if (!newLetter) {		
		return;
	}
	[newLetter setPositionOnKeyboard:[letterSelected positionOnKeyboard]];
	[newLetter setCharacter:[letterSelected character]];
	[newLetter setShouldDidAnAnimation:YES];
	[letterSelected setCharacter:@""];
	[letterSelected setShouldDidAnAnimation:YES];
	
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.charactersToFill indexOfObject:newLetter] inSection:0];
	[self.collectionView reloadItemsAtIndexPaths:@[indexPath, newIndexPath]];
	
	if ([self isCharacterPositionRight:newLetter]) {
		self.nbCharactersFound++;
	}
}

- (void)moveLetterSelectedOnKeyboard:(FQLetter *)letterSelected atIndexPath:(NSIndexPath *)indexPath {
	if ([self isCharacterPositionRight:letterSelected]) {
		self.nbCharactersFound--;
	}

	FQLetter *newLetter = [self.charactersKeyboard objectAtIndex:[letterSelected positionOnKeyboard]];
	[newLetter setCharacter:[letterSelected character]];
	[newLetter setShouldDidAnAnimation:YES];
	[letterSelected setCharacter:@""];
	[letterSelected setShouldDidAnAnimation:YES];
	
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[letterSelected positionOnKeyboard] inSection:1];
	[self.collectionView reloadItemsAtIndexPaths:@[indexPath, newIndexPath]];
}

@end
