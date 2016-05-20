//
//  EZChannelSearchViewController.m
//  EZ Tube
//
//  Created by dan mullaguru on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EZFeedSearchViewController.h"

@interface EZFeedSearchViewController()
{
    BOOL videoEnteredFullScreen1;// = NO;
    NSArray *pickerArraySearchTypeDisplay;
    NSArray *pickerArraySearchPeriodDisplay;
    NSArray *pickerArraySearchRegionDisplay;
    NSArray *pickerArraySearchChanneltypeDisplay;
    NSArray *pickerArraySearchSortByDisplay;
    
    NSString * selectedFeedTypeDisplay;
    NSString * selectedFeedPeriodDisplay;
    NSString * selectedFeedRegionDisplay;
    NSString * selectedFeedCategoryDisplay;
    
    NSString * selectedFeedType_key;
    NSString * selectedFeedPeriod_key;
    NSString * selectedFeedRegion_key;
    NSString * selectedFeedCategory_key;
    
    NSString * selectedSearchSortBy_key;
    
    
}
-(void) populatePickerArrays;
-(void)prepareSearchQueryString;
-(void) prepareFeedId;
-(NSString *) giveFeedIdForStartIndex:(int)start;
-(void) launchYoutubeAPIVideoFeedQuery:(NSString *)queryFeedID;
-(void) launchYoutubeAPIVideoSearchQuery;
-(void) displayChannelsHeader;
-(void) downloadPendingImages;

//-(void) videoFeedActive;
//-(void) videoFeedComplete;
-(void) videoFeedActive;
-(void) videoFeedComplete;
-(void) videoFeedCompleteTimedOut;
-(void) refreshVideoResults;
- (void)pickerTap;
-(void) showHideAddFeedButton;
-(void) pickRandomRowforPicker:(UIPickerView *)picker forComponent:(int)compNum;
-(void) playSound : (NSString *) fName : (NSString *) ext;
//-(NSString *) giveFriendlyDate:(NSDate *)uploadDate;

@end

@implementation EZFeedSearchViewController

@synthesize ls;
@synthesize currentFeedStartEndLbl;

@synthesize start_index;
@synthesize max_results;

@synthesize feedCategoryButton;
@synthesize orLbl;
@synthesize keywordSearchLbl;
@synthesize sortedByLbl;
@synthesize countryIconImageView;
@synthesize categoryIconImageView;
@synthesize feedCountryButton;
@synthesize feedPeriodButton;
@synthesize feedTypeButton;

SystemSoundID audioEffect;

@synthesize managedObjectContext = __managedObjectContext;

@synthesize pickerArraySearchType;
@synthesize pickerArraySearchPeriod;
@synthesize pickerArraySearchRegion;
@synthesize pickerArraySearchRegionFlags;
@synthesize pickerArraySearchChanneltype;
@synthesize pickerArraySearchChanneltypeIcons;
@synthesize pickerArraySortBy;

@synthesize pickerArraySearchType_keys;
@synthesize pickerArraySearchPeriod_keys;
@synthesize pickerArraySearchRegion_keys;
@synthesize pickerArraySearchChanneltype_keys;
@synthesize pickerArraySortBy_keys;



@synthesize pickerViewFeed;
@synthesize pickerViewSort;

@synthesize keywordField;
@synthesize findVideosButton;



@synthesize currentYoutubeAPISearchType;

@synthesize videoFeedDownloadQueue;
@synthesize spinButton;
@synthesize searchButtonTop;
@synthesize prevButton;
@synthesize nextButton;


@synthesize videoFeedId;
@synthesize videoFindType;
@synthesize videoSearchQueryString;

@synthesize videoSearchSortString;
@synthesize videoSearchSortStringDisplay;

@synthesize selectedFeedType;
@synthesize selectedFeedPeriod;
@synthesize selectedFeedRegion;
@synthesize selectedFeedCategory;
@synthesize selectedSearchSortBy;

@synthesize currentFeedUniqueEZId;
@synthesize currentFeedRecommendedDisplayName;

@synthesize delegate;
@synthesize videoViewController;
@synthesize feedVideoResultsArray;
@synthesize videosScrollView;
@synthesize currentFeedLbl;
@synthesize feedActivityIndicator;
@synthesize addVideoFeedButton;
@synthesize feedAddStatusLbl;

UIPopoverController * popOver;


//int max_results_1 = 30;
//int start_index_1 = 1;


NSMutableArray * videoResultsArray ;
//NSMutableArray * videoResultsArray ;

GDataServiceGoogleYouTube *youTubeService;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  
    [super viewDidLoad];
    
     ls = [LocalizationSystem sharedLocalSystem];
    
    videoEnteredFullScreen1 = NO;
    feedVideoResultsArray = [[NSMutableArray alloc]init];
    //ReSize Picker
    pickerViewFeed.frame = CGRectMake(0.0, 0.0, 690.0, 162.0);
    pickerViewSort.frame = CGRectMake(875.0, 0.0, 189, 162.0);
    
    // Do any additional setup after loading the view from its nib.
    currentYoutubeAPISearchType = @"NONE";
    
    [self populatePickerArrays];
    
    videoResultsArray = [[NSMutableArray alloc]init];
    youTubeService = [[TSDownloadManager sharedInstance] youTubeService];
    
    dispatch_queue_t videoDownloadQueue = dispatch_queue_create("com.eztube.testVideoFeed", NULL);
    self.videoFeedDownloadQueue = videoDownloadQueue;
    
    //Set background image
    UIImage * scrollBGImg = [UIImage imageNamed:@"backgroundvideofeed.png"];
    self.videosScrollView.backgroundColor = [UIColor colorWithPatternImage:scrollBGImg];
    
    //Set start_index, max_results
    self.start_index = 1;
    self.max_results = 50;
    
  
    //[self loadLanguageUI];
    [self setVCtoCurrentLanguage];
    
    //Default Search Sort to Publish date
    [pickerViewSort selectRow:1 inComponent:0 animated:YES];
    [pickerViewSort reloadComponent:0];
    
    pickerViewFeed.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                action:@selector(pickerTap)];
    [pickerViewFeed addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    //[pickerViewFeed setBackgroundColor:[UIColor blackColor]];
    
    
    //Load Default Feeds if none
    //[self loadDefaultFeedsForCountryLocale];
        
}



- (void)pickerTap {
    //NSLog(@"Picker tapped"); 
      keywordField.text = @"";
}


- (void)viewDidUnload
{
   
    [self setPickerViewFeed:nil];
 
    [self setKeywordField:nil];
 
    [self setFindVideosButton:nil];

    
    [self setVideosScrollView:nil];
    [self setCurrentFeedLbl:nil];
    [self setFeedActivityIndicator:nil];
    [self setAddVideoFeedButton:nil];
    [self setFeedAddStatusLbl:nil];
   
    [self setPickerViewSort:nil];
    [self setFeedTypeButton:nil];
    [self setFeedPeriodButton:nil];
    [self setFeedCountryButton:nil];
    [self setFeedCategoryButton:nil];
    [self setCurrentFeedStartEndLbl:nil];
    [self setSpinButton:nil];
    [self setSearchButtonTop:nil];
    [self setPrevButton:nil];
    [self setNextButton:nil];
    [self setOrLbl:nil];
    [self setKeywordSearchLbl:nil];
    [self setSortedByLbl:nil];
    [self setCountryIconImageView:nil];
    [self setCategoryIconImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    //Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(youtubeFullScreenEnteredUIMoviePlayer:)
                                                 name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(youtubeFullScreenExitedUIMoviePlayer:)
                                                 name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    //[self loadChannelVideosView];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    //Remove Observer
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
    
}

-(void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"ViewDidAppear:feed search view");
    [self downloadPendingImages];
    
    if(feedVideoResultsArray.count < 1)
    {
        [self searchVideos:nil];
    }
}

-(void) downloadPendingImages
{
    
    //Loop through all subviews of VideosScrollView
    if (self.view.window)
    {
        for(NSObject * subView in self.videosScrollView.subviews)
        {
            if([subView respondsToSelector:@selector(loadImageView)])
            {
                EZFeedSearchVideoCellView * videoCell = (EZFeedSearchVideoCellView *)subView;
                [videoCell loadImageView];
            }
        }
    }
    //else
    //{
        //NSLog(@"Not checking pending images");
    //}
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	//return YES;
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Handle keyboard return

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(![textField.text isEqualToString:@""])
    {
        [self searchVideos:nil];
        return YES;
        
    }
    else 
    {
        return NO;
    }
}

#pragma mark - showHideAddChannelButton

