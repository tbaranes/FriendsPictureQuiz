//
//  FQLetterCell.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 03/06/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import "FQLetterCell.h"
#import "FQLetter.h"

@implementation FQLetterCell

#pragma mark - Life cycle

- (void)awakeFromNib {
	[super awakeFromNib];
}

#pragma mark - Data

- (void)configureCellWithModel:(FQLetter *)letter {
	BOOL isFix = [letter isFix] || [letter onKeyboard];
	UIImage *cellBackground = [UIImage imageNamed:isFix ? @"bg_cell_letter_fixed" : @"bg_cell_letter_unfixed"];
	[self.imageBackground setImage:cellBackground];
	UIColor *textColor = isFix ? [UIColor redColorFQ] : [UIColor whiteColor];
	[self.labelLetter setTextColor:textColor];

	[self.labelLetter setText:[letter character]];
	if ([letter shouldDidAnAnimation]) {
		[self animateLetterWithAlpha:[letter alpha]];
		[letter setShouldDidAnAnimation:NO];
	}
	
	if ([[letter character] isEqualToString:@""]) {
		[self setAlpha:[letter alpha]];
	}
}

#pragma mark - Animation

- (void)animateLetterWithAlpha:(NSInteger)alpha {
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 0.5f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = YES;
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

	[UIView animateWithDuration:0.5f animations:^{
		[self setAlpha:alpha];
	}];
}

@end
