//
//  EZChannelSearchViewController.m
//  EZ Tube
//
//  Created by dan mullaguru on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EZChannelSearchViewController.h"

@interface EZChannelSearchViewController()
{
    BOOL videoEnteredFullScreen1;// = NO;
    NSArray *pickerArraySearchTypeDisplay;
    NSArray *pickerArraySearchPeriodDisplay;
    NSArray *pickerArraySearchRegionDisplay;
    NSArray *pickerArraySearchChanneltypeDisplay;
    
    NSString * selectedFeedTypeDisplay;
    NSString * selectedFeedPeriodDisplay;
    NSString * selectedFeedRegionDisplay;
    NSString * selectedFeedChannelTypeDisplay;
    
    
}
-(void) populatePickerArrays;
-(void)prepareSearchQueryString;
-(void) prepareFeedId;
-(void)refreshChannelResults;
-(NSString *) giveFeedIdForStartIndex:(int)start;
-(void) launchYoutubeAPIChannelFeedQuery:(NSString *)queryFeedID;
-(void) launchYoutubeAPIChannelSearchQuery;
-(void) displayChannelsHeader;

-(void) channelFeedActive;
-(void) channelFeedComplete;
-(void) channelFeedCompleteTimedOut;
-(void) videoFeedActive;
-(void) videoFeedComplete;
-(void) loadChannelVideosView;
-(void) pickRandomRowforPicker:(UIPickerView *)picker forComponent:(int)compNum;
-(void) playSound : (NSString *) fName : (NSString *) ext;

-(void) launchInitialChannelLoadSearchForFeedId:(NSString *)feedId 
                                     feedPeriod:(NSString *)feedPeriod 
                                     feedRegion:(NSString *)feedRegion 
                                   feedCategory:(NSString *)feedCategory
                                  channelsCount:(int)numOfChannels;

@end

@implementation EZChannelSearchViewController

@synthesize ls;

@synthesize feedTypeButton;
@synthesize feedPeriodButton;
@synthesize feedCountryButton;
@synthesize feedCategoryButton;
@synthesize spinButton;
@synthesize searchButton;
@synthesize orLbl;


SystemSoundID audioEffect;

@synthesize managedObjectContext = __managedObjectContext;

@synthesize pickerArraySearchType;
@synthesize pickerArraySearchPeriod;
@synthesize pickerArraySearchRegion;
@synthesize pickerArraySearchChanneltype;
@synthesize pickerArraySearchChanneltypeIcons;

@synthesize bannedChannels;

@synthesize channelsTableView;
@synthesize pickerView;
@synthesize prevButton;
@synthesize nextButton;
@synthesize keywordField;
@synthesize findChannelsButton;
@synthesize showingResultsLabel;
@synthesize channelFeedActivityIndicator;
@synthesize keywordSearchLbl;

@synthesize currentSearchInfoLabel;

@synthesize currentYoutubeAPISearchType;

@synthesize channelVideosVC;

@synthesize channelFeedID;
@synthesize channelFindType;
@synthesize channelSearchQueryString;

@synthesize selectedFeedType;
@synthesize selectedFeedPeriod;
@synthesize selectedFeedRegion;
@synthesize pickerArraySearchRegionFlags;
@synthesize selectedFeedChannelType;

@synthesize delegate;
@synthesize videoViewController;


UIPopoverController * popOver;


int max_results = 25;
int start_index = 1;
int channelShow_videoLimit = 12;
int results_returned = 0;


NSMutableArray * channelResultsArray ;
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
    
    //ReSize Picker
    pickerView.frame = CGRectMake(0.0, 0.0, 718.0, 162.0);
    
    // Do any additional setup after loading the view from its nib.
    currentYoutubeAPISearchType = @"NONE";
    
    [self populatePickerArrays];
    channelResultsArray = [[NSMutableArray alloc]init];
    //videoResultsArray = [[NSMutableArray alloc]init];
    youTubeService = [[TSDownloadManager sharedInstance] youTubeService];
    
    
    //[((UIScrollView *)self.view) setContentSize:CGSizeMake(1024, 916)];
    
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(youtubeFullScreenEnteredUIMoviePlayer:)
                                                 name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(youtubeFullScreenExitedUIMoviePlayer:)
                                                 name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    */
    
    
    //[self loadDefaultChannelssForCountryLocale];
    
    [self loadChannelVideosView];
    
    [self setVCtoCurrentLanguage];
    
    UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                action:@selector(pickerTap)];
    [pickerView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    bannedChannels = [[NSDictionary alloc]initWithObjectsAndKeys:
                                                @"1",@"shaziajafrey8",
     nil ];
    
}

/*
-(void) loadLanguageUI
{
    
    orLbl.text  = EZ_OR;
    keywordSearchLbl.text = EZ_KEYWORD_SEARCH;
    keywordField.placeholder = EZ_KEY_WORD;
}
 */


- (void)pickerTap {
    //NSLog(@"Picker tapped"); 
    keywordField.text = @"";
}


- (void)viewDidUnload
{
    [self setChannelsTableView:nil];
    [self setPickerView:nil];
    [self setPrevButton:nil];
    [self setNextButton:nil];
    [self setKeywordField:nil];
    [self setShowingResultsLabel:nil];
    [self setCurrentSearchInfoLabel:nil];
    [self setFindChannelsButton:nil];
    [self setChannelFeedActivityIndicator:nil];
    
    [self setFeedTypeButton:nil];
    [self setFeedPeriodButton:nil];
    [self setFeedCountryButton:nil];
    [self setFeedCategoryButton:nil];
   
    [self setSpinButton:nil];
    [self setSearchButton:nil];
    [self setOrLbl:nil];
    [self setKeywordSearchLbl:nil];
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
    
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    //Remove Observer
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
    
}


-(void)viewDidAppear:(BOOL)animated
{
    if(channelResultsArray.count < 1)
    {
        [self searchChannels:nil];
    }
    
    [self.channelVideosVC viewDidAppear:NO];
    
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
        [self searchChannels:nil];
        return YES;
        
    }
    else 
    {
        return NO;
    }
}