-(void) showHideAddFeedButton
{
    
    if(currentFeedUniqueEZId)
    {
    
            BOOL isChannelAdded = NO;
            
            isChannelAdded = [Feed doesFeedExistForSite:@"youtube" feedUniqueId:currentFeedUniqueEZId inManagedObjectContext:self.managedObjectContext];
            
            if(isChannelAdded)
            {
                [addVideoFeedButton setHidden:YES];
                [feedAddStatusLbl setHidden:NO];
            }
            else
            {
                [addVideoFeedButton setHidden:NO];
                [feedAddStatusLbl setHidden:YES];
                
            }
    }
    else
    {
        
        [addVideoFeedButton setHidden:YES];
        [feedAddStatusLbl setHidden:YES];
        
    }
    
}


-(void) loadDefaultFeedsForCountryLocale
{
    int currentFeedsCount = [Feed nextDisplayOrderNumberInManagedObjectContext:self.managedObjectContext];
    //currentFeedsCount = 1;
    

        //Use locale and find country
        
        NSLocale *locale = [NSLocale currentLocale];
        NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
        countryCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentAppCountry"];
    
    
        
        //NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
        
        //NSString *country = [usLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
        
        //NSLog(@"Country Code: %@, Country: %@", countryCode, country);
        
        int countryPickerIndex = [self.pickerArraySearchRegion indexOfObject:countryCode];
        //NSLog(@"Country exists in picker:%d",countryPickerIndex);
    
    
        
        [pickerViewFeed selectRow:countryPickerIndex inComponent:2 animated:YES];
        [pickerViewFeed reloadComponent:2];
        [feedCountryButton setSelected:YES];
        
        [pickerViewFeed selectRow:1 inComponent:0 animated:YES];
        [pickerViewFeed reloadComponent:0];
        
        
        [pickerViewFeed selectRow:0 inComponent:1 animated:YES];
        [pickerViewFeed reloadComponent:1];
        [feedPeriodButton setSelected:YES];
    
    if(currentFeedsCount == 1)
    {
        //populate Feeds
        
        
       // self.pickerArraySearchChanneltype_keys = [[NSArray alloc] initWithObjects:@"All Categories",@"Film",@"Autos",@"Music",@"Animals",@"Sports",@"Travel",@"Games",@"Comedy",@"People",@"News",@"Entertainment",@"Education",@"How to",@"Non profit",@"Technology", nil];
        
        if(countryPickerIndex > 0)
        {
            
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"ALL"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"ALL"];
            
 
          
            //Trending Film
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Film"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Film"];
            

            
            //Trending News
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Tech"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Tech"];
            
         
            
            
            //Trending Technology
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Entertainment"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Entertainment"];
            

            
            //Trending Entertainment
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"News"];
            
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"News"];
            
           
            
            //Trending Sports
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Sports"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Sports"];
            
            

     
            //Trending Music
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Music"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Music"];
            
            
         
            //Trending Comedy
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Comedy"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Comedy"];
            
          
 
            //Trending Sports
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"People"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"People"];
            
           
            
            //Trending Film
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Autos"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Autos"];
            
            
  
            
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"ALL"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:countryCode feedCategory:@"ALL"];

            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Film"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:countryCode feedCategory:@"Film"];
            
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Tech"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:countryCode feedCategory:@"Tech"];
            
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Entertainment"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:countryCode feedCategory:@"Entertainment"];
            
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"News"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:countryCode feedCategory:@"News"];
            
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Sports"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:countryCode feedCategory:@"Sports"];
            
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Music"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:countryCode feedCategory:@"Music"];
            
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Comedy"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:countryCode feedCategory:@"Comedy"];
            
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"People"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:countryCode feedCategory:@"People"];
            
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:countryCode feedCategory:@"Autos"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:countryCode feedCategory:@"Autos"];
            
            //-----ALL COUNTRIES
            

            
            //---------most viewed this week for ALL Countries
            //Most Viewed ALL for country
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"ALL"];
            
            //Most Viewed Film
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Film"];
            
            //Most Viewed News
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"News"];
            
            
            //Most Viewed Technology
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Tech"];
            
            //Most Viewed Entertainment
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Entertainment"];
            
            //Most Viewed Sports
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Sports"];
            
            
            //Most Viewed Music
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Music"];
            
            //Most Viewed Comedy
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Comedy"];
            
            //Most Viewed Sports
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"People"];
            
            //Most Viewed Film
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Autos"];
            
            

            

 
            
        }
        
        else 
        {
            
            /////  Populate Feeds for All Countries
            
            //-----ALL COUNTRIES
            
            //Trending ALL for ALL Countries
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"ALL"];
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"ALL"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"ALL"];
            
            
            //Trending Film
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Film"];
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Film"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Film"];
            
            
            //Trending Technology
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Tech"];
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Tech"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Tech"];

            
            //Trending Entertainment
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Entertainment"];
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Entertainment"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Entertainment"];
            
            //Trending News
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"News"];
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"News"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"News"];

            
            //Trending Sports
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Sports"];
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Sports"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Sports"];

            
            
            //Trending Music
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Music"];
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Music"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Music"];
      
            
            //Trending Comedy
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Comedy"];
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Comedy"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Comedy"];
            
            
            //Trending Sports
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"People"];
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"People"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"People"];
        
            
            //Trending Film
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Autos"];
            [self createFeedForFeedId:@"on_the_web" feedPeriod:@"today" feedRegion:@"ALL" feedCategory:@"Autos"];
            [self createFeedForFeedId:@"most_viewed" feedPeriod:@"this_week" feedRegion:@"ALL" feedCategory:@"Autos"];

            
  
        }
        
        [self.delegate informAboutNewFeeds];
        
        //NSLog(@"Created new Feeds");
    }

    
   
    
    //FEEDS
    //populate country feeds, Channels
    
    ////Trending Entertainment,Technology, Music, 
    ////Most Viewed today  News, Film,  Sports, Comedy
    
    //Set Country and Lock Country
    
    
}


-(void) createFeedForFeedId:(NSString *)feedId 
                 feedPeriod:(NSString *)feedPeriod 
                 feedRegion:(NSString *)feedRegion 
               feedCategory:(NSString *)feedCategory
{
    
    NSString * feedRegionFixed;
    NSString * feedCategoryFixed;
    
    NSString * feedUniqueEZId;
    NSString * FeedRecommendedDisplayName = @"";
    NSString * feedFindType = @"FEED";
    NSString * feedURL;
    
    NSString * feedIdKey = [pickerArraySearchType_keys objectAtIndex:[pickerArraySearchType indexOfObject:feedId]];
    NSString * feedPeriodKey = [pickerArraySearchPeriod_keys objectAtIndex:[pickerArraySearchPeriod indexOfObject:feedPeriod]];;
    NSString * feedRegionKey = [pickerArraySearchRegion_keys objectAtIndex:[pickerArraySearchRegion indexOfObject:feedRegion]];;
    NSString * feedCategoryKey = [pickerArraySearchChanneltype_keys objectAtIndex:[pickerArraySearchChanneltype indexOfObject:feedCategory]];;
    
    
    //Set Country...blank if ALL
    if([feedRegion isEqualToString:@"ALL"])
    {
        feedRegionFixed = @"";
        
    }
    else
    {
        feedRegionFixed = [NSString stringWithFormat:@"%@/",feedRegion];
    }
    
    //Set Channel type...blank if ALL
    if([feedCategory isEqualToString:@"ALL"])
    {
        feedCategoryFixed = @"";
    }
    else
    {
        feedCategoryFixed = [NSString stringWithFormat:@"_%@",feedCategory];
    }
    
    BOOL NoTimeParam = NO;
    //Blank out period for most_shared, recently_featured, most_recent, on_the_web
    if([feedId isEqualToString:@"most_shared"] || [feedId isEqualToString:@"recently_featured"] || [feedId isEqualToString:@"most_recent"] || [feedId isEqualToString:@"on_the_web"])
    {
        NoTimeParam = YES;
    }
    
    
    if(NoTimeParam)
    {
        feedURL = [NSString stringWithFormat:@"%@%@%@?",feedRegionFixed,feedId,feedCategoryFixed];
        selectedFeedPeriodDisplay = @"";
    }
    else
    {
        feedURL = [NSString stringWithFormat:@"%@%@%@?&time=%@",feedRegionFixed,feedId,feedCategoryFixed,feedPeriod];
    }
    
     feedUniqueEZId = [NSString stringWithFormat:@"VIDEOFEED-%@-%@-%@-%@-",feedId,feedPeriod,feedRegionFixed,feedCategoryFixed];
    
    NSMutableDictionary * videoFeedSource = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                             @"youtube", @"sourceSite",
                                             feedUniqueEZId, @"feedUniqueId",
                                             FeedRecommendedDisplayName, @"displayName",   
                                             feedFindType, @"feed_OR_search",
                                             feedURL, @"feedURL",
                                             feedIdKey, @"feedId",
                                             feedCategoryKey, @"feedCategory",
                                             feedPeriodKey, @"feedPeriod",
                                             feedRegionKey, @"feedRegion",
                                             nil];               
    
    [self.delegate addNewVideoFeedRecord:[videoFeedSource autorelease] informAboutFeeds:NO];
    
    
}




