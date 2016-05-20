//
//  TSPreferencesViewController.h
//  TSVideos
//
//  Created by dan mullaguru on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditVideoFeedViewController.h"
#import "EZFeedSearchViewController.h"
#import "Feed.h"
#import "EZFeedsTableCell.h"
#import "LocalizationSystem.h"

@protocol EZFeedsViewControllerDelegate <NSObject>

-(void) doneWithFeedPreferences;

-(void)addedNewFeed;
-(void)editedFeed;
-(void)deletedFeed;
-(void)movedFeed;
-(void) popVideo:(NSString *)videoId title:(NSString *)title;
-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId;
-(void) loadAllVideosInExternalPlayerWithVideoSetArray:(NSArray*)videoSetArray  feedChannelInfo:(NSDictionary *)feed_OR_Channel_info StartingWithVideoIndex:(int)index;

@end

@interface EZFeedsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,EditVideoFeedViewControllerDelegate,EZFeedSearchViewControllerDelegate>
{
id<EZFeedsViewControllerDelegate> delegate;
    UINib *cellLoader;
}
- (IBAction)addButtonPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UITableView *currentFeedsTableView;
@property (retain, nonatomic) IBOutlet UIButton *editButton;

@property (nonatomic, retain) NSDictionary * feedFlagsImagesDictionary;
@property (nonatomic, retain) NSDictionary * feedCategoriesImagesDictionary;

- (IBAction)editChannels:(id)sender;

@property (nonatomic, retain) LocalizationSystem * ls;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) id<EZFeedsViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIImageView *ezFeedsImageView;


-(void) setVCtoCurrentLanguage;

@end