-(void) loadDefaultChannelssForCountryLocale
{
    //loadDefaultChannelsIterationCounter
    int currentChannelsCount = [Source allSourcesCountInManagedObjectContext:self.managedObjectContext];
    //currentChannelsCount = 0;
    
        
    if(currentChannelsCount <2 )
    {
        
        //Use locale and find country
        
        NSLocale *locale = [NSLocale currentLocale];
        NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
        countryCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentAppCountry"];
        
        //NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
        
        //NSString *country = [usLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
        
        //NSLog(@"Country Code: %@, Country: %@", countryCode, country);
        
        int countryPickerIndex = [self.pickerArraySearchRegion indexOfObject:countryCode];
        //NSLog(@"Country exists in picker:%d",countryPickerIndex);
        
        [pickerView selectRow:countryPickerIndex inComponent:2 animated:YES];
        [pickerView reloadComponent:2];
        [feedCountryButton setSelected:YES];
        
        [pickerView selectRow:0 inComponent:0 animated:YES];
        [pickerView reloadComponent:0];
        
        
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView reloadComponent:1];
        [feedPeriodButton setSelected:YES];
        
        /*
        NSString * feedCategory = @"Partners";
        if([countryCode isEqualToString:@"US"])
        {
            feedCategory = @"Reporters";
        }
        */
     
        //Add Latest Videos dummy channel
        
        NSMutableDictionary * videoSource = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                             @"youtube", @"sourceSite",
                                             @"newvideos", @"sourceUserId",
                                             @"* Latest Videos", @"displayName",
                                             [NSNumber numberWithInt:200], @"maxVideos",
                                             @"High",@"thumbnailQuality",
                                             UIImagePNGRepresentation([UIImage imageNamed:@"newvideos.png"]), @"channelThumbnail",
                                             [NSNumber numberWithBool:YES],@"isSystemInstalled",
                                             nil];               
        
        
        [self.delegate addNewVideoSourceRecord:[videoSource autorelease] informAboutFeeds:NO];

        
        //Launch ChannelInitialSearch Based On Country of Origin
        //Most Viewed, this month, country, ALL
        //[self launchInitialChannelLoadSearchForFeedId:@"most_viewed" feedPeriod:@"this_month" feedRegion:countryCode feedCategory:feedCategory];
        
        
        ///////      NSArray *arrayToLoadPickerRegion = [[NSArray alloc] initWithObjects: @"ALL",@"AR",@"AU",@"BR",@"CA",@"CZ",@"FR",@"DE",@"GB",@"HK",@"IN",@"IE",@"IL",@"IT",@"JP",@"MX",@"NL",@"NZ",@"PL",@"RU",@"ZA",@"KR",@"ES",@"SE",@"TW",@"US", nil];
           
        /* pickerArraySearchRegionDisplay = [[NSArray alloc] initWithObjects: @"All Countries",@"Argentina",@"Australia",@"Brazil",@"Canada",@"Czech Republic",@"France",@"Germany",@"Great Britain",@"Hong Kong",@"India",@"Ireland",@"Israel",@"Italy",@"Japan",@"Mexico",@"Netherlands",@"New Zealand",@"Poland",@"Russia",@"South Africa",@"South Korea",@"Spain",@"Sweden",@"Taiwan",@"United States", nil]; */
        
        
       
        
        //All Channel Types, ALL time, most viewed
        //spain
        /*
         if([countryCode isEqualToString:@"ES"] )
        {
            [self launchInitialChannelLoadSearchForFeedId:@"most_viewed" feedPeriod:@"all_time" feedRegion:countryCode feedCategory:@"ALL" channelsCount:50];
        }
         */
        
        //AReporters, ALL time, most viewed
        //ALL Countries, canada,
        if([countryCode isEqualToString:@"CA"] || [countryCode isEqualToString:@"ALL"] || [countryCode isEqualToString:@"ES"])
        {
            [self launchInitialChannelLoadSearchForFeedId:@"most_viewed" feedPeriod:@"this_month" feedRegion:countryCode feedCategory:@"Reporters" channelsCount:50];
        }
        
        //All Channel Types, this month, most viewed
        //USA, Taiwan, Sweden,south korea,south africa,Poland, NewZealand,Mexico,Japan,italy,israel,ireland,hongkong,czech,brazil, Argentina,Australia
        if([countryCode isEqualToString:@"US"] || [countryCode isEqualToString:@"TW"] || [countryCode isEqualToString:@"SE"] || [countryCode isEqualToString:@"KR"] || [countryCode isEqualToString:@"ZA"] || [countryCode isEqualToString:@"PL"] || [countryCode isEqualToString:@"NZ"] || [countryCode isEqualToString:@"MX"] || [countryCode isEqualToString:@"JP"] || [countryCode isEqualToString:@"IT"] || [countryCode isEqualToString:@"IL"] || [countryCode isEqualToString:@"IE"] || [countryCode isEqualToString:@"HK"] || [countryCode isEqualToString:@"CZ"] || [countryCode isEqualToString:@"BR"] || [countryCode isEqualToString:@"AR"] || [countryCode isEqualToString:@"AU"])
        {
             [self launchInitialChannelLoadSearchForFeedId:@"most_viewed" feedPeriod:@"this_month" feedRegion:countryCode feedCategory:@"ALL" channelsCount:50];
        }
        
        //Partners, this month, most viewed
        //India, Russia,netherlands,great britain,france,Germany
        if([countryCode isEqualToString:@"IN"] || [countryCode isEqualToString:@"RU"] || [countryCode isEqualToString:@"GB"] || [countryCode isEqualToString:@"NL"] || [countryCode isEqualToString:@"FR"] || [countryCode isEqualToString:@"DE"])
        {
            //NSLog(@"Country Code:%@",countryCode);
            [self launchInitialChannelLoadSearchForFeedId:@"most_viewed" feedPeriod:@"this_month" feedRegion:countryCode feedCategory:@"Partners" channelsCount:50];
        }
        

        
    }

    
    
}


-(void) launchInitialChannelLoadSearchForFeedId:(NSString *)feedType 
                 feedPeriod:(NSString *)feedPeriod 
                 feedRegion:(NSString *)feedRegion 
               feedCategory:(NSString *)feedCategory
              channelsCount:(int)numOfChannels
{
        //NSLog(@"launchInitialChannelLoadSearchForFeedId");
    
    
    NSString * feedRegionFixed;
    NSString * feedCategoryFixed;
    
    NSString * feedURL;

    
    //Period today not allowed for most_subscribed
    if([feedType isEqualToString:@"most_subscribed"] && [feedPeriod isEqualToString:@"today"])
    {
        feedPeriod = [NSMutableString stringWithFormat:@"this_week"]; 
    }  
    
    //Set Country...blank if ALL
    if([feedRegion isEqualToString:@"ALL"])
    {
        feedRegionFixed = [NSMutableString stringWithFormat:@""];
        
    }
    else
    {
        feedRegionFixed = [NSMutableString stringWithFormat:@"%@/",feedRegion];
    }
    
    //Set Channel type...blank if ALL
    if([feedCategory isEqualToString:@"ALL"])
    {
        feedCategoryFixed = [NSMutableString stringWithFormat:@""];
    }
    else
    {
        feedCategoryFixed = [NSMutableString stringWithFormat:@"_%@",feedCategory];
    }

    feedURL = [NSString stringWithFormat:@"%@%@%@?&time=%@",feedRegionFixed,feedType,feedCategoryFixed,feedPeriod];
    
    self.currentYoutubeAPISearchType = @"CHANNEL_INITIAL_LOAD";
    //max_results = 50;
    //[NSMutableString stringWithFormat:@"%@&start-index=%d&max-results=%d&v=2",feedURL,0,50];
    [self launchYoutubeAPIChannelFeedQuery:[NSMutableString stringWithFormat:@"%@&start-index=%d&max-results=%d&v=2",feedURL,1,numOfChannels]];
    //max_results = 25;
                  
}


