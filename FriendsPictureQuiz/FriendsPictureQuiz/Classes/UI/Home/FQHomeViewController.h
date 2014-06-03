//
//  FQHomeViewController.h
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQHomeViewController : UICollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