#pragma mark - setCurrent Language to UI
-(void) setVCtoCurrentLanguage
{
    //LocalizationSetLanguage(@"ja");
    //LocalizationLoadCurrentLanguage;
    
     

    
   // NSLog(@"Most Viewed: %@", ls.eZ_MOST_VIEWED);
    
    pickerArraySearchTypeDisplay= [[NSArray alloc] initWithObjects: ls.eZ_MOST_VIEWED,ls.eZ_TRENDING,ls.eZ_MOST_POPULAR,ls.eZ_MOST_SHARED,ls.eZ_MOST_DISCUSSED,ls.eZ_MOST_RESPONDED,ls.eZ_RECENTLY_FEATURED,ls.eZ_TOP_RATED,ls.eZ_TOP_FAVORITES, nil];
    
    pickerArraySearchPeriodDisplay = [[NSArray alloc] initWithObjects: ls.eZ_TODAY,ls.eZ_THIS_WEEK,ls.eZ_THIS_MONTH,ls.eZ_ALL_TIME, nil];
    
    pickerArraySearchRegionDisplay = [[NSArray alloc] initWithObjects: ls.eZ_ALL_COUNTRIES,ls.eZ_ARGENTINA,ls.eZ_AUSTRALIA,ls.eZ_BRAZIL,ls.eZ_CANADA,ls.eZ_CZECH,ls.eZ_FRANCE,ls.eZ_GERMANY,ls.eZ_BRITAIN,ls.eZ_HONGKONG,ls.eZ_INDIA,ls.eZ_IRELAND,ls.eZ_ISRAEL,ls.eZ_ITALY,ls.eZ_JAPAN,ls.eZ_MEXICO,ls.eZ_NETHERLANDS,ls.eZ_NEWZEALAND,ls.eZ_POLAND,ls.eZ_RUSSIA,ls.eZ_SOUTHAFRICA,ls.eZ_SOUTHKOREA,ls.eZ_SPAIN,ls.eZ_SWEDEN,ls.eZ_TAIWAN,ls.eZ_UNITEDSTATES, nil];
    
    pickerArraySearchChanneltypeDisplay = [[NSArray alloc] initWithObjects:ls.eZ_ALL_CATEGORIES,ls.eZ_FILM,ls.eZ_NEWS,ls.eZ_TECHNOLOGY,ls.eZ_ENTERTAINMENT,ls.eZ_SPORTS,ls.eZ_MUSIC,ls.eZ_COMEDY,ls.eZ_PEOPLE,ls.eZ_AUTOS,ls.eZ_ANIMALS,ls.eZ_TRAVEL,ls.eZ_GAMES,ls.eZ_EDUCATION,ls.eZ_HOW_TO,ls.eZ_NON_PROFIT, nil];
    
    pickerArraySearchSortByDisplay = [[NSArray alloc] initWithObjects: ls.eZ_RELEVANCE,ls.eZ_PUBLISH_DATE,ls.eZ_VIEW_COUNT,ls.eZ_RATING, nil];
    
    [pickerViewFeed reloadAllComponents];
    [pickerViewSort reloadAllComponents];
    
    
    orLbl.text  = ls.eZ_OR;
    keywordSearchLbl.text = ls.eZ_KEYWORD_SEARCH;
    sortedByLbl.text = ls.eZ_SORTED_BY;
    keywordField.placeholder = ls.eZ_KEY_WORD;
    feedAddStatusLbl.text = ls.eZ_ADDED_TO_EZFEEDS;
    
    //Load localized images
    
        //Spin button
        UIImage *spin_blue_highlighted_img = [[UIImage alloc] initWithContentsOfFile:ls.spin_blue_highlighted_path];
        if(!spin_blue_highlighted_img)
        {
            spin_blue_highlighted_img = [[UIImage alloc] initWithContentsOfFile:ls.spin_blue_highlighted_mainBundle_path];
        }
    
        UIImage *spin_blue_default_img = [[UIImage alloc] initWithContentsOfFile:ls.spin_blue_default_path];
        if(!spin_blue_default_img)
        {
            spin_blue_default_img = [[UIImage alloc] initWithContentsOfFile:ls.spin_blue_default_mainBundle_path];
        }

        [spinButton setImage:spin_blue_default_img forState:UIControlStateNormal];
        [spinButton setImage:spin_blue_highlighted_img forState:UIControlStateHighlighted];
        [spin_blue_default_img release];
        [spin_blue_highlighted_img release];
        
        //Search button
    
        UIImage *searchbutton_img = [[UIImage alloc] initWithContentsOfFile:ls.searchbutton_path];
        if(!searchbutton_img)
        {
            searchbutton_img = [[UIImage alloc] initWithContentsOfFile:ls.searchbutton_mainBundle_path];
        }
        [searchButtonTop setImage:searchbutton_img forState:UIControlStateNormal];
        [findVideosButton setImage:searchbutton_img forState:UIControlStateNormal];
        [searchbutton_img release];
    
        
        //add to Feeds button
    
        UIImage *add_to_ez_feeds_img = [[UIImage alloc] initWithContentsOfFile:ls.add_to_ez_feeds_path];
        if(!add_to_ez_feeds_img)
        {
            add_to_ez_feeds_img = [[UIImage alloc] initWithContentsOfFile:ls.add_to_ez_feeds_mainBundle_path];
        }
        [addVideoFeedButton setImage:add_to_ez_feeds_img forState:UIControlStateNormal];
        [add_to_ez_feeds_img release];
        //clear search text
        self.currentFeedLbl.text = @"";
    
        //[self searchVideos:nil];
    
        
   // NSLog(@"Current Language: %@",AMLocalizedString(@"Most viewed", nil));
   // NSLog(@"Current Language: %@",ls.eZ_MOST_VIEWED);
    
    
    
}



#pragma mark - populate pickerArrays