-(void) saveTopTenChannels:(NSArray *)initialLoadchannelsResultsArray
{
    //NSLog(@"Saving Top Ten Channels");
    
    NSArray * channelsInCountry = initialLoadchannelsResultsArray;
    
    //NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"videoCountInt"  ascending:NO];
    //NSArray * sortedChannelsInCountry = [channelsInCountry sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

    int i = 1;
    for (NSDictionary* channelInfo in channelsInCountry)
    {
        //NSLog(@"TOP CHANNEL:%@, Videos:%@ ",[channelInfo objectForKey:@"channelName"],[channelInfo objectForKey:@"videoCountInt"]);
        
        NSMutableDictionary * videoSource = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                             @"youtube", @"sourceSite",
                                             [channelInfo objectForKey:@"channelName"], @"sourceUserId",
                                             [channelInfo objectForKey:@"channelName"], @"displayName",
                                             [NSNumber numberWithInt:200], @"maxVideos",
                                             @"High",@"thumbnailQuality",
                                             UIImagePNGRepresentation([channelInfo objectForKey:@"thumbImg"]), @"channelThumbnail",
                                             nil];               
        
        
        [self.delegate addNewVideoSourceRecord:[videoSource autorelease] informAboutFeeds:NO];
        
        i++;
        if (i > 50)
            break;
    }
    //Sort the channels by video count
    
    //Save top ten to database
    
    self.currentYoutubeAPISearchType = @"NONE";
    
    [self.delegate startFullDownloadOfChannels];
    
    //NSLog(@"Populated top 50 channels");
    
    
}




#pragma mark - setCurrent Language to UI
-(void) setVCtoCurrentLanguage
{
    
    LocalizationLoadCurrentLanguage;
    
    pickerArraySearchTypeDisplay= [[NSArray alloc] initWithObjects: ls.eZ_MOST_VIEWED,ls.eZ_MOST_SUBSCRIBED, nil];
    
    pickerArraySearchPeriodDisplay = [[NSArray alloc] initWithObjects: ls.eZ_TODAY,ls.eZ_THIS_WEEK,ls.eZ_THIS_MONTH,ls.eZ_ALL_TIME, nil];
    
    
    pickerArraySearchRegionDisplay = [[NSArray alloc] initWithObjects: ls.eZ_ALL_COUNTRIES,ls.eZ_ARGENTINA,ls.eZ_AUSTRALIA,ls.eZ_BRAZIL,ls.eZ_CANADA,ls.eZ_CZECH,ls.eZ_FRANCE,ls.eZ_GERMANY,ls.eZ_BRITAIN,ls.eZ_HONGKONG,ls.eZ_INDIA,ls.eZ_IRELAND,ls.eZ_ISRAEL,ls.eZ_ITALY,ls.eZ_JAPAN,ls.eZ_MEXICO,ls.eZ_NETHERLANDS,ls.eZ_NEWZEALAND,ls.eZ_POLAND,ls.eZ_RUSSIA,ls.eZ_SOUTHAFRICA,ls.eZ_SOUTHKOREA,ls.eZ_SPAIN,ls.eZ_SWEDEN,ls.eZ_TAIWAN,ls.eZ_UNITEDSTATES, nil];
    
    pickerArraySearchChanneltypeDisplay = [[NSArray alloc] initWithObjects: ls.eZ_ALL_CHANNEL_TYPES,ls.eZ_REPORTERS,ls.eZ_MUSICIANS,ls.eZ_COMEDIANS,ls.eZ_DIRECTORS,ls.eZ_GURUS,ls.eZ_PARTNERS,ls.eZ_SPONSORS,ls.eZ_NON_PROFIT,ls.eZ_POLITICIANS, nil];
    
    
    [pickerView reloadAllComponents];
    
    orLbl.text  = ls.eZ_OR;
    keywordSearchLbl.text = ls.eZ_KEYWORD_SEARCH;
    keywordField.placeholder = ls.eZ_KEY_WORD;
    
    //Load localized images
    
    //Spin button
    UIImage *spin_red_highlighted_img = [[UIImage alloc] initWithContentsOfFile:ls.spin_red_highlighted_path];
    if(!spin_red_highlighted_img)
    {
        spin_red_highlighted_img = [[UIImage alloc] initWithContentsOfFile:ls.spin_red_highlighted_mainBundle_path];
    }
    
    
    UIImage *spin_red_default_img = [[UIImage alloc] initWithContentsOfFile:ls.spin_red_default_path];
    if(!spin_red_default_img)
    {
        spin_red_default_img = [[UIImage alloc] initWithContentsOfFile:ls.spin_red_default_mainBundle_path];
    }
    
    [spinButton setImage:spin_red_default_img forState:UIControlStateNormal];
    [spinButton setImage:spin_red_highlighted_img forState:UIControlStateHighlighted];

    [spin_red_default_img release];
    [spin_red_highlighted_img release];
    
    //Search button
    
    UIImage *searchbutton_img = [[UIImage alloc] initWithContentsOfFile:ls.searchbutton_path];
    if(!searchbutton_img)
    {
        searchbutton_img = [[UIImage alloc] initWithContentsOfFile:ls.searchbutton_mainBundle_path];
    }
    [searchButton setImage:searchbutton_img forState:UIControlStateNormal];
    [findChannelsButton setImage:searchbutton_img forState:UIControlStateNormal];
    [searchbutton_img release];
    
    self.currentSearchInfoLabel.text = @"";
    
    [channelsTableView reloadData];
    [channelVideosVC setVCtoCurrentLanguage];
    
}



-(void) loadChannelVideosView
{
    channelVideosVC = [[ChannelVideosViewController alloc]init];
    CGRect frame = channelVideosVC.view.frame;
    frame.origin.x = 271;
    frame.origin.y = 162;
    
    channelVideosVC.view.frame = frame;
    
    [self.view addSubview:channelVideosVC.view];
    channelVideosVC.delegate = self;
    channelVideosVC.managedObjectContext = self.managedObjectContext;
}

#pragma mark - populate pickerArrays

