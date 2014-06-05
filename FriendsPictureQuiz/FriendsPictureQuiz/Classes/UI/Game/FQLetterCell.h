//
//  FQLetterCell.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 03/06/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FQLetter;
@interface FQLetterCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageBackground;
@property (strong, nonatomic) IBOutlet UILabel *labelLetter;

- (void)configureCellWithModel:(FQLetter *)letter;
- (void)animateLetterToSize:(CGSize)toSize;

@end