-(void) populatePickerArrays
{
    NSArray *arrayToLoadPickerTypes = [[NSArray alloc] initWithObjects: @"most_viewed",@"on_the_web",@"most_popular",@"most_shared",@"most_discussed",@"most_responded",@"recently_featured",@"top_rated",@"top_favorites",nil];
    
    self.pickerArraySearchType = arrayToLoadPickerTypes;
    [arrayToLoadPickerTypes release];
    
    self.pickerArraySearchType_keys = [[NSArray alloc] initWithObjects: @"Most viewed",@"Trending",@"Most popular",@"Most shared",@"Most discussed",@"Most responded",@"Recently featured",@"Top rated",@"Top favorites", nil]; 
    
    /*
     pickerArraySearchTypeDisplay= [[NSArray alloc] initWithObjects: AMLocalizedString(@"Most viewed", nil),EZ_TRENDING,EZ_MOST_POPULAR,EZ_MOST_SHARED,EZ_MOST_DISCUSSED,EZ_MOST_RESPONDED,EZ_RECENTLY_FEATURED,EZ_TOP_RATED,EZ_TOP_FAVORITES, nil];
     */
    
    

    
    NSArray *arrayToLoadPickerPeriod = [[NSArray alloc] initWithObjects: @"today",@"this_week",@"this_month",@"all_time", nil];
    
    self.pickerArraySearchPeriod = arrayToLoadPickerPeriod;
    [arrayToLoadPickerPeriod release];
    
    self.pickerArraySearchPeriod_keys = [[NSArray alloc] initWithObjects: @"today",@"this week",@"this month",@"all time", nil];
    
    //pickerArraySearchPeriodDisplay = [[NSArray alloc] initWithObjects: EZ_TODAY,EZ_THIS_WEEK,EZ_THIS_MONTH,EZ_ALL_TIME, nil];
    
    

    
    //NOTE: For most_subscribed cahnnels, "today" does not work.
    
    
    NSArray *arrayToLoadPickerRegion = [[NSArray alloc] initWithObjects: @"ALL",@"AR",@"AU",@"BR",@"CA",@"CZ",@"FR",@"DE",@"GB",@"HK",@"IN",@"IE",@"IL",@"IT",@"JP",@"MX",@"NL",@"NZ",@"PL",@"RU",@"ZA",@"KR",@"ES",@"SE",@"TW",@"US", nil];
    
    self.pickerArraySearchRegion = arrayToLoadPickerRegion;
    [arrayToLoadPickerRegion release];
    
    
    self.pickerArraySearchRegion_keys = [[NSArray alloc] initWithObjects: @"All Countries",@"Argentina",@"Australia",@"Brazil",@"Canada",@"Czech Republic",@"France",@"Germany",@"Great Britain",@"Hong Kong",@"India",@"Ireland",@"Israel",@"Italy",@"Japan",@"Mexico",@"Netherlands",@"New Zealand",@"Poland",@"Russia",@"South Africa",@"South Korea",@"Spain",@"Sweden",@"Taiwan",@"United States", nil]; 
    
     /*
    pickerArraySearchRegionDisplay = [[NSArray alloc] initWithObjects: EZ_ALL_COUNTRIES,EZ_ARGENTINA,EZ_AUSTRALIA,EZ_BRAZIL,EZ_CANADA,EZ_CZECH,EZ_FRANCE,EZ_GERMANY,EZ_BRITAIN,EZ_HONGKONG,EZ_INDIA,EZ_IRELAND,EZ_ISRAEL,EZ_ITALY,EZ_JAPAN,EZ_MEXICO,EZ_NETHERLANDS,EZ_NEWZEALAND,EZ_POLAND,EZ_RUSSIA,EZ_SOUTHAFRICA,EZ_SOUTHKOREA,EZ_SPAIN,EZ_SWEDEN,EZ_TAIWAN,EZ_UNITEDSTATES, nil];
     */
    
       
    
    
    pickerArraySearchRegionFlags = [[NSArray alloc] initWithObjects:
                                                                      [UIImage imageNamed:@"globe.png"],
                                                                      [UIImage imageNamed:@"argentina.png"],
                                                                      [UIImage imageNamed:@"australia.png"],
                                                                      [UIImage imageNamed:@"brazil.png"],
                                                                      [UIImage imageNamed:@"canada.png"],
                                                                      [UIImage imageNamed:@"czech.png"],
                                                                      [UIImage imageNamed:@"france.png"],
                                                                      [UIImage imageNamed:@"germany.png"],
                                                                      [UIImage imageNamed:@"britain.png"],
                                                                      [UIImage imageNamed:@"hongkong.png"],
                                                                      [UIImage imageNamed:@"india.png"],
                                                                      [UIImage imageNamed:@"ireland.png"],
                                                                      [UIImage imageNamed:@"israel.png"],
                                                                      [UIImage imageNamed:@"italy.png"],
                                                                      [UIImage imageNamed:@"japan.png"],
                                                                      [UIImage imageNamed:@"mexico.png"],
                                                                      [UIImage imageNamed:@"holland.png"],
                                                                      [UIImage imageNamed:@"newzealand.png"],
                                                                      [UIImage imageNamed:@"poland.png"],
                                                                      [UIImage imageNamed:@"russia.png"],
                                                                      [UIImage imageNamed:@"southafrica.png"],
                                                                      [UIImage imageNamed:@"southkorea.png"],
                                                                      [UIImage imageNamed:@"spain.png"],
                                                                      [UIImage imageNamed:@"sweden.png"],
                                                                      [UIImage imageNamed:@"taiwan.png"],
                                                                      [UIImage imageNamed:@"usa.png"], 
                                                                      nil];
    
    

    
    NSArray *arrayToLoadPickerChannelType = [[NSArray alloc] initWithObjects: @"ALL",@"Film",@"News",@"Tech",@"Entertainment",@"Sports",@"Music",@"Comedy",@"People",@"Autos",@"Animals",@"Travel",@"Games",@"Education",@"Howto",@"Nonprofit", nil];
    
     self.pickerArraySearchChanneltype = arrayToLoadPickerChannelType;
    [arrayToLoadPickerChannelType release];
    
    self.pickerArraySearchChanneltype_keys = [[NSArray alloc] initWithObjects:@"All Categories",@"Film",@"News",@"Technology",@"Entertainment",@"Sports",@"Music",@"Comedy",@"People",@"Autos",@"Animals",@"Travel",@"Games",@"Education",@"How to",@"Non profit", nil];
    
    /*
     pickerArraySearchChanneltypeDisplay = [[NSArray alloc] initWithObjects:EZ_ALL_CATEGORIES,EZ_FILM,EZ_AUTOS,EZ_MUSIC,EZ_ANIMALS,EZ_SPORTS,EZ_TRAVEL,EZ_GAMES,EZ_COMEDY,EZ_PEOPLE,EZ_NEWS,EZ_ENTERTAINMENT,EZ_EDUCATION,EZ_HOW_TO,EZ_NON_PROFIT,EZ_TECHNOLOGY, nil];
     
    */
    
    pickerArraySearchChanneltypeIcons = [[NSArray alloc] initWithObjects: 
                                    [UIImage imageNamed:@"all.png"],     
                                    [UIImage imageNamed:@"film.png"],
                                    [UIImage imageNamed:@"news.png"],
                                    [UIImage imageNamed:@"technology.png"],
                                    [UIImage imageNamed:@"entertainment.png"],
                                    [UIImage imageNamed:@"sports.png"],
                                    [UIImage imageNamed:@"music.png"],
                                    [UIImage imageNamed:@"comedy.png"],
                                    [UIImage imageNamed:@"people.png"],
                                    [UIImage imageNamed:@"autos.png"],
                                    [UIImage imageNamed:@"animals.png"],
                                    [UIImage imageNamed:@"travel.png"],
                                    [UIImage imageNamed:@"games.png"],
                                    [UIImage imageNamed:@"education.png"],
                                    [UIImage imageNamed:@"howto.png"],
                                    [UIImage imageNamed:@"nonprofit.png"],
                                    nil];
    
    
   
    
    
    NSArray *arrayToLoadPickerSortBy = [[NSArray alloc] initWithObjects: @"relevance",@"published",@"viewCount",@"rating", nil];
    
    self.pickerArraySortBy = arrayToLoadPickerSortBy;
    [arrayToLoadPickerSortBy release];
    
    self.pickerArraySortBy_keys = [[NSArray alloc] initWithObjects: @"Relevance",@"Publish date",@"View count",@"Rating", nil];
    
    //pickerArraySearchSortByDisplay = [[NSArray alloc] initWithObjects: EZ_RELEVANCE,EZ_PUBLISH_DATE,EZ_VIEW_COUNT,EZ_RATING, nil];
   
   
    
    
}




#pragma mark - Picker View Datasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if([pickerView isEqual:pickerViewFeed])
    return 4;
    else 
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
     if([pickerView isEqual:pickerViewFeed])
     {
            switch (component) {
                case 0:
                    return 190;
                case 1:
                    return 130;
                case 2:
                    return 170;
                case 3:
                    return 170;
                    
                default:
                    return 50;;
            }
     }
    else
    {
        return 144;
    }
}


-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([pickerView isEqual:pickerViewFeed])
    {
        int count = 0;
        
        switch (component) {
            case 0:
                count = self.pickerArraySearchType.count;
                break;
            case 1:
                count = self.pickerArraySearchPeriod.count;
                break;
            case 2:
                count = self.pickerArraySearchRegion.count;
                break;
            case 3:
                count = self.pickerArraySearchChanneltype.count;
                break;
                
            default:
                break;
        }
        return count;
    }
    else
    {
        return 4;
    }
    
    
    
    
}

/*

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString * title = @"";
    
    if([pickerView isEqual:pickerViewFeed])
    {
            
        switch (component) {
            case 0:
                title = [pickerArraySearchTypeDisplay objectAtIndex:row];
                break;
            case 1:
                title = [pickerArraySearchPeriodDisplay objectAtIndex:row];
                break;
            case 2:
                //title = [pickerArraySearchRegionDisplay objectAtIndex:row];
                break;
            case 3:
                title = [pickerArraySearchChanneltypeDisplay objectAtIndex:row];
                break;
                
            default:
                break;
        }
    }
    else
    {
        title = [pickerArraySearchSortByDisplay objectAtIndex:row];
    }
    return title;

}


*/




- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    NSString * title = @"";
    UILabel *channelLabel;
    UIView *tmpView;
    UIImageView *temp;
    
    if([pickerView isEqual:pickerViewFeed])
    {
        
        switch (component) {
            case 0:
                title = [pickerArraySearchTypeDisplay objectAtIndex:row];
                channelLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 5, 180, 30)];
                channelLabel.text = title;
                channelLabel.textAlignment = UITextAlignmentLeft;
                channelLabel.backgroundColor = [UIColor clearColor];
                channelLabel.textColor = [UIColor whiteColor];
                
                UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 190, 40)];
                [tmpView setBackgroundColor:[UIColor blackColor]];
                [tmpView insertSubview:channelLabel atIndex:1];
                return tmpView;
                break;
                break;
                
                
            case 1:
                title = [pickerArraySearchPeriodDisplay objectAtIndex:row];
                UILabel *channelLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 5, 120, 30)];
                channelLabel.text = title;
                channelLabel.textAlignment = UITextAlignmentLeft;
                channelLabel.backgroundColor = [UIColor clearColor];
                channelLabel.textColor = [UIColor whiteColor];
                
                tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
                [tmpView setBackgroundColor:[UIColor blackColor]];
                [tmpView insertSubview:channelLabel atIndex:1];
                return tmpView;
                break;
                
            case 2:
                title = [pickerArraySearchRegionDisplay objectAtIndex:row];
                temp = [[UIImageView alloc] initWithImage:[pickerArraySearchRegionFlags objectAtIndex:row]];        
                temp.frame = CGRectMake(7, 5, 40, 30);
                
                
                channelLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 120, 30)];
                channelLabel.text = title;
                channelLabel.textAlignment = UITextAlignmentLeft;
                channelLabel.backgroundColor = [UIColor clearColor];
                channelLabel.textColor = [UIColor whiteColor];
                
                tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 40)];
                [tmpView setBackgroundColor:[UIColor blackColor]];
                [tmpView insertSubview:temp atIndex:0];
                [tmpView insertSubview:channelLabel atIndex:1];
                return tmpView;
                break;
                
                
            case 3:
                title = [pickerArraySearchChanneltypeDisplay objectAtIndex:row];
                temp = [[UIImageView alloc] initWithImage:[pickerArraySearchChanneltypeIcons objectAtIndex:row]];        
                temp.frame = CGRectMake(7, 5, 30, 30);
                
                channelLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 130, 30)];
                channelLabel.text = title;
                channelLabel.textAlignment = UITextAlignmentLeft;
                channelLabel.backgroundColor = [UIColor clearColor];
                channelLabel.textColor = [UIColor whiteColor];
                
                tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 40)];
                [tmpView setBackgroundColor:[UIColor blackColor]];
                [tmpView insertSubview:temp atIndex:0];
                [tmpView insertSubview:channelLabel atIndex:1];
                return tmpView;
                break;
                
            default:
                break;
        }
    }
    else
    {
        title = [pickerArraySearchSortByDisplay objectAtIndex:row];
        channelLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 139, 30)];
        channelLabel.text = title;
        channelLabel.textAlignment = UITextAlignmentLeft;
        channelLabel.backgroundColor = [UIColor clearColor];
        channelLabel.textColor = [UIColor whiteColor];
        
        tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 144, 40)];
        [tmpView setBackgroundColor:[UIColor blackColor]];
        [tmpView insertSubview:channelLabel atIndex:1];
        return tmpView;
    }
    
    
   return tmpView;
    
}


#pragma mark - Picker View Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if([pickerView isEqual:pickerViewFeed])
    {
        keywordField.text = @"";
    }
}

#pragma mark - Give FeedID For Start_Index

-(NSString *) giveFeedIdForStartIndex:(int)start
{
    //NSLog(@"Curent Feed:%@",self.videoFeedId);
    NSString * tempFeedID = [NSString stringWithFormat:@"%@&start-index=%d&max-results=%d&v=2",self.videoFeedId,start,self.max_results];
    
    return tempFeedID;
    
}

#pragma mark - prepare SearchQueryString