-(void) populatePickerArrays
{
    NSArray *arrayToLoadPickerTypes = [[NSArray alloc] initWithObjects: @"most_viewed",@"most_subscribed", nil];
     //pickerArraySearchTypeDisplay= [[NSArray alloc] initWithObjects: @"Most viewed",@"Most subscribed", nil];
    
   // pickerArraySearchTypeDisplay= [[NSArray alloc] initWithObjects: EZ_MOST_VIEWED,EZ_MOST_SUBSCRIBED, nil];
    self.pickerArraySearchType = arrayToLoadPickerTypes;
    [arrayToLoadPickerTypes release];
    
    NSArray *arrayToLoadPickerPeriod = [[NSArray alloc] initWithObjects: @"today",@"this_week",@"this_month",@"all_time", nil];
   //pickerArraySearchPeriodDisplay = [[NSArray alloc] initWithObjects: @"today",@"this week",@"this month",@"all time", nil];
   // pickerArraySearchPeriodDisplay = [[NSArray alloc] initWithObjects: EZ_TODAY,EZ_THIS_WEEK,EZ_THIS_MONTH,EZ_ALL_TIME, nil];
    self.pickerArraySearchPeriod = arrayToLoadPickerPeriod;
    [arrayToLoadPickerPeriod release];
    
    //NOTE: For most_subscribed cahnnels, "today" does not work.
    
    
    NSArray *arrayToLoadPickerRegion = [[NSArray alloc] initWithObjects: @"ALL",@"AR",@"AU",@"BR",@"CA",@"CZ",@"FR",@"DE",@"GB",@"HK",@"IN",@"IE",@"IL",@"IT",@"JP",@"MX",@"NL",@"NZ",@"PL",@"RU",@"ZA",@"KR",@"ES",@"SE",@"TW",@"US", nil];
    /* pickerArraySearchRegionDisplay = [[NSArray alloc] initWithObjects: @"All Countries",@"Argentina",@"Australia",@"Brazil",@"Canada",@"Czech Republic",@"France",@"Germany",@"Great Britain",@"Hong Kong",@"India",@"Ireland",@"Israel",@"Italy",@"Japan",@"Mexico",@"Netherlands",@"New Zealand",@"Poland",@"Russia",@"South Africa",@"South Korea",@"Spain",@"Sweden",@"Taiwan",@"United States", nil]; */
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
    
    
    
    self.pickerArraySearchRegion = arrayToLoadPickerRegion;
    [arrayToLoadPickerRegion release];
    
    NSArray *arrayToLoadPickerChannelType = [[NSArray alloc] initWithObjects: @"ALL",@"Reporters",@"Musicians",@"Comedians",@"Directors",@"Gurus",@"Partners",@"Sponsors",@"Non-Profit",@"Politicians", nil];
    /* pickerArraySearchChanneltypeDisplay = [[NSArray alloc] initWithObjects: @"All Channel types",@"Reporters",@"Musicians",@"Comedians",@"Directors",@"Gurus",@"Partners",@"Sponsors",@"Non-Profit",@"Politicians", nil]; */
    /*
    pickerArraySearchChanneltypeDisplay = [[NSArray alloc] initWithObjects: EZ_ALL_CHANNEL_TYPES,EZ_REPORTERS,EZ_MUSICIANS,EZ_COMEDIANS,EZ_DIRECTORS,EZ_GURUS,EZ_PARTNERS,EZ_SPONSORS,EZ_NON_PROFIT,EZ_POLITICIANS, nil];
    */
    
    pickerArraySearchChanneltypeIcons = [[NSArray alloc] initWithObjects: 
                                    [UIImage imageNamed:@"all.png"],
                                    [UIImage imageNamed:@"reporters.png"],
                                    [UIImage imageNamed:@"musician.png"],
                                    [UIImage imageNamed:@"comedian.png"],
                                    [UIImage imageNamed:@"director.png"],
                                    [UIImage imageNamed:@"guru.png"],
                                    [UIImage imageNamed:@"partners.png"],
                                    [UIImage imageNamed:@"sponsors.png"],
                                    [UIImage imageNamed:@"nonprofit.png"],
                                    [UIImage imageNamed:@"politician.png"],
                                    nil];
    
    
    self.pickerArraySearchChanneltype = arrayToLoadPickerChannelType;
    [arrayToLoadPickerChannelType release];
    
    
    
    
}




#pragma mark - Picker View Datasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return 191;
        case 1:
            return 135;
        case 2:
            return 173;
        case 3:
            return 190;
            
        default:
            break;
    }
    return 50;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
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


/*
 
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString * title = @"";
    
    switch (component) {
        case 0:
            title = [pickerArraySearchTypeDisplay objectAtIndex:row];
            break;
        case 1:
            title = [pickerArraySearchPeriodDisplay objectAtIndex:row];
            break;
        case 2:
            title = [pickerArraySearchRegionDisplay objectAtIndex:row];
            break;
        case 3:
            title = [pickerArraySearchChanneltypeDisplay objectAtIndex:row];
            break;
            
        default:
            break;
    }
    return title;

}

*/


-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    NSString * title = @"";
    UILabel *channelLabel;
    UIView *tmpView;
    UIImageView * temp;
    
 
        switch (component) {
            case 0:
                title = [pickerArraySearchTypeDisplay objectAtIndex:row];
                channelLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 5, 190, 30)];
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
                
                channelLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 150, 30)];
                channelLabel.text = title;
                channelLabel.textAlignment = UITextAlignmentLeft;
                channelLabel.backgroundColor = [UIColor clearColor];
                channelLabel.textColor = [UIColor whiteColor];
                
                tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 190, 40)];
                [tmpView setBackgroundColor:[UIColor blackColor]];
                [tmpView insertSubview:temp atIndex:0];
                [tmpView insertSubview:channelLabel atIndex:1];
                return tmpView;
                break;
                
            default:
                break;
        }

    
    return tmpView;
    
}






#pragma mark - Picker View Delegate
-(void)pickerView:(UIPickerView *)pickerViewSent didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if([pickerViewSent isEqual:pickerView])
    {
        keywordField.text = @"";
    }
}


#pragma mark - Give FeedID For Start_Index

-(NSString *) giveFeedIdForStartIndex:(int)start
{
    //NSLog(@"Curent Feed:%@",channelFeedID);
    NSString * tempFeedID = [NSMutableString stringWithFormat:@"%@&start-index=%d&max-results=%d&v=2",channelFeedID,start,max_results];
    
    return tempFeedID;
    
}

#pragma mark - prepare SearchQueryString

-(void)prepareSearchQueryString
{
    //[channelFeedID release];
    //channelFeedID = NULL;
    
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
    channelSearchQueryString = qString;
    [channelSearchQueryString retain];
    //NSLog(@"channel Search Query String:%@",channelSearchQueryString);
}


#pragma mark - prepare FeedID

