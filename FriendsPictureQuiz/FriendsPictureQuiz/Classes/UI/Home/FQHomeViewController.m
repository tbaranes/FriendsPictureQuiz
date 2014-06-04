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

- (void)setupUI {
	[self setTitle:NSLocalizedString(@"generic.title_app", nil)];
	self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor redColorFQ]};
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupUI];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_reset"]];
	UIButton *btnReset = [UIButton buttonWithImageView:imageView target:self selector:@selector(resetPressed:)];
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:btnReset]];

	[self setupFacebookStateChanged];
	[self fetchFacebookResult];
	[self loadDataFriends];
}

#pragma mark - IBAction

- (IBAction)resetPressed:(id)sender {
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"home.reset.title", nil) message:NSLocalizedString(@"home.reset.msg", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"generic.word.cancel", nil) otherButtonTitles:NSLocalizedString(@"generic.word.confirm", nil), nil] show];
}

#pragma mark - Facebook

- (void)fetchFacebookResult {
	[[FQFacebookHelper sharedAPI] setFriendsFetchedBlock:^(NSArray *friends) {
		[self filtreAndAddNewFriends:friends];
		[[self.collectionView collectionViewLayout] invalidateLayout];
	}];
}

- (void)setupFacebookStateChanged {
	[[FQFacebookHelper sharedAPI] setFacebookStateChangedBlock:^{
		[self.collectionView reloadData];
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
					if (friends) {
						[self updateUIWithNewFriends:friends];
					}
				}];
			} else {
				[MBProgressHUD hideHUDForView:self.view animated:YES];
				[UIAlertView showTitle:NSLocalizedString(@"twitter.error.title", nil) message:NSLocalizedString(@"twitter.error.no_acccess_or_account", nil)];
			}
		}];
	});
}

- (void)updateUIWithNewFriends:(NSArray *)friends {
	NSInteger oldFriends = [self.items count];	
	[self filtreAndAddNewFriends:friends];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.collectionView reloadData];
		[MBProgressHUD hideHUDForView:self.view animated:YES];
		NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
		[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
		
		NSInteger newFriend = [self.items count] - oldFriends;
		if (newFriend) {
			[UIAlertView showTitle:NSLocalizedString(@"home.new_friends_loaded.title", nil) message:[NSString stringWithFormat:@"%u %@", newFriend, NSLocalizedString(@"home.new_friends_loaded.msg", nil)]];
		} else {
			[UIAlertView showTitle:NSLocalizedString(@"home.new_friends_loaded.title", nil) message:NSLocalizedString(@"home.no_friends_loaded.msg", nil)];
		}
	});
}

#pragma mark - Data

- (NSInteger)filtreAndAddNewFriends:(NSArray *)newFriends {
	NSInteger oldItems = [self.items count];
	NSMutableSet *set = [NSMutableSet setWithArray:newFriends];
	[set addObjectsFromArray:self.items];
	self.items = [set allObjects];
	[self saveFriendsData];
	return [self.items count] - oldItems;
}

- (void)friendWasFound:(FQFriendProfile *)friendFound {
	[friendFound setIsFound:YES];
	[self.collectionView reloadData];
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
		[vc setFriendIsFoundBlock:^{
			[self friendWasFound:sender.item];
		}];
	}
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[[FQTwitterHelper sharedAPI] resetCursor];		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:nil forKey:keyFriendsUserDefaults];
		[userDefaults synchronize];
		self.items = nil;
		[self.collectionView reloadData];

	}
}

@end
