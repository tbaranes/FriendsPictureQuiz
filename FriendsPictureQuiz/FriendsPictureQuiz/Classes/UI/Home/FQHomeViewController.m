//
//  FQHomeViewController.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

// ViewController
#import "FQHomeViewController.h"
#import "FQGameViewController.h"
// View
#import "FQHomeHeaderReusableView.h"
#import "FQHomeFooterReusableView.h"
#import "FQProfilePictureCell.h"
// Helper
#import "FQTwitterHelper.h"
#import "FQFacebookHelper.h"
// Model
#import "FQFriendProfile.h"

@interface FQHomeViewController ()

@property (strong, nonatomic) NSArray *items;

@end

@implementation FQHomeViewController

static NSString *cellIdentifier = @"FQProfilePictureCell";
static NSString *headerReusableViewIdentifier = @"headerReusableViewIdentifier";
static NSString *footerReusableview = @"footerReusableViewIdentifier";
static NSString *keyFriendsUserDefaults = @"keyFriendsUserDefaults";

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setTitle:NSLocalizedString(@"generic.title_app", nil)];
		
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_reset"]];
	UIButton *btnReset = [UIButton buttonWithImageView:imageView target:self selector:@selector(resetPressed:)];
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:btnReset]];

	[self loadDataFriends];
	[self fetchFacebookResult];
}

#pragma mark - IBAction

- (IBAction)resetPressed:(id)sender {
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"home.reset.title", nil) message:NSLocalizedString(@"home.reset.msg", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"generic.word.cancel", nil) otherButtonTitles:NSLocalizedString(@"generic.word.confirm", nil), nil] show];
}

#pragma mark - Facebook

- (void)fetchFacebookResult {
	[[FQFacebookHelper sharedAPI] setupHelperWithFriendsFetchedBlock:^(NSArray *friends) {
		if ([friends count]) {
			[self filtreAndAddNewFriends:friends];
		}
	}];
}

#pragma mark - Twitter

- (IBAction)twitterLoginPressed:(id)sender {
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		FQTwitterHelper *twitter = [FQTwitterHelper sharedAPI];
		[twitter loginWithCompletion:^{
			if ([twitter isLogged]) {
				[twitter fetchTwitterFollowingWithCompletion:^(NSArray *friends) {
					[self filtreAndAddNewFriends:friends];
				}];
			} else {
				[UIAlertView showTitle:NSLocalizedString(@"twitter.error.title", nil) message:NSLocalizedString(@"twitter.error.no_account", nil)];				
			}
			
			[self.collectionView reloadData];
			[MBProgressHUD hideHUDForView:self.view animated:YES];
		}];
	});
}

#pragma mark - Data

- (void)filtreAndAddNewFriends:(NSArray *)newFriends {
	NSMutableSet *set = [NSMutableSet setWithArray:newFriends];
	[set addObjectsFromArray:self.items];
	self.items = [set allObjects];
	[self saveFriendsData];
}

- (void)saveFriendsData {
	NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[self.items count]];
	for (FQFriendProfile *aFriend in self.items) {
		NSData *personEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:aFriend];
		[archiveArray addObject:personEncodedObject];
	}
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:archiveArray forKey:keyFriendsUserDefaults];
	[userDefaults synchronize];
}

- (void)loadDataFriends {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray *friendData = [userDefaults valueForKey:keyFriendsUserDefaults];
	NSMutableArray *friendsModel = [NSMutableArray arrayWithCapacity:[friendData count]];
	for (NSData *data in friendData) {
		FQFriendProfile *friend = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		[friendsModel addObject:friend];
	}
	self.items = [friendsModel copy];
}

#pragma mark - UICollectionView datasource & delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.items count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

	UICollectionReusableView *reusableView;
	if ([kind isEqualToString:@"UICollectionElementKindSectionFooter"]) {
		FQHomeFooterReusableView *footerReusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerReusableview forIndexPath:indexPath];
		[footerReusableView configureFooter];
		if (![[footerReusableView.btnTwitter allTargets] count]) {
			[footerReusableView.btnTwitter addTarget:self action:@selector(twitterLoginPressed:) forControlEvents:UIControlEventTouchUpInside];
		}
		reusableView = footerReusableView;
	} else {
		FQHomeHeaderReusableView *headerReusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerReusableViewIdentifier forIndexPath:indexPath];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFound == YES"];
		NSInteger friendsFound = [[self.items filteredArrayUsingPredicate:predicate] count];
		[headerReusableView configureHomeWithNbFriendsFound:friendsFound totFriends:[self.items count]];
		reusableView = headerReusableView;
	}
	return reusableView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FQProfilePictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
	FQFriendProfile *model = [self.items objectAtIndex:indexPath.row];
	[cell configureCellWithModel:model];
	return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(FQProfilePictureCell *)sender {
	if ([[segue identifier] isEqualToString:@"ProfilePictureToGameSegueIdentifier"]) {
        FQGameViewController *vc = [segue destinationViewController];
        [vc setItemSelected:sender.item];
	}
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:nil forKey:keyFriendsUserDefaults];
		[userDefaults synchronize];
		
		self.items = nil;
		[self.collectionView reloadData];

	}
}

@end