-(void)prepareFeedId
{
    //[channelSearchQueryString release];
    //channelSearchQueryString = NULL;
    
   
    //NSMutableString * feedID ;//= @"IN/most_viewed_Partners?&time=all_time&start-index=1&max-results=50&v=2";
     /*
    NSMutableString * countryCode = @"";
    NSMutableString * feedType = @"most_viewed";
    NSMutableString * channelType = @"";
    NSMutableString * period = @"";
     */
    //int max_results = 50;
    
    int selectedIndex = 0;
    
    selectedIndex = [pickerView selectedRowInComponent:0];
    //NSMutableString * 
    selectedFeedType = [pickerArraySearchType objectAtIndex:selectedIndex];
    selectedFeedTypeDisplay = [pickerArraySearchTypeDisplay objectAtIndex:selectedIndex];
    
    selectedIndex = [pickerView selectedRowInComponent:1];
    //NSMutableString * 
    selectedFeedPeriod = [pickerArraySearchPeriod objectAtIndex:selectedIndex];
    selectedFeedPeriodDisplay = [pickerArraySearchPeriodDisplay objectAtIndex:selectedIndex];
    
    selectedIndex = [pickerView selectedRowInComponent:2];
    //NSMutableString * 
    selectedFeedRegion = [pickerArraySearchRegion objectAtIndex:selectedIndex];
    selectedFeedRegionDisplay = [pickerArraySearchRegionDisplay objectAtIndex:selectedIndex];
    
    selectedIndex = [pickerView selectedRowInComponent:3];
    //NSMutableString * 
    selectedFeedChannelType = [pickerArraySearchChanneltype objectAtIndex:selectedIndex];
    selectedFeedChannelTypeDisplay = [pickerArraySearchChanneltypeDisplay objectAtIndex:selectedIndex];
    
    //Period today not allowed for most_subscribed
    if([selectedFeedType isEqualToString:@"most_subscribed"] && [selectedFeedPeriod isEqualToString:@"today"])
    {
        selectedFeedPeriod = [NSMutableString stringWithFormat:@"this_week"]; 
        //selectedFeedPeriodDisplay = [NSMutableString stringWithFormat:@"this week"]; 
        selectedFeedPeriodDisplay = [pickerArraySearchPeriodDisplay objectAtIndex:1];
        
    }  
    
    //Set Country...blank if ALL
    if([selectedFeedRegion isEqualToString:@"ALL"])
    {
        selectedFeedRegion = [NSMutableString stringWithFormat:@""];
        
    }
    else
    {
        selectedFeedRegion = [NSMutableString stringWithFormat:@"%@/",selectedFeedRegion];
    }
    
    //Set Channel type...blank if ALL
    if([selectedFeedChannelType isEqualToString:@"ALL"])
    {
        selectedFeedChannelType = [NSMutableString stringWithFormat:@""];
    }
    else
    {
        selectedFeedChannelType = [NSMutableString stringWithFormat:@"_%@",selectedFeedChannelType];
    }
    
    /*
    feedID = [NSMutableString stringWithFormat:@"%@%@%@?&time=%@&start-index=%d&max-results=%d&v=2",selectedFeedRegion,selectedFeedType,selectedFeedChannelType,selectedFeedPeriod,start_index,max_results];
    */
    channelFeedID = [NSString stringWithFormat:@"%@%@%@?&time=%@",selectedFeedRegion,selectedFeedType,selectedFeedChannelType,selectedFeedPeriod];
    [channelFeedID retain];

    
}

#pragma mark - User Actions 

- (IBAction)spinTheWheel:(id)sender {

    
    keywordField.text = @"";
    
    //[pickerViewFeed selectRow:1 inComponent:0 animated:YES];
    //[pickerViewFeed reloadComponent:0];
    
    if((!self.feedTypeButton.selected) || (!self.feedPeriodButton.selected) || (!self.feedCountryButton.selected) || (!self.feedCategoryButton.selected))
    {
        [self playSound:@"slot_machine_high" :@"wav"];
    }
    
    for(int i =0; i<[pickerView numberOfComponents]; i++)
    {
        if(((i == 0) && self.feedTypeButton.selected) || ((i == 1) && self.feedPeriodButton.selected) || ((i == 2) && self.feedCountryButton.selected) || ((i == 3) && self.feedCategoryButton.selected) )
        {
            continue;
        }
        else
        {
            [self pickRandomRowforPicker:pickerView forComponent:i];
        }
        
    }
    
    //[self searchVideos:nil];
    [self performSelector:@selector(searchChannels:) withObject:nil afterDelay:1];
    
}