-(void)prepareSearchQueryString
{

    
    NSString *trimmed =
    [keywordField.text stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableString *qString = [NSMutableString stringWithString:@""];
    
    for (NSString * keyword in [trimmed componentsSeparatedByString: @" "])
    {
        if(qString.length >0)
        {[qString appendString:@"+"];}
        
        [qString appendString:[keyword stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
   
    videoSearchQueryString = qString;
    [videoSearchQueryString retain];
    //NSLog(@"video Search Query String:%@",videoSearchQueryString);
    
    videoSearchSortString = [pickerArraySortBy objectAtIndex:[pickerViewSort selectedRowInComponent:0]];
    selectedSearchSortBy_key = [pickerArraySortBy_keys objectAtIndex:[pickerViewSort selectedRowInComponent:0]];
    videoSearchSortStringDisplay = [pickerArraySearchSortByDisplay objectAtIndex:[pickerViewSort selectedRowInComponent:0]];
    
    self.currentFeedUniqueEZId = [NSString stringWithFormat:@"VIDEOSEARCH-%@-%@",videoSearchQueryString,videoSearchSortString];
    //NSLog(@"currentFeedUniqueEZId--1--:%@",self.currentFeedUniqueEZId);
}


#pragma mark - prepare FeedID

-(void)prepareFeedId
{
    //[videoSearchQueryString release];
    //videoSearchQueryString = NULL;
    
   
    //NSMutableString * feedID ;//= @"IN/most_viewed_Partners?&time=all_time&start-index=1&max-results=50&v=2";
    //https://gdata.youtube.com/feeds/api/standardfeeds/regionID/feedID_CATEGORY_NAME?v=2
     /*
    NSMutableString * countryCode = @"";
    NSMutableString * feedType = @"most_viewed";
    NSMutableString * videoType = @"";
    NSMutableString * period = @"";
     */
    //int self.max_results = 50;
    
    int selectedIndex = 0;
    
    selectedIndex = [pickerViewFeed selectedRowInComponent:0];
    selectedFeedType = [pickerArraySearchType objectAtIndex:selectedIndex];
    selectedFeedType_key = [pickerArraySearchType_keys objectAtIndex:selectedIndex];
    selectedFeedTypeDisplay = [pickerArraySearchTypeDisplay objectAtIndex:selectedIndex];
    
    
    selectedIndex = [pickerViewFeed selectedRowInComponent:1];
    selectedFeedPeriod = [pickerArraySearchPeriod objectAtIndex:selectedIndex];
    selectedFeedPeriod_key = [pickerArraySearchPeriod_keys objectAtIndex:selectedIndex];
    selectedFeedPeriodDisplay = [pickerArraySearchPeriodDisplay objectAtIndex:selectedIndex];
    
    selectedIndex = [pickerViewFeed selectedRowInComponent:2];
    NSString * selectedFeedRegionTemp = [pickerArraySearchRegion objectAtIndex:selectedIndex];
    selectedFeedRegion_key = [pickerArraySearchRegion_keys objectAtIndex:selectedIndex];
    selectedFeedRegionDisplay = [pickerArraySearchRegionDisplay objectAtIndex:selectedIndex];
    
    selectedIndex = [pickerViewFeed selectedRowInComponent:3];
    NSString * selectedFeedCategoryTemp = [pickerArraySearchChanneltype objectAtIndex:selectedIndex];
    selectedFeedCategory_key = [pickerArraySearchChanneltype_keys objectAtIndex:selectedIndex];
    selectedFeedCategoryDisplay = [pickerArraySearchChanneltypeDisplay objectAtIndex:selectedIndex];
    
    BOOL NoTimeParam = NO;
    //Blank out period for most_shared, recently_featured, most_recent, on_the_web
    if([selectedFeedType isEqualToString:@"most_shared"] || [selectedFeedType isEqualToString:@"recently_featured"] || [selectedFeedType isEqualToString:@"most_recent"] || [selectedFeedType isEqualToString:@"on_the_web"])
    {
        NoTimeParam = YES;
    }
    
    
    //Set Country...blank if ALL
    if([selectedFeedRegionTemp isEqualToString:@"ALL"])
    {
        self.selectedFeedRegion = @"";
        
    }
    else
    {
        self.selectedFeedRegion = [NSString stringWithFormat:@"%@/",selectedFeedRegionTemp];
    }
    
    //Set Channel type...blank if ALL
    if([selectedFeedCategoryTemp isEqualToString:@"ALL"])
    {
        self.selectedFeedCategory = @"";
    }
    else
    {
        self.selectedFeedCategory = [NSString stringWithFormat:@"_%@",selectedFeedCategoryTemp];
    }
    
    /*
    feedID = [NSMutableString stringWithFormat:@"%@%@%@?&time=%@&start-index=%d&max-results=%d&v=2",selectedFeedRegion,selectedFeedType,selectedFeedCategory,selectedFeedPeriod,self.start_index,self.max_results];
    */
    if(NoTimeParam)
    {
        self.videoFeedId = [NSString stringWithFormat:@"%@%@%@?",selectedFeedRegion,selectedFeedType,selectedFeedCategory];
        selectedFeedPeriodDisplay = @"";
    }
    else
    {
        self.videoFeedId = [NSString stringWithFormat:@"%@%@%@?&time=%@",selectedFeedRegion,selectedFeedType,selectedFeedCategory,selectedFeedPeriod];
    }
    
    [self.videoFeedId retain];
    
    self.currentFeedUniqueEZId = [NSString stringWithFormat:@"VIDEOFEED-%@-%@-%@-%@-",selectedFeedType,selectedFeedPeriod,selectedFeedRegion,selectedFeedCategory];
   
//NSLog(@"currentFeedUniqueEZId--1--:%@",self.currentFeedUniqueEZId);
    
}

#pragma mark - User Actions 



- (IBAction)feedTypeButtonPressed:(id)sender {
    
    if(self.feedTypeButton.selected)
    {
        [self.feedTypeButton setSelected:NO];
    }
    else
    {
        [self.feedTypeButton setSelected:YES];
    }
}

- (IBAction)feedPeriodButtonPressed:(id)sender {
    
    if(self.feedPeriodButton.selected)
    {
        [self.feedPeriodButton setSelected:NO];
    }
    else
    {
        [self.feedPeriodButton setSelected:YES];
    }
}

- (IBAction)feedCountryButtonPressed:(id)sender {
    
    if(self.feedCountryButton.selected)
    {
        [self.feedCountryButton setSelected:NO];
    }
    else
    {
        [self.feedCountryButton setSelected:YES];
    }
}

- (IBAction)feedCategoryButtonPressed:(id)sender {
    
    if(self.feedCategoryButton.selected)
    {
        [self.feedCategoryButton setSelected:NO];
    }
    else
    {
        [self.feedCategoryButton setSelected:YES];
    }
}

- (IBAction)showNext:(id)sender {
    
    [self videoFeedActive];
    
    if(start_index < (600 - max_results))
        start_index = start_index+max_results;
    
    NSString * queryFeedID = [self giveFeedIdForStartIndex:start_index];
    
    if([videoFindType isEqualToString:@"FEED"])
    {
        [self launchYoutubeAPIVideoFeedQuery:queryFeedID];
    }
    else
    {
        [self launchYoutubeAPIVideoSearchQuery];
    }
    
}

- (IBAction)showPrevious:(id)sender {
    
    [self videoFeedActive];
    
    if(start_index > max_results)
        start_index = start_index-max_results;
    
    NSString * queryFeedID = [self giveFeedIdForStartIndex:start_index];
    
    if([videoFindType isEqualToString:@"FEED"])
    {
        [self launchYoutubeAPIVideoFeedQuery:queryFeedID];
    }
    else
    {
        [self launchYoutubeAPIVideoSearchQuery];
    }
    
    
}










- (IBAction)searchVideos:(id)sender {
    
   [self.keywordField resignFirstResponder];
    

    
    
    
    [self videoFeedActive];
    
    //Reset Start_Index
    self.start_index = 1;

    if([keywordField.text isEqualToString:@""] )
    {
        [self prepareFeedId];
       
        //self.currentFeedRecommendedDisplayName = [NSString stringWithFormat:@"%@ videos %@, in %@, among %@",selectedFeedTypeDisplay,selectedFeedPeriodDisplay,selectedFeedRegionDisplay,selectedFeedCategoryDisplay];
        
        NSString * catDisplay ;
        NSString * periodDisplay ;
        NSString * regionDisplay;
        
        
        if(![selectedFeedPeriodDisplay isEqualToString:@""])
        {
            periodDisplay = [NSString stringWithFormat:@", %@",selectedFeedPeriodDisplay];
        }
        else
        {
            periodDisplay = @"";   
        }
        
        
        if(![selectedFeedCategory isEqualToString:@""])
        {
            catDisplay = [NSString stringWithFormat:@" %@",selectedFeedCategoryDisplay];
        }
        else
        {
            catDisplay = @""; 
        }
        
        
        if(![selectedFeedRegion isEqualToString:@""])
        {
            regionDisplay = [NSString stringWithFormat:@" %@ %@",ls.eZ_IN,selectedFeedRegionDisplay];
        }
        else
        {
            regionDisplay = @""; 
        }
        
        
        
        self.currentFeedRecommendedDisplayName = [NSString stringWithFormat:@"%@%@ %@%@%@",selectedFeedTypeDisplay,catDisplay,ls.eZ_VIDEOS,regionDisplay,periodDisplay];
        
        currentFeedLbl.text = self.currentFeedRecommendedDisplayName;
        int selectedCountryIndex = [pickerViewFeed selectedRowInComponent:2];
        countryIconImageView.image = [pickerArraySearchRegionFlags objectAtIndex:selectedCountryIndex];
        int selectedCategoryIndex = [pickerViewFeed selectedRowInComponent:3];
        categoryIconImageView.image = [pickerArraySearchChanneltypeIcons objectAtIndex:selectedCategoryIndex];
        
        NSString * queryFeedID = [self giveFeedIdForStartIndex:self.start_index];
        [self launchYoutubeAPIVideoFeedQuery:queryFeedID];
        

        videoFindType = @"FEED";
    }
    else
    {
        [self prepareSearchQueryString];
            
        self.currentFeedRecommendedDisplayName = [NSString stringWithFormat:@"%@: %@  %@: %@",ls.eZ_SEARCH,videoSearchQueryString,ls.eZ_SORTED_BY,videoSearchSortStringDisplay];
        currentFeedLbl.text = self.currentFeedRecommendedDisplayName;
        
        //NSString *querySearchFeedId = @"";
        [self launchYoutubeAPIVideoSearchQuery];
        //keywordField.text = @"";
        videoFindType = @"SEARCH";
    }
     
    
}




#pragma mark - Launch Channel Feed Query

-(void) launchYoutubeAPIVideoFeedQuery:(NSString *)queryFeedID
{
    [self showHideAddFeedButton];
    
    [self clearCurrentFeed];
    
   self.currentFeedStartEndLbl.text = [NSString stringWithFormat:@"(%d-%d)",start_index,start_index+max_results-1];
    
    
    //https://gdata.youtube.com/feeds/api/standardfeeds/regionID/feedID_CATEGORY_NAME?v=2
    
    NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForFeedID:queryFeedID];
    //youTubeURLForChannelsFeeds
    //NSLog(@"Invoking Feed:%@", queryFeedID);
    
    GDataQueryYouTube * query = [GDataQueryYouTube  youTubeQueryWithFeedURL:feedURL];
    
    
    [youTubeService fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(request:finishedWithFeed:error:)];
    
    
}


#pragma mark - Launch Channel Search Query

-(void) launchYoutubeAPIVideoSearchQuery
{
    [self showHideAddFeedButton];
    
    [self clearCurrentFeed];
    
    self.currentFeedStartEndLbl.text = [NSString stringWithFormat:@"(%d-%d)",start_index,start_index+max_results-1];
    /*
    https://gdata.youtube.com/feeds/api/videos?
    q=football+-soccer
    &orderby=published
    &start-index=11
    &max-results=10
    &v=2
    */
    

    
    
    
    NSString * videoSearchString = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos?q=%@&orderby=%@&start-index=%d&max-results=%d&v=2",videoSearchQueryString,videoSearchSortString,self.start_index,self.max_results];
    
    //self.videoFeedId = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos?q=%@&orderby=%@&v=2",videoSearchQueryString];
    self.videoFeedId = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos?q=%@&orderby=%@&v=2",videoSearchQueryString,videoSearchSortString];
    
    [self.videoFeedId retain];
    
    
    NSURL *videoSearchURL = [NSURL URLWithString:videoSearchString];
    
    //youTubeURLForChannelsFeeds
    //NSLog(@"Invoking Search:%@", videoSearchString);
    
    GDataQueryYouTube * query = [GDataQueryYouTube  youTubeQueryWithFeedURL:videoSearchURL];
    
    
    [youTubeService fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(request:finishedWithFeed:error:)];
    
    
}

#pragma mark - setup Channels Header

-(void) displayChannelsHeader{
    

        
    
}



#pragma mark - Add Video Feed


- (IBAction)addVideoFeed:(id)sender {
    
    //NSLog(@"%@",self.currentFeedUniqueEZId);
    //NSLog(@"%@",self.currentFeedRecommendedDisplayName);
    //NSLog(@"%@",self.videoFindType);
    //NSLog(@"%@",self.selectedFeedType);
    //NSLog(@"%@",self.selectedFeedCategory);
    //NSLog(@"%@",self.selectedFeedPeriod);
    //NSLog(@"%@",self.selectedFeedRegion);
    //NSLog(@"%@",self.videoFeedId);

  
    
    
    NSMutableDictionary * videoFeedSource = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                         @"youtube", @"sourceSite",
                                         self.currentFeedUniqueEZId, @"feedUniqueId",
                                         self.currentFeedRecommendedDisplayName, @"displayName",   
                                         self.videoFindType, @"feed_OR_search",
                                         self.videoFeedId, @"feedURL",
                                         selectedFeedType_key, @"feedId",
                                         selectedFeedCategory_key, @"feedCategory",
                                         selectedFeedPeriod_key, @"feedPeriod",
                                         selectedFeedRegion_key, @"feedRegion",
                                         videoSearchQueryString,@"searchWords",
                                         selectedSearchSortBy_key,@"searchSortBy",
                                         nil];               
      
        [self.delegate addNewVideoFeedRecord:[videoFeedSource autorelease] informAboutFeeds:YES];
     //NSLog(@"%@",self.videoFeedId);
    [self showHideAddFeedButton];
}



#pragma mark - Spin The Wheel

- (IBAction)SpinTheWheel:(id)sender {
    
    self.keywordField.text = @"";
    
    //[pickerViewFeed selectRow:1 inComponent:0 animated:YES];
    //[pickerViewFeed reloadComponent:0];

    if((!self.feedTypeButton.selected) || (!self.feedPeriodButton.selected) || (!self.feedCountryButton.selected) || (!self.feedCategoryButton.selected))
    {
        [self playSound:@"slot_machine_high" :@"wav"];
    }
    
    for(int i =0; i<[pickerViewFeed numberOfComponents]; i++)
    {
        if(((i == 0) && self.feedTypeButton.selected) || ((i == 1) && self.feedPeriodButton.selected) || ((i == 2) && self.feedCountryButton.selected) || ((i == 3) && self.feedCategoryButton.selected) )
        {
            continue;
        }
        else
        {
            [self pickRandomRowforPicker:pickerViewFeed forComponent:i];
        }
        
    }
    
    //[self searchVideos:nil];
    [self performSelector:@selector(searchVideos:) withObject:nil afterDelay:1];
    
}


-(void) pickRandomRowforPicker:(UIPickerView *)picker forComponent:(int)compNum
{
    int rowCount = [picker numberOfRowsInComponent:compNum];
    
    int randomRow = arc4random()%rowCount;
    
    [pickerViewFeed selectRow:randomRow inComponent:compNum animated:YES];
    [pickerViewFeed reloadComponent:compNum];
}



-(void) playSound : (NSString *) fName : (NSString *) ext
{
    NSString *path  = [[NSBundle mainBundle] pathForResource : fName ofType :ext];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        AudioServicesCreateSystemSoundID((CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
    else
    {
        //NSLog(@"error, file not found: %@", path);
    }
}


#pragma mark - GData Youtube Data Feed returned

/*
-(NSString *) giveFriendlyDate:(NSDate *)uploadDate
{
    NSString * simpleDate;// = [[NSString alloc]init];
    NSDate * currentTime = [NSDate date];
    NSTimeInterval currentTimeSecs = [currentTime timeIntervalSinceReferenceDate];
    NSTimeInterval uploadTimeSecs = [uploadDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsedDowloadSecs = fabs(currentTimeSecs - uploadTimeSecs);
    
    if(elapsedDowloadSecs < 300)
    {
        //5 mins
        simpleDate  = [NSString stringWithString: @"5 mins"];
    }
    else  if(elapsedDowloadSecs < 1800)
    {
        //30 mins
        simpleDate  = [NSString stringWithString:@"30 mins"];
        
    }
    else  if(elapsedDowloadSecs < 3600)
    {
        //1 hour
        simpleDate  = [NSString stringWithString:@"1 hour"];
    }
    else  if(elapsedDowloadSecs < 18000)
    {
        //5 hours
        simpleDate  = [NSString stringWithString:@"5 hours"];
    }
    else  if(elapsedDowloadSecs < 86400)
    {
        //today
        simpleDate  = [NSString stringWithString:@"today"];
        
    }
    else 
    {
        //just show date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        simpleDate  = [dateFormatter stringFromDate:uploadDate];
        
    }
    
    return simpleDate;
}
*/


#pragma mark - Feed returned


- (void)request:(GDataServiceTicket *)ticket
finishedWithFeed:(GDataFeedBase *)aFeed
          error:(NSError *)error 
{

    //NSLog(@"-Download from GData complete");
    
    //NSManagedObjectContext * moc = [self.managedObjectContext copy];
    
	if(!error)
    {
        
        //Clear old results
        [feedVideoResultsArray removeAllObjects];
        //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        
        for (id feedEntry in [aFeed entries]) 
        {
            
            // NSArray * authors = [(GDataEntryYouTubeVideo *)feedEntry authors];
            //GDataAtomAuthor * author = [authors objectAtIndex:0];
            //NSString *userId =author.name;//self.sourceUserId;
            // NSString *sourceId = [author.name lowercaseString];
            
            
            
            
            GDataYouTubeMediaGroup * mediaGroup = [(GDataEntryYouTubeVideo *)feedEntry mediaGroup];
            
            
            NSArray *mediaContents = [mediaGroup mediaContents];
            NSNumber *flashFormatNum = [NSNumber numberWithInt:5];
            
            GDataMediaContent *flashContent;
            
            flashContent = [GDataUtilities firstObjectFromArray:mediaContents
                                                      withValue:flashFormatNum
                                                     forKeyPath:@
                            "youTubeFormatNumber"];
            
            //mediaContents = nil;
            
            
            
            if (flashContent != nil) 
            {
                NSArray * authors = [(GDataEntryYouTubeVideo *)feedEntry authors];
                GDataAtomAuthor * author = [authors objectAtIndex:0];
                NSString *sourceId = [author.name lowercaseString];
                
                
                NSString *videoURL=[flashContent URLString];
                //NSNumber *duration = [flashContent duration];
                //NSLog(@"Duration:%@",duration);
                NSArray *thumbnails = [mediaGroup mediaThumbnails];
                NSDate *uploadedDate = [[mediaGroup uploadedDate] date];
                //NSString * dateString = [dateFormatter stringFromDate:uploadedDate];
                NSString * dateString = [ls giveFriendlyDate:uploadedDate];
                //[dateString retain];
                NSString *videoId = [mediaGroup videoID];
                //NSURL *thumbNailURL = [NSURL URLWithString:[[thumbnails objectAtIndex:1] URLString]];
                NSString *thumbnailString = [[thumbnails objectAtIndex:1] URLString];
                //NSData *videoThumbnail=[NSData dataWithContentsOfURL:[NSURL URLWithString:[[thumbnails objectAtIndex:1] URLString]]];
                NSString *contentTitle =[[(GDataEntryBase *) feedEntry title] stringValue];
                
                NSDictionary * row = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      videoId,@"videoId",
                                      contentTitle,@"videoTitle",
                                      sourceId,@"channelId",
                                      videoURL,@"videoURL",
                                      dateString,@"videoUploadDate",
                                      thumbnailString,@"videoThumbnailString",
                                      nil];
                [feedVideoResultsArray addObject:row];
                [row release];
                
                //NSLog(@"Video:%@   Date:%@",contentTitle,uploadedDate);
                //NSLog(@"VideoCount:%d",feedVideoResultsArray.count);
                
            }
        }//End For Loop
        
        //[dateFormatter release];
        [self refreshVideoResults];
        
    }//End if error
    else
    {
        //Log error
        //NSLog(@"Downloaded GData has errors. ERROR DEscription:--->  %@",error.description);
        if([error.domain isEqualToString:@"NSURLErrorDomain"])
        {
            //NSLog(@"Error code:%d",error.code);
            if(error.code == -1009 || error.code == -1004 || error.code == -1001)
            {
                currentFeedLbl.text = ls.eZ_NO_INTERNET;
            }
        }
        
    }
    
    
    
    [self videoFeedComplete];
    
}


#pragma mark - populate Channel Results

-(void) refreshVideoResults
{
    

    
    CGRect frame = self.videosScrollView.frame;
    int height = frame.size.height;
    
    
    
    
    int i = 1;
    int x = 0;
    int xStart = 10;
    int xBuffer = 10;
    int yStart = 10;
    int yBuffer = 10;
    
    float videoCount = feedVideoResultsArray.count;
    int rowCount = ceil(videoCount / 3.0);
    int scrollWidth = (rowCount*(180+xBuffer))+2*xBuffer+6;
    if(scrollWidth < 1024)
        scrollWidth = 1024;
    self.videosScrollView.contentSize =  CGSizeMake(scrollWidth, height);
    
    
    
    int videoNum = 0;
    
    
    
    for (NSDictionary * videoRow in feedVideoResultsArray)
    {
        
        
        //Create Video Cell, Set the attributes
        EZFeedSearchVideoCellView * feedVideoCellView = [[EZFeedSearchVideoCellView alloc]init];
        
        feedVideoCellView.videoIndex = videoNum;
        feedVideoCellView.videoId = [videoRow objectForKey:@"videoId"];
        feedVideoCellView.videoTitle = [videoRow objectForKey:@"videoTitle"];
        feedVideoCellView.channelId = [videoRow objectForKey:@"channelId"];
        feedVideoCellView.videoThumbNailURLString = [videoRow objectForKey:@"videoThumbnailString"];
        feedVideoCellView.videoURL = [videoRow objectForKey:@"videoURL"];
        
        videoNum++;
        
        feedVideoCellView.videoTitleLbl.text = [NSString stringWithFormat:@"%d. %@",videoNum+start_index-1,[videoRow objectForKey:@"videoTitle"]];
        feedVideoCellView.videoUploadDateLbl.text = [videoRow objectForKey:@"videoUploadDate"];
        
        [feedVideoCellView setImagedDownloadQueue:self.videoFeedDownloadQueue];
        feedVideoCellView.delegate = self;
        
        //Add Video Cell view as SubView
        CGRect frame = feedVideoCellView.frame;
        frame.origin.x = xStart+x;
        frame.origin.y = yStart+(i-1)*(135+yBuffer);
        
        feedVideoCellView.frame = frame;
        
        [ self.videosScrollView addSubview:feedVideoCellView];
        [feedVideoCellView loadImageView];
        
        //Load Video Cell Images
        
        if(i == 1)
            i = 2;
        else if(i ==2)
            i = 3;
        else if(i ==3)
        {
            i = 1;
            x = x+180+xBuffer;
        }
    }
    
    
}






#pragma mark - Lock Unlock buttons during API Call
/*
-(void) videoFeedActive
{
    //Set CurrentFeed Return Type
    currentYoutubeAPISearchType = @"CHANNELS";
    
    //Disable Buttons
    [findChannelsButton setEnabled:NO];


}


-(void) videoFeedComplete
{
    //Set CurrentFeed Return Type
    currentYoutubeAPISearchType = @"NONE";
    
    //Enable Buttons
    [findChannelsButton setEnabled:YES];


}
*/

-(void) videoFeedActive
{
    
    
    //Set CurrentFeed Return Type
    currentYoutubeAPISearchType = @"VIDEOS";
    
    //Set the Search Decsription
    //self.currentFeedLbl.text = @"Most Viewed today";
    
    //Disable Buttons
    [findVideosButton setEnabled:NO];
    [spinButton setEnabled:NO];
    [searchButtonTop setEnabled:NO];
    [prevButton setEnabled:NO];
    [nextButton setEnabled:NO];
    [addVideoFeedButton setEnabled:NO];
    
    
    //StartActivityIndicator
    [feedActivityIndicator startAnimating];
    
    
    //Enable buttons after certain time
    aTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                              target:self 
                                            selector:@selector(videoFeedCompleteTimedOut) 
                                            userInfo:nil 
                                             repeats:NO];
    
}


-(void) videoFeedComplete
{
    
    //Set CurrentFeed Return Type
    currentYoutubeAPISearchType = @"NONE";
    
    //Enable Buttons
    [findVideosButton setEnabled:YES];
    [spinButton setEnabled:YES];
    [searchButtonTop setEnabled:YES];
    [prevButton setEnabled:YES];
    [nextButton setEnabled:YES];
    [addVideoFeedButton setEnabled:YES];
    
    //StopActivityIndicator
    [feedActivityIndicator stopAnimating];
    if(feedVideoResultsArray.count == 0)
    {
        currentFeedStartEndLbl.text = [NSString stringWithFormat:@"0 %@", ls.eZ_VIDEOS];
    }
   
    
}

-(void) videoFeedCompleteTimedOut
{
    //NSLog(@"videoFeedCompleteTimedOut");
    //Enable Buttons
    [findVideosButton setEnabled:YES];
    [spinButton setEnabled:YES];
    [searchButtonTop setEnabled:YES];
    [prevButton setEnabled:YES];
    [nextButton setEnabled:YES];
    [addVideoFeedButton setEnabled:YES];
   
}





#pragma mark - Clear Feed

-(void) clearCurrentFeed
{
    [self.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.feedVideoResultsArray removeAllObjects];
    [self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 1024, 561) animated:YES];
    
}



#pragma mark - ChannelVideosVC Delegate
-(void) videosDownloadComplete
{
    [self videoFeedComplete];
}
    

#pragma mark - Playing Video in popup, Enter, Exit Full Screen

-(void) popVideo:(NSString *)videoId title:(NSString *)title;
{

    //[self.delegate popVideo:videoId title:title];
    
}


-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId;
{
    
    //[self.delegate popVideo:videoId title:title channelId:channelId];
    
    
    
    
    self.videoViewController.videoId = videoId;
    self.videoViewController.videoTitle = title;
    self.videoViewController.channelId = channelId;
    //self.videoViewController.playerType = self.currentPlayer;
    
    
    
    popOver = [[UIPopoverController alloc]initWithContentViewController:videoViewController];
    //[videoViewController release];
    
    
    CGRect popRect = CGRectMake(384,70,160,60);
    
    popOver.delegate = self;
    
    videoEnteredFullScreen1 = NO;
    
    [popOver presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [self.videoViewController loadVideo];
    
}

-(void) loadAllVideosInExternalPlayerStartingWithVideoIndex:(int)index
{
    NSMutableArray * videoSetArray = [[NSMutableArray alloc] init];
    //make the videoSetArray
    
    for (NSDictionary * videoRow in feedVideoResultsArray)
    {
        NSDictionary * videoInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [videoRow objectForKey:@"videoId"],@"videoId",
                                    [videoRow objectForKey:@"videoTitle"],@"videoTitle",
                                    [videoRow objectForKey:@"channelId"],@"videoChannelId",
                                    [videoRow objectForKey:@"videoThumbnailString"],@"videoImgURL",
                                    [videoRow objectForKey:@"videoUploadDate"],@"videoUploadDate",
                                    nil ];
        [videoSetArray addObject:videoInfo];
        [videoInfo autorelease];
    }
    
    NSDictionary * feed_OR_Channel_info = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           self.videoFindType,@"feed_Channel_Type",
                                           self.currentFeedRecommendedDisplayName,@"feed_Channel_Title",
                                           countryIconImageView.image,@"feed_Channel_FlagImg",
                                           categoryIconImageView.image,@"feed_Channel_Category_Channel_img",
                                           nil ];
    
    
    [self.delegate loadAllVideosInExternalPlayerWithVideoSetArray:videoSetArray feedChannelInfo:feed_OR_Channel_info StartingWithVideoIndex:index];
}



