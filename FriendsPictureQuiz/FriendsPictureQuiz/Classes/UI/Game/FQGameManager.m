//
//  FQGameManager.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 05/06/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import "FQGameManager.h"
// Model
#import "FQLetter.h"

@interface FQGameManager ()

#define SECTION_TO_FILL 0
#define SECTION_KEYBOARD 1

@property (strong, nonatomic) NSString *name;

@end

@implementation FQGameManager

- (instancetype)initWithName:(NSString *)name {
	self = [super init];
	if (self) {
		self.name = name;
	}
	return self;
}

#pragma mark - Setup manager

- (void)setupManager {
	[self initializeCharactersToFill];
	[self initializeKeyboard];
}

- (void)initializeCharactersToFill {
	self.charactersKeyboard = [NSMutableArray array];
	self.charactersToFill = [NSMutableArray array];
	NSString *name = self.name;
	NSInteger characterHidden = 0;
	
	for (int i = 0; i < [name length]; i++) {
		NSString *ichar  = [NSString stringWithFormat:@"%c", [name characterAtIndex:i]];
		FQLetter *letter = [FQLetter new];
		[letter setAlpha:1];
		[letter setOnKeyboard:NO];
		[letter setCharacter:ichar];
		if (i % 3 && ![self.charactersToFill containsObject:ichar]) {
			[letter setIsFix:YES];
			self.nbCharactersFound++;
			[self.charactersToFill addObject:letter];
		} else {
			characterHidden++;
			[letter setIsFix:NO];
			[letter setOnKeyboard:YES];
			[letter setPositionOnKeyboard:[self.charactersKeyboard count]];
			[self.charactersKeyboard addObject:letter];
			
			letter = [FQLetter new];
			[letter setCharacter:@""];
			[letter setAlpha:0];
			[letter setShouldDidAnAnimation:YES];
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
		[letter setOnKeyboard:YES];
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

#pragma mark - End game

- (BOOL)isKeyboardToFillFull {
	for (FQLetter *letter in self.charactersToFill) {
		if ([[letter character] isEqualToString:@""]) {
			return NO;
		}
	}
	return YES;
}

- (BOOL)isGameEnd {
	return self.nbCharactersFound == [self.name length];
}

#pragma mark - Game management

- (void)resetLettersWithIndexPathPerLetter:(void (^)(FQLetter *letter, NSIndexPath *indexPath))letterToMove {
	for (FQLetter *letter in self.charactersToFill) {
		if (![letter isFix] && ![[letter character] isEqualToString:@""]) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.charactersToFill indexOfObject:letter] inSection:SECTION_TO_FILL];
			letterToMove(letter, indexPath);
		}
	}
}

#pragma mark - Helper

- (FQLetter *)letterAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == SECTION_TO_FILL && indexPath.row >= [self.charactersToFill count]) {
		return nil;
	} else if (indexPath.section == SECTION_TO_FILL) {
		return [self.charactersToFill objectAtIndex:indexPath.row];
	}
	return [self.charactersKeyboard objectAtIndex:indexPath.row];
}

- (BOOL)isCharacterPositionRight:(FQLetter *)letter {
	NSInteger idx = [self.charactersToFill indexOfObject:letter];
	NSString *goodCharac = [NSString stringWithFormat:@"%c", [self.name characterAtIndex:idx]];
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

#pragma mark - Letters management

- (void)moveLecterSelectedFromKeyboard:(FQLetter *)letterSelected atIndexPath:(NSIndexPath *)indexPath completion:(void (^)(NSArray *indexPaths))completion {
	FQLetter *newLetter = [self findCellReadyToBeFilled];
	if (!newLetter) {
		return;
	}
	[newLetter setPositionOnKeyboard:[letterSelected positionOnKeyboard]];
	[newLetter setCharacter:[letterSelected character]];
	[newLetter setShouldDidAnAnimation:YES];
	[newLetter setAlpha:1];
	[letterSelected setCharacter:@""];
	[letterSelected setAlpha:0];
	[letterSelected setShouldDidAnAnimation:YES];
	
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.charactersToFill indexOfObject:newLetter] inSection:SECTION_TO_FILL];
	completion(@[indexPath, newIndexPath]);
	if ([self isCharacterPositionRight:newLetter]) {
		self.nbCharactersFound++;
	}
}

- (void)moveLetterSelectedOnKeyboard:(FQLetter *)letterSelected atIndexPath:(NSIndexPath *)indexPath completion:(void (^)(NSArray *indexPaths))completion {
	if ([self isCharacterPositionRight:letterSelected]) {
		self.nbCharactersFound--;
	}
	
	FQLetter *newLetter = [self.charactersKeyboard objectAtIndex:[letterSelected positionOnKeyboard]];
	[newLetter setCharacter:[letterSelected character]];
	[newLetter setShouldDidAnAnimation:YES];
	[newLetter setAlpha:1];
	[letterSelected setCharacter:@""];
	[letterSelected setAlpha:0];
	[letterSelected setShouldDidAnAnimation:YES];
	
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[letterSelected positionOnKeyboard] inSection:SECTION_KEYBOARD];
	completion(@[indexPath, newIndexPath]);
}

@end