-(void) pickRandomRowforPicker:(UIPickerView *)picker forComponent:(int)compNum
{
    int rowCount = [picker numberOfRowsInComponent:compNum];
    
    int randomRow = arc4random()%rowCount;
    
    [pickerView selectRow:randomRow inComponent:compNum animated:YES];
    [pickerView reloadComponent:compNum];
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









- (IBAction)searchChannels:(id)sender {
    
   
    
    [self.keywordField resignFirstResponder];
    
    [self.channelVideosVC.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.channelVideosVC clearChannelHeaderInfo];
    
    
    [self channelFeedActive];
    
    //Reset Start_Index
    start_index = 1;

    if([keywordField.text isEqualToString:@""] )
    {
        [self prepareFeedId];
        NSString * queryFeedID = [self giveFeedIdForStartIndex:start_index];
        [self launchYoutubeAPIChannelFeedQuery:queryFeedID];
        
        currentSearchInfoLabel.text = [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@ %@",selectedFeedTypeDisplay,ls.eZ_CHANNELS,selectedFeedPeriodDisplay,ls.eZ_IN,selectedFeedRegionDisplay,ls.eZ_AMONG,selectedFeedChannelTypeDisplay];
        channelFindType = @"FEED";
    }
    else
    {
        [self prepareSearchQueryString];
        //NSString *querySearchFeedId = @"";
        [self launchYoutubeAPIChannelSearchQuery];
        currentSearchInfoLabel.text = [NSString stringWithFormat:@"%@ %@: %@",ls.eZ_CHANNEL,ls.eZ_SEARCH,channelSearchQueryString];
        //keywordField.text = @"";
        channelFindType = @"SEARCH";
    }
     
    
}

- (IBAction)showPrevious:(id)sender {
    
    [self channelFeedActive];
    
    if(start_index > max_results)
        start_index = start_index-max_results;
    else 
    {
        start_index = 1;
    }
    
    NSString * queryFeedID = [self giveFeedIdForStartIndex:start_index];
    
    if([channelFindType isEqualToString:@"FEED"])
    {
        [self launchYoutubeAPIChannelFeedQuery:queryFeedID];
    }
    else
    {
        [self launchYoutubeAPIChannelSearchQuery];
    }
    
}

- (IBAction)showNext:(id)sender {
    
    
    [self channelFeedActive];
    
    if(start_index < (100 - max_results))
        start_index = start_index+max_results;
    
    NSString * queryFeedID = [self giveFeedIdForStartIndex:start_index];
    
    if([channelFindType isEqualToString:@"FEED"])
    {
        [self launchYoutubeAPIChannelFeedQuery:queryFeedID];
    }
    else
    {
        [self launchYoutubeAPIChannelSearchQuery];
    }
}

#pragma mark - Show specific channel

-(void) showChannelWithChannelId:(NSString *)channelId
{
    
    //Add channel to Array.
    //Clear old results
    [channelResultsArray removeAllObjects];
    NSDictionary * row = [[NSDictionary alloc] initWithObjectsAndKeys:
                          channelId,@"channelName",
                          channelId,@"channelTitle",
                          @"",@"thumbURL",
                          nil,@"thumbImg",
                          @"",@"videoCount",
                          0,@"videoCountInt",
                          0,@"totalUploadViewCount",
                          nil];
    
    
    [channelResultsArray addObject:row];

    [self refreshChannelResults];
    //[self displayChannelsHeader];
    [self channelFeedComplete];
    
    
}

#pragma mark - Show specific channel

-(void) showChannelWithChannelId:(NSString *)channelId startIndex:(int)startIndex
{
    
    //Add channel to Array.
    //Clear old results
    [channelResultsArray removeAllObjects];
    NSDictionary * row = [[NSDictionary alloc] initWithObjectsAndKeys:
                          channelId,@"channelName",
                          channelId,@"channelTitle",
                          @"",@"thumbURL",
                          nil,@"thumbImg",
                          @"",@"videoCount",
                          0,@"videoCountInt",
                          0,@"totalUploadViewCount",
                          nil];
    
    
    [channelResultsArray addObject:row];
    
    [self refreshChannelResults];
   
    [channelVideosVC loadBasicChannelInfo:row];
    [channelVideosVC downloadChannelVideosFromIndex:startIndex];
    
    
}

#pragma mark - Launch Channel Feed Query

-(void) launchYoutubeAPIChannelFeedQuery:(NSString *)queryFeedID
{
    
    NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForChannelStandardFeedID:queryFeedID];
    //youTubeURLForChannelsFeeds
    //NSLog(@"Invoking Feed:%@", queryFeedID);
    
    GDataQueryYouTube * query = [GDataQueryYouTube  youTubeQueryWithFeedURL:feedURL];
    
    
    [youTubeService fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(request:finishedWithFeed:error:)];
    
    
}


#pragma mark - Launch Channel Search Query

-(void) launchYoutubeAPIChannelSearchQuery
{

    NSString * channelSearchString = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/channels?q=%@&start-index=%d&max-results=%d&v=2",channelSearchQueryString,start_index,max_results];
    NSURL *channelSearchURL = [NSURL URLWithString:channelSearchString];
    
    //youTubeURLForChannelsFeeds
    //NSLog(@"Invoking Search:%@", channelSearchString);
    
    GDataQueryYouTube * query = [GDataQueryYouTube  youTubeQueryWithFeedURL:channelSearchURL];
    
    
    [youTubeService fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(request:finishedWithFeed:error:)];
    
    
}

#pragma mark - setup Channels Header

-(void) displayChannelsHeader{
    
    //Show Hide Prev
    if(start_index > max_results )
        [prevButton setHidden:NO];
    else
        [prevButton setHidden:YES];
            
    //Show Hide Next
    if(results_returned == max_results && start_index < (100 - max_results))
        [nextButton setHidden:NO];
    else
        [nextButton setHidden:YES];
    
            
            
    //Show Start-Index, End-Index
    if(channelResultsArray.count > 0)
        showingResultsLabel.text = [NSString stringWithFormat:@"(%d-%d)",start_index,(start_index+channelResultsArray.count-1)];
    else
     showingResultsLabel.text = ls.eZ_NO_CHANNELS;
        
    
}



#pragma mark - Add Channel

-(void) addNewVideoSourceRecord:(NSMutableDictionary *)videoSource
{

    [self.delegate addNewVideoSourceRecord:videoSource informAboutFeeds:YES];
    
}





#pragma mark - GData Youtube Data Feed returned


- (void)request:(GDataServiceTicket *)ticket
finishedWithFeed:(GDataFeedBase *)aFeed
          error:(NSError *)error 
{
    results_returned = 0;
    //NSLog(@"-Download from GData complete");
    
    //NSManagedObjectContext * moc = [self.managedObjectContext copy];
    
	if(!error)
    {
    
        if ([currentYoutubeAPISearchType isEqualToString:@"CHANNELS"] || [currentYoutubeAPISearchType isEqualToString:@"CHANNEL_INITIAL_LOAD"]) 
        {
        
                                //Clear old results
                                [channelResultsArray removeAllObjects];
                                
                                GDataFeedYouTubeChannel * channelFeed = (GDataFeedYouTubeChannel *)aFeed;
                                int i =1;
                                for (id feedEntry in [channelFeed entries]) 
                                {
                                    GDataEntryYouTubeChannel * chanelEntry = (GDataEntryYouTubeChannel *)feedEntry;
                                    results_returned ++;
                                    
                      
                                    
                                    
                                    
                                    //NSLog(@"%d.Channel:--------------------------------->%@",i++,[chanelEntry itemsForDescription]);
                                    
                                
                                    GDataXMLDocument * xmlDocument = (GDataXMLDocument *)[chanelEntry XMLDocument];
                                    //NSLog(@"Description:%@",[xmlDocument rootElement].description );
                                    GDataXMLElement * rootXMLElement = (GDataXMLElement *)[xmlDocument rootElement] ;
                                    //NSArray *channelName = [rootXMLElement nodesForXPath:@"//entry/title" error:nil];
                                    //NSLog(@"Title:%@",[channelName objectAtIndex:0]);
                                    
                                    NSString * channelTitle = @"";
                                    NSString * channelName = @"";
                                    NSString * videoCount = @"";
                                    NSNumber * videoCountInt = [NSNumber numberWithInt:0];
                                    NSString * thumbURLString = @"";
                                    UIImage * thumbImg;// = [[UIImage alloc] init] ;
                                    //NSString * subscriberCount = @"";
                                    NSString * totalUploadViewCount = @"";
                                    
                                    //Find Name/userid
                                    
                                    //NSLog(@"AuthorArray:%@",chanelEntry.authors);
                                    
                                    GDataAtomAuthor * channelAuthor =[chanelEntry.authors objectAtIndex:0];
                                    //NSLog(@"----------------->AuthorName:%@",channelAuthor.name);
                                    channelName = channelAuthor.name;
                                 
                                    
                                    
                                    
                                    //Find Title
                                    NSArray *titles = [rootXMLElement elementsForName:@"title"];
                                    if (titles.count > 0) {
                                        GDataXMLElement *title = (GDataXMLElement *) [titles objectAtIndex:0];
                                        channelTitle = title.stringValue;
                                    } //else continue;
                                    
                                    
                                    //NSLog(@"channel Num:%d,  Channel Title:%@",i,channelTitle);
                                    i++;
                                    
                                    //Find Title
                                    NSArray *mediagroups = [rootXMLElement elementsForName:@"media:group"];
                                    if (mediagroups.count > 0) 
                                    {
                                        GDataXMLElement *mediagroup = (GDataXMLElement *)[mediagroups objectAtIndex:0];
                                        //NSLog(@"mediagroup:%@",mediagroup);
                                        
                                         NSArray *mediathumbnails = [mediagroup elementsForName:@"media:thumbnail"];
                                         if (mediathumbnails.count > 0) 
                                         {
                                             GDataXMLElement *mediathumbnail = (GDataXMLElement *) [mediathumbnails objectAtIndex:0];
                                             //NSLog(@"------>mediathumbnail:%@",mediathumbnail);
                                             
                                              NSArray * attributes = mediathumbnail.attributes;
                                             for (GDataXMLNode * attribute in attributes) 
                                             {
                                                 if([attribute.name isEqualToString:@"url"])
                                                 {
                                                     thumbURLString = attribute.stringValue;
                                                     ////thumbURLString = @"//i4.ytimg.com/i/_gE-kg7JvuwCNlbZ1-shlA/1.jpg?v=d81d40";
                                                     if([[thumbURLString substringToIndex:4] isEqualToString:@"http"])
                                                     {
                                                         //thumbURLString = attribute.stringValue;
                                                     }
                                                     else 
                                                     {
                                                         thumbURLString = [NSString stringWithFormat:@"http:%@", thumbURLString];
                                                     }
                                            
                                                     //NSLog(@"ThumbNail: %@",thumbURLString);
                                                     thumbImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbURLString]]];
                                                     
                                                 }
                                                
                                             }

                                             
                                         }
                                         
                                        
                                    }
                                    else 
                                    {
                                        thumbImg = [UIImage imageNamed:@"blankImage.png"];
                                    }//else continue;
                                    
                                    //NSLog(@"Channel Title:%@",channelTitle);
                               
                                    
                                    
                                    //Find videosCount,totalUploadViewCount-- yt:channelStatistics
                                    NSArray *statistics = [rootXMLElement elementsForName:@"yt:channelStatistics"];
                                   if (statistics.count > 0) 
                                   {
                                       GDataXMLElement *statistic = (GDataXMLElement *) [statistics objectAtIndex:0];
                                       NSArray * attributes = statistic.attributes;
                                       //NSLog(@"Channel Statistics:%@",attributes);
                                       for (GDataXMLNode * attribute in attributes) 
                                       {
                                           if([attribute.name isEqualToString:@"videoCount"])
                                           {
                                               
                                               videoCount = attribute.stringValue;
                                               videoCountInt =[NSNumber numberWithInt:[videoCount intValue]];
                                               
                                           }
                                           else if([attribute.name isEqualToString:@"totalUploadViewCount"])
                                           {
                                               
                                               totalUploadViewCount = attribute.stringValue;
                                               
                                           }
                                           
                                       
                                       }
                                       
                                   } //else continue;
                                   
                                    //NSLog(@"Videos Count:%@",videoCount);
                                    //NSLog(@"Upload Views:%@",totalUploadViewCount);
                                    if([videoCount isEqualToString:@""] || ([videoCount intValue] >= channelShow_videoLimit))
                                    {
                                        //NSLog(@"--%@",channelName);
                                        if(![bannedChannels objectForKey:[channelName lowercaseString]])

                                        {
                                            NSDictionary * row ;
                                           
                                            row = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                        channelName,@"channelName",
                                                                        channelTitle,@"channelTitle",
                                                                        thumbURLString,@"thumbURL",
                                                                        thumbImg,@"thumbImg",
                                                                        videoCount,@"videoCount",
                                                                        videoCountInt,@"videoCountInt",
                                                                        totalUploadViewCount,@"totalUploadViewCount",
                                                                        nil];
                                                                                    
                                            [channelResultsArray addObject:row];
                                            [row autorelease];
                                        }
                                    }
                                    
                                }//End For loop
            
                    if ([currentYoutubeAPISearchType isEqualToString:@"CHANNELS"]) 
                    {
                        [self refreshChannelResults];
                        [self displayChannelsHeader];
                    }
                    else if([currentYoutubeAPISearchType isEqualToString:@"CHANNEL_INITIAL_LOAD"])
                    {
                        [self saveTopTenChannels:channelResultsArray];
                        
                        
                        
                    }

            }//End CHANNEL FEED
        
        }//End if error
    else
    {
        if ([currentYoutubeAPISearchType isEqualToString:@"CHANNELS"]) 
        {
                //Log error
                 //NSLog(@"Downloaded GData has errors. ERROR DEscription:--->  %@",error.description);
                if([error.domain isEqualToString:@"NSURLErrorDomain"])
                {
                    //NSLog(@"Error code:%d",error.code);
                    if(error.code == -1009 || error.code == -1004 || error.code == -1001)
                    {
                        showingResultsLabel.text = ls.eZ_NO_INTERNET;
                        [prevButton setHidden:YES];
                        [nextButton setHidden:YES];
                    }
                }
        }
        else if([currentYoutubeAPISearchType isEqualToString:@"CHANNEL_INITIAL_LOAD"])
        {
            [self.delegate channelPopulationErroredOut];
        }
        
    }
    
    if ([currentYoutubeAPISearchType isEqualToString:@"CHANNELS"]) 
    {
        [self channelFeedComplete];
        [self videoFeedComplete];
    }

    
}


