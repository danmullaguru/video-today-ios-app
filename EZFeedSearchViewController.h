//
//  EZChannelSearchViewController.h
//  EZ Tube
//
//  Created by dan mullaguru on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataYouTube.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataBaseElements.h"
#import "TSDownloadManager.h"
#import "EZFeedSearchVideoCellView.h"
#import "TSVideoViewController.h"
#import "Feed.h"
#import "AudioToolbox/AudioToolbox.h"
#import "EZUtility.h"
#import "LocalizationSystem.h"


@protocol EZFeedSearchViewControllerDelegate <NSObject>

//-(void) addNewVideoFeedRecord:(NSDictionary *)videoSource;
-(void) addNewVideoFeedRecord:(NSMutableDictionary *)videoFeed informAboutFeeds:(BOOL)inform;
-(void) popVideo:(NSString *)videoId title:(NSString *)title;
-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId;
-(void) informAboutNewFeeds;
-(void) loadAllVideosInExternalPlayerWithVideoSetArray:(NSArray*)videoSetArray  feedChannelInfo:(NSDictionary *)feed_OR_Channel_info StartingWithVideoIndex:(int)index;

@end



@interface EZFeedSearchViewController : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource,EZFeedSearchVideoCellViewDelegate,UIPopoverControllerDelegate,UITextFieldDelegate>
{
     id<EZFeedSearchViewControllerDelegate> delegate;
    int start_index;
    int max_results;
    
    NSString * videoFeedId ;
    NSString * videoFindType ;
    NSString * videoSearchQueryString ;
    NSString * videoSearchSortString ;
    
    NSString * selectedFeedType ;
    NSString * selectedFeedPeriod ;
    NSString * selectedFeedRegion ;
    NSString * selectedFeedCategory ;
    
    NSString * currentFeedUniqueEZId ;
    NSString * currentFeedRecommendedDisplayName ;
    NSTimer *aTimer;
}

@property int start_index;
@property int max_results;

@property (strong, nonatomic) id<EZFeedSearchViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,retain) NSArray * pickerArraySearchType;
@property (nonatomic,retain) NSArray * pickerArraySearchPeriod;
@property (nonatomic,retain) NSArray * pickerArraySearchRegion;
@property (nonatomic,retain) NSArray * pickerArraySearchRegionFlags;
@property (nonatomic,retain) NSArray * pickerArraySearchChanneltype;
@property (nonatomic,retain) NSArray * pickerArraySearchChanneltypeIcons;
@property (nonatomic,retain) NSArray * pickerArraySortBy;

@property (nonatomic,retain) NSArray * pickerArraySearchType_keys;
@property (nonatomic,retain) NSArray * pickerArraySearchPeriod_keys;
@property (nonatomic,retain) NSArray * pickerArraySearchRegion_keys;
@property (nonatomic,retain) NSArray * pickerArraySearchChanneltype_keys;
@property (nonatomic,retain) NSArray * pickerArraySortBy_keys;





@property (retain, nonatomic) IBOutlet UIPickerView *pickerViewFeed;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerViewSort;

@property (retain, nonatomic) IBOutlet UITextField *keywordField;



@property (nonatomic, retain) NSString * currentYoutubeAPISearchType;
@property (nonatomic, retain) TSVideoViewController *videoViewController;

@property (nonatomic, retain) NSString * videoFeedId ;
@property (nonatomic, retain) NSString * videoFindType ;
@property (nonatomic, retain) NSString * videoSearchQueryString ;

@property (nonatomic, retain) NSString * videoSearchSortString ;
@property (nonatomic, retain) NSString * videoSearchSortStringDisplay ;

@property (nonatomic, retain) NSString * selectedFeedType ;
@property (nonatomic, retain) NSString * selectedFeedPeriod ;
@property (nonatomic, retain) NSString * selectedFeedRegion ;
@property (nonatomic, retain) NSString * selectedFeedCategory ;
@property (nonatomic, retain) NSString * selectedSearchSortBy ;
@property (nonatomic, retain) LocalizationSystem * ls;

@property (nonatomic, retain) NSString * currentFeedUniqueEZId ;
@property (nonatomic, retain) NSString * currentFeedRecommendedDisplayName ;

@property (nonatomic, retain) NSMutableArray * feedVideoResultsArray ;

@property (retain, nonatomic) IBOutlet UIScrollView *videosScrollView;
@property (retain, nonatomic) IBOutlet UILabel *currentFeedLbl;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *feedActivityIndicator;

@property (retain, nonatomic) IBOutlet UILabel *feedAddStatusLbl;
@property (nonatomic) dispatch_queue_t videoFeedDownloadQueue;

@property (retain, nonatomic) IBOutlet UIButton *spinButton;
@property (retain, nonatomic) IBOutlet UIButton *findVideosButton;
@property (retain, nonatomic) IBOutlet UIButton *searchButtonTop;
@property (retain, nonatomic) IBOutlet UIButton *prevButton;

@property (retain, nonatomic) IBOutlet UIButton *nextButton;
@property (retain, nonatomic) IBOutlet UIButton *addVideoFeedButton;

- (IBAction)addVideoFeed:(id)sender;
- (IBAction)SpinTheWheel:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *feedTypeButton;
- (IBAction)feedTypeButtonPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *feedPeriodButton;
- (IBAction)feedPeriodButtonPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *feedCountryButton;
- (IBAction)feedCountryButtonPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *feedCategoryButton;
@property (retain, nonatomic) IBOutlet UILabel *orLbl;
@property (retain, nonatomic) IBOutlet UILabel *keywordSearchLbl;
@property (retain, nonatomic) IBOutlet UILabel *sortedByLbl;

@property (retain, nonatomic) IBOutlet UIImageView *countryIconImageView;
@property (retain, nonatomic) IBOutlet UIImageView *categoryIconImageView;



- (IBAction)feedCategoryButtonPressed:(id)sender;


@property (retain, nonatomic) IBOutlet UILabel *currentFeedStartEndLbl;
- (IBAction)showNext:(id)sender;
- (IBAction)showPrevious:(id)sender;

//-(void) loadLanguageUI;



- (IBAction)searchVideos:(id)sender;
-(void) clearCurrentFeed;
-(void) setVCtoCurrentLanguage;
-(void) loadDefaultFeedsForCountryLocale;
-(void) createFeedForFeedId:(NSString *)feedId 
                 feedPeriod:(NSString *)feedPeriod 
                 feedRegion:(NSString *)feedRegion 
               feedCategory:(NSString *)feedCategory;


@end