- (void)youtubeFullScreenEnteredUIMoviePlayer:(NSNotification *)notification
{
    
    videoEnteredFullScreen1 = YES;
    
    if(popOver.isPopoverVisible)
    {
        [popOver dismissPopoverAnimated:YES];
    }
    
    
}

- (void)youtubeFullScreenExitedUIMoviePlayer:(NSNotification *)notification
{
    
    videoEnteredFullScreen1 = NO;
    CGRect popRect = CGRectMake(384,70,160,60);
    
    [popOver presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    
}



-(void) youtubeFullScreenPlaybackFinished:(NSNotification *)notification
{
    
    //NSLog(@"NOTIFICATION Info: %@", notification.description);
}

#pragma mark - Dismiss Video Popup and Channels popup


- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popover
{
  if ([popover.contentViewController isKindOfClass:[TSVideoViewController class]]) 
    {
        if(!videoEnteredFullScreen1)
        {
            //NSLog(@"Releasing Video VC");
            //[((TSVideoViewController *)popover.contentViewController).webView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            //[((TSVideoViewController *)popover.contentViewController).webView loadHTMLString:@"<body bgcolor=black></body>"  baseURL:nil];
            [((TSVideoViewController *)popover.contentViewController) clearVideo];
            //popover.contentViewController = nil;
            //[videoViewController release];
        }
    }
    return YES;  
}

    
- (void)dealloc {
    
    AudioServicesDisposeSystemSoundID(audioEffect);
  
    [pickerViewFeed release];

    [keywordField release];

    [findVideosButton release];

    [videosScrollView release];
    [currentFeedLbl release];
    [feedActivityIndicator release];
    [addVideoFeedButton release];
    [feedAddStatusLbl release];
   
    [pickerViewSort release];
    [feedTypeButton release];
    [feedPeriodButton release];
    [feedCountryButton release];
    [feedCategoryButton release];
    [currentFeedStartEndLbl release];
    [spinButton release];
    [searchButtonTop release];
    [prevButton release];
    [nextButton release];
    [orLbl release];
    [keywordSearchLbl release];
    [sortedByLbl release];
    [countryIconImageView release];
    [categoryIconImageView release];
    [super dealloc];
}
@end