#pragma mark - populate Channel Results

-(void)refreshChannelResults
{
    
    [channelsTableView reloadData];
    if(channelResultsArray.count >0)
    {
        [channelsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        //[self showVideosforChannelRowAtIndex:0];
    }
    
    
}

#pragma mark - populate Video Results

-(void)showVideosforChannelRowAtIndex:(int)rowNum;
{
    
    if ([currentYoutubeAPISearchType isEqualToString:@"NONE"]) 
    {
        [self videoFeedActive];
        
        
        if(channelResultsArray.count > 0 && channelResultsArray.count-1 >= rowNum)
        {
            NSDictionary * row = [channelResultsArray objectAtIndex:rowNum];
            [channelVideosVC loadBasicChannelInfo:row];
            [channelVideosVC downloadChannelVideos];
        }
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.

	
    return channelResultsArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //static NSString *CellIdentifier = @"ChannelNameSearch";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:channelFindType];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:channelFindType] autorelease];
    }
    
    NSDictionary * row = [channelResultsArray objectAtIndex:indexPath.row];
    

    
    if([channelFindType isEqualToString:@"FEED"])
    {
        //cell.textLabel.text  = [NSString stringWithFormat:@"%d.%@",indexPath.row+1,[row objectForKey:@"channelName"]];  //@"Name";
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text  = [NSString stringWithFormat:@"%d.%@(%@)",indexPath.row+start_index,[row objectForKey:@"channelName"],[row objectForKey:@"channelTitle"]];//@"Title";
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@, %@: %@",ls.eZ_VIDEOS,[row objectForKey:@"videoCount"],ls.eZ_VIEWS,[row objectForKey:@"totalUploadViewCount"]];
        UIImage * thumbImg = [row objectForKey:@"thumbImg"];
        //[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[row objectForKey:@"thumbURL"]]]];
        // = CGSizeMake(44.0, 44.0)
        cell.imageView.backgroundColor = [UIColor blackColor];
        cell.imageView.image = thumbImg;
        /*
         [UIImage imageWithCGImage:[thumbImg CGImage] scale:0.5 orientation:thumbImg.imageOrientation];
        [cell.imageView sizeToFit];
         */
    }
    else
    {
        
        //cell.textLabel.text  = [NSString stringWithFormat:@"%d.%@",indexPath.row+1,[row objectForKey:@"channelName"]];  //@"Name";
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text  = [NSString stringWithFormat:@"%d.%@",indexPath.row+start_index,[row objectForKey:@"channelName"]];//@"Title";
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@)",[row objectForKey:@"channelTitle"]];
        
    }
    
    
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    
    if ([currentYoutubeAPISearchType isEqualToString:@"NONE"]) 
    {
        [self videoFeedActive];
        
        NSDictionary * row = [channelResultsArray objectAtIndex:indexPath.row];
        [channelVideosVC loadBasicChannelInfo:row];
        [channelVideosVC downloadChannelVideos];
    }
    
    */

    [self showVideosforChannelRowAtIndex:indexPath.row];
    
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([channelFindType isEqualToString:@"FEED"])
    {
        return 60;
    }
    else
    {
        return 45;
    }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark - Lock Unlock buttons during API Call
-(void) channelFeedActive
{
    //Set CurrentFeed Return Type
    currentYoutubeAPISearchType = @"CHANNELS";
    
    //Disable Buttons
    [findChannelsButton setEnabled:NO];
    [prevButton setEnabled:NO];
    [nextButton setEnabled:NO];
    [spinButton setEnabled:NO];
    [searchButton setEnabled:NO];
    [channelsTableView setUserInteractionEnabled:NO];
    
    
    //Hide items
    [showingResultsLabel setHidden:YES];
    
    
    
    //Start ChannelFeed Activity Indicator
    [channelFeedActivityIndicator startAnimating];
    
    
    //Enable buttons after certain time
    aTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                              target:self 
                                            selector:@selector(channelFeedCompleteTimedOut) 
                                            userInfo:nil 
                                             repeats:NO];
}


