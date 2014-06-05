//
//  FQGameManager.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 05/06/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FQLetter;
@interface FQGameManager : NSObject

@property (strong, nonatomic) NSMutableArray *charactersToFill;
@property (strong, nonatomic) NSMutableArray *charactersKeyboard;
@property (nonatomic) NSInteger nbCharactersFound;

- (instancetype)initWithName:(NSString *)name;
- (void)setupManager;

- (void)resetLettersWithIndexPathPerLetter:(void (^)(FQLetter *letter, NSIndexPath *indexPath))letterToMove;
- (void)moveLecterSelectedFromKeyboard:(FQLetter *)letterSelected atIndexPath:(NSIndexPath *)indexPath completion:(void (^)(NSArray *indexPaths))completion;
- (void)moveLetterSelectedOnKeyboard:(FQLetter *)letterSelected atIndexPath:(NSIndexPath *)indexPath completion:(void (^)(NSArray *indexPaths))completion;

- (BOOL)isKeyboardToFillFull;
- (BOOL)isGameEnd;

- (FQLetter *)letterAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isCharacterPositionRight:(FQLetter *)letter;
- (FQLetter *)findCellReadyToBeFilled;

@end
