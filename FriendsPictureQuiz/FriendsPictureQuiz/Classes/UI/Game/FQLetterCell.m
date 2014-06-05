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
	[self.imageBackground setHidden:!letter];
	[self.labelLetter setHidden:!letter];
	if (!letter) {
		[self setBackgroundColor:[UIColor redColorFQ]];
	} else {
		[self setBackgroundColor:[UIColor clearColor]];
		[self setHidden:[[letter character] isEqualToString:@""]];
		[self.labelLetter setText:[letter character]];
		if ([letter shouldDidAnAnimation]) {
			[self animateLetterToSize:CGSizeZero];
			[letter setShouldDidAnAnimation:NO];
		}
	}
}

#pragma mark - Animation

- (void)animateLetterToSize:(CGSize)toSize {
	CGRect frame = CGRectZero;
	frame.size = toSize;
	[UIView animateWithDuration:1.f  animations:^{
//		[self setAlpha:0];
	}];
}

@end