-(void) channelFeedComplete
{
    //Set CurrentFeed Return Type
    currentYoutubeAPISearchType = @"NONE";
    
    //Enable Buttons
    [findChannelsButton setEnabled:YES];
    [prevButton setEnabled:YES];
    [nextButton setEnabled:YES];
    [spinButton setEnabled:YES];
    [searchButton setEnabled:YES];
     [channelsTableView setUserInteractionEnabled:YES];
    
    
    //show items
    [showingResultsLabel setHidden:NO];
    
    
    //Stop ChannelFeed Activity Indicator
    [channelFeedActivityIndicator stopAnimating];
    
    //Download videos of first channel
    if(channelResultsArray.count >0)
    {
        [self.channelsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self showVideosforChannelRowAtIndex:0];
    }
    
    //Scroll to bottom
    //[(UIScrollView *)self.view scrollRectToVisible:CGRectMake(0, 216, 1024, 768) animated:YES];

}

-(void) channelFeedCompleteTimedOut
{
    //NSLog(@"channelFeedCompleteTimedOut");
    //Enable Buttons
    [findChannelsButton setEnabled:YES];
    [prevButton setEnabled:YES];
    [nextButton setEnabled:YES];
    [spinButton setEnabled:YES];
    [searchButton setEnabled:YES];
    [channelsTableView setUserInteractionEnabled:YES];
    

}


-(void) videoFeedActive
{
    //Set CurrentFeed Return Type
    currentYoutubeAPISearchType = @"VIDEOS";
    
    //Disable Buttons
    //[findChannelsButton setEnabled:NO];
    [prevButton setEnabled:NO];
    [nextButton setEnabled:NO];
    [channelsTableView setUserInteractionEnabled:NO];
   
    
}


-(void) videoFeedComplete
{
    
    //Set CurrentFeed Return Type
    currentYoutubeAPISearchType = @"NONE";
    
    //Enable Buttons
    //[findChannelsButton setEnabled:YES];
    [prevButton setEnabled:YES];
    [nextButton setEnabled:YES];
    [channelsTableView setUserInteractionEnabled:YES];
    
}

#pragma mark - Clear Channel Videos

-(void) clearCurrentChannelVideos
{
    [channelResultsArray removeAllObjects];
    [self.channelVideosVC.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.channelVideosVC.channelVideoResultsArray removeAllObjects];
    [self.channelVideosVC.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 750, 518) animated:YES];
    [channelsTableView reloadData];
    [self.channelVideosVC clearChannelHeaderInfo];
    showingResultsLabel.text = @"";
    currentSearchInfoLabel.text = @"";
}


#pragma mark - ChannelVideosVC Delegate
-(void) channelVideosDownloadComplete
{
    [self videoFeedComplete];
}
    

#pragma mark - Playing Video in popup, Enter, Exit Full Screen

-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId;
{
    
    //[self.delegate popVideo:videoId title:title channelId:channelIdSent];
    
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

-(void) popVideo:(NSString *)videoId title:(NSString *)title;
{
    
    //[self.delegate popVideo:videoId title:title];
    
    self.videoViewController.videoId = videoId;
    self.videoViewController.videoTitle = title;
    self.videoViewController.channelId = @"";
    //self.videoViewController.playerType = self.currentPlayer;
    
    
    
    popOver = [[UIPopoverController alloc]initWithContentViewController:videoViewController];
    //[videoViewController release];
    
    
    CGRect popRect = CGRectMake(384,70,160,60);
    
    popOver.delegate = self;
    
    videoEnteredFullScreen1 = NO;
    
    [popOver presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [self.videoViewController loadVideo];

    
}

-(void) loadAllVideosInExternalPlayerWithVideoSetArray:(NSArray*)videoSetArray  feedChannelInfo:(NSDictionary *)feed_OR_Channel_info StartingWithVideoIndex:(int)index
{
    
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
            //[((TSVideoViewController *)popover.contentViewController).webView loadHTMLString:@"<body bgcolor=black></body>" baseURL:nil];
            [((TSVideoViewController *)popover.contentViewController) clearVideo];
            //popover.contentViewController = nil;
            //[videoViewController release];
        }
    }
    return YES;  
}

    
- (void)dealloc {
    AudioServicesDisposeSystemSoundID(audioEffect);
    
    [channelsTableView release];
    [pickerView release];
    [prevButton release];
    [nextButton release];
    [keywordField release];
    [showingResultsLabel release];
    [currentSearchInfoLabel release];
    [findChannelsButton release];
    [channelFeedActivityIndicator release];

    [feedTypeButton release];
    [feedPeriodButton release];
    [feedCountryButton release];
    [feedCategoryButton release];
  
    [spinButton release];
    [searchButton release];
    [orLbl release];
    [keywordSearchLbl release];
    [super dealloc];
}

@end
