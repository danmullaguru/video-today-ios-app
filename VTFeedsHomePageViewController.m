//
//  EZFeedsHomePageViewController.m
//  EZ Tube
//
//  Created by dan mullaguru on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VTFeedsHomePageViewController.h"

@interface VTFeedsHomePageViewController()
{
    BOOL videoEnteredFullScreen4;
}

- (void)configureCell:(EZFeedsTableCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void) videoFeedActive;
-(void) videoFeedComplete;
-(void) refreshVideoResults;
-(void) launchYoutubeAPIVideoFeedQuery:(NSString *)feedURLString startIndex:(int)startIndex maxResults:(int)maxResults;
-(void) launchYoutubeAPIVideoSearchQuery:(NSString *)queryURLString startIndex:(int)startIndex maxResults:(int)maxResults;
-(void) refreshFeedList;
-(void) setPageControl:(int)videosPerPage;
-(void) setFeedsScrollViewContentSize;
-(void) deselectAllRowsTable:(UITableView *)table;
-(void) loadFeedImagesDictionary;

-(void) layoutVideoscrowded;
-(void) layoutVideosSpreadOut;
-(void) downloadPendingImages;
-(void) ifVideoEmptyLoadFirstFromFeed;
-(void) showUpDownArrows;

-(void) reframeExistingVideosSpreadOut;
-(void) reframeExistingVideosCrowded;

//-(void) handlePinchVideos:(UIPinchGestureRecognizer *)gr;
-(void) handleSwipeUpVideos:(UISwipeGestureRecognizer *)gr;
-(void) handleSwipeDownVideos:(UISwipeGestureRecognizer *)gr;

//-(void) handlePinchFeeds:(UIPinchGestureRecognizer *)gr;
-(void) highlightFeedName:(int)actualRow;
-(void) moveFeedListScrollViewToFeed:(int)feedNum;

@end

@implementation VTFeedsHomePageViewController
@synthesize feedSearchButton;
@synthesize feedManageButton;

@synthesize ls;
@synthesize upButton;
@synthesize downButton;

@synthesize currentFeedCountryImage;
@synthesize currentFeedCategoryImage;

@synthesize feedHeaderView;
@synthesize feedsPageControl;
@synthesize feedsLbl;


@synthesize feedFlagsImagesDictionary;
@synthesize feedCategoriesImagesDictionary;

@synthesize start_index;
@synthesize max_results;
@synthesize currentSelectedFeedActualRow;
@synthesize videoToShowNum;
@synthesize feedType;
@synthesize feedURL;

@synthesize delegate;
@synthesize feedVideoResultsArray;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize feedsTableView;

@synthesize videosScrollView = _videosScrollView;
@synthesize videoViewController;
@synthesize videoFeedDownloadQueue;
@synthesize selectedFeedLbl;
@synthesize reLayoutNeeded;
@synthesize VideosDownloadIndicator;
@synthesize prevButton;
@synthesize nextButton;
@synthesize videoStartEndLbl;
@synthesize feedsScrollView;
static NSString *CellClassName = @"EZFeedsTableCell";
UIPopoverController * popOver;

GDataServiceGoogleYouTube *youTubeService;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
     cellLoader = [[UINib nibWithNibName:CellClassName bundle:[NSBundle mainBundle]] retain];
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
    [self loadFeedImagesDictionary];
    
    // Do any additional setup after loading the view from its nib.
    youTubeService = [[TSDownloadManager sharedInstance] youTubeService];
    feedVideoResultsArray = [[NSMutableArray alloc]init];
    dispatch_queue_t videoDownloadQueue = dispatch_queue_create("com.eztube.HomePageVideoFeed", NULL);
    self.videoFeedDownloadQueue = videoDownloadQueue;
     self.reLayoutNeeded = NO;
    [self setVCtoCurrentLanguage];
    
    [self setFeedsScrollViewContentSize];
    
    //VideoPlayer added in app delegate
    //self.videoViewController = [[TSVideoViewController alloc] initWithNibName:@"TSVideoViewController" bundle:nil];

    self.currentSelectedFeedActualRow = -1;
    self.videoToShowNum = -1;
    
    
    //Add pinch gesture for videos Scroll View
    UIPinchGestureRecognizer* pinchVideos = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchVideos:)];
    [self.videosScrollView addGestureRecognizer: pinchVideos];
    [pinchVideos release];
    
    //Add Swipe Up gesture for videos Scroll View
    UISwipeGestureRecognizer* swipeUpVideos = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpVideos:)];
    [swipeUpVideos setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.videosScrollView addGestureRecognizer: swipeUpVideos];
    [swipeUpVideos release];
    
    //Add Swipe Down gesture for videos Scroll View
    UISwipeGestureRecognizer* swipeDownVideos = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownVideos:)];
    [swipeDownVideos setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.videosScrollView addGestureRecognizer: swipeDownVideos];
    [swipeDownVideos release];
    
    //Add pinch gesture for feeds Scroll View
    UIPinchGestureRecognizer* pinchFeeds = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFeeds:)];
    [self.feedsScrollView addGestureRecognizer: pinchFeeds];
    [pinchFeeds release];
    
        
    
    
}

#pragma mark - Handle VideosScrollView Gestures



-(void) handleSwipeUpVideos:(UISwipeGestureRecognizer *)gr {
    //NSLog(@"handleSwipeUp");

    
     if([gr state] == UIGestureRecognizerStateEnded && (! VideosDownloadIndicator.isAnimating)) 
    {
        //NSLog(@"Swipe Up Ended");
        
        //if next feed exists, go to next feed
        
        int feedCount = self.fetchedResultsController.fetchedObjects.count;
        
        if(self.currentSelectedFeedActualRow < feedCount-1)
        {
            [self highlightFeedName:self.currentSelectedFeedActualRow+1];
            [self showVideosForRow:self.currentSelectedFeedActualRow + 1];
        }

   
	}
     
    
}

-(void) handleSwipeDownVideos:(UISwipeGestureRecognizer *)gr {
    //NSLog(@"handleSwipeDown");
    
    
    if([gr state] == UIGestureRecognizerStateEnded&& (! VideosDownloadIndicator.isAnimating)) 
    {
        //NSLog(@"Swipe Down Ended");

        
        //if previous feed exists, go to previous feed
        
        if(self.currentSelectedFeedActualRow >0)
        {
            [self highlightFeedName:self.currentSelectedFeedActualRow-1];
            [self showVideosForRow:self.currentSelectedFeedActualRow - 1];
        }
        
	}
    
    
}

#pragma mark - Handle VideosScrollView Gestures






-(void) viewDidAppear:(BOOL)animated
{
    
    [self downloadPendingImages];
    [self ifVideoEmptyLoadFirstFromFeed];
}

-(void) initializeViewsIfNotYet
{
    //Is feed record count atleast 1
    int feedsCount = self.fetchedResultsController.fetchedObjects.count;
    
    //NSLog(@"Feed Count: %d",feedsCount);
    
    if(feedsCount > 0)
    {
    
    
            //currentSelectedFeedActualRow > -1 (default is -1)
        
            if(self.currentSelectedFeedActualRow == -1)
            {
                        //....Load first row of existing feeds
                        //if (-1) load first (actual) row of the feed...(Row shall be selectes in Red)
                [self showVideosForRow:0];
                [self.feedsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0 ] animated:YES scrollPosition:UITableViewScrollPositionTop];
               

                            
            }
    
    }

    
}


-(void) ifVideoEmptyLoadFirstFromFeed
{

    //Is VideoId exists for VideoController?
    //if not,does feed exist in array "feedVideoResultsArray"?
    // then , loadVideo of the VideoController with the first row of the feed videos returned.
    if([self.videoViewController.videoId isEqualToString:@""])
    {
        if(feedVideoResultsArray.count > 0)
        {
            
            NSDictionary * firstrow = [feedVideoResultsArray objectAtIndex:0];
            
            [self loadVideoInPage:[firstrow objectForKey:@"videoId"] title:[firstrow objectForKey:@"videoTitle"] channelId:[firstrow objectForKey:@"channelId"] videoSeqNum:1 ];
            self.videoToShowNum = -1;
        }
    }
    
}


-(void) showUpDownArrows
{
    
    int feedCount = self.fetchedResultsController.fetchedObjects.count;
    
    if(self.currentSelectedFeedActualRow >0)
    {
        //[self.downButton setHidden:NO];
    }
    else 
    {
        //[self.downButton setHidden:YES];
    }
    
    if(self.currentSelectedFeedActualRow < feedCount-1)
    {
        //[self.upButton setHidden:NO];
    }
    else 
    {
        //[self.upButton setHidden:YES];
    }
    
}

-(void) setVCtoCurrentLanguage
{
    
    feedsLbl.text  = ls.eZ_FEEDS;
    
    //feed search button in local language
    UIImage *top_search_default_img = [[UIImage alloc] initWithContentsOfFile:ls.top_search_default_path ];
    if(!top_search_default_img)
    {
        top_search_default_img = [[UIImage alloc] initWithContentsOfFile:ls.top_share_mainBundle_path];
    }
    
    UIImage *top_search_active_img = [[UIImage alloc] initWithContentsOfFile:ls.top_search_active_path ];
    if(!top_search_active_img)
    {
        top_search_active_img = [[UIImage alloc] initWithContentsOfFile:ls.top_search_active_mainBundle_path];
    }
    
    
    [self.feedSearchButton setImage:top_search_default_img forState:UIControlStateNormal];
    [self.feedSearchButton setImage:top_search_active_img forState:UIControlStateHighlighted];
    [self.feedSearchButton setImage:top_search_active_img forState:UIControlStateSelected];
    
   
    
    [top_search_default_img release];
    [top_search_active_img release];
    
    
    //manage feeds button in local language
    UIImage *top_manage_img = [[UIImage alloc] initWithContentsOfFile:ls.top_manage_path ];
    if(!top_manage_img)
    {
        top_manage_img = [[UIImage alloc] initWithContentsOfFile:ls.top_manage_mainBundle_path];
    }
    
    
    [feedManageButton setImage:top_manage_img forState:UIControlStateNormal];
    
    [top_manage_img release];
    
    
    
    [self refreshFeedList];
    //[self showVideosForRow:0];
    
}

- (void)viewDidUnload
{
    [self setFeedsTableView:nil];
    [self setVideosScrollView:nil];
    [self setSelectedFeedLbl:nil];
    [self setVideosDownloadIndicator:nil];
    [self setPrevButton:nil];
    [self setNextButton:nil];
    [self setVideoStartEndLbl:nil];
    [self setFeedsLbl:nil];
    [self setFeedsPageControl:nil];

    [self setFeedsScrollView:nil];
    [self setCurrentFeedCountryImage:nil];
    [self setCurrentFeedCategoryImage:nil];

    [self setFeedHeaderView:nil];

    [self setUpButton:nil];
    [self setDownButton:nil];
    [self setFeedSearchButton:nil];
    [self setFeedManageButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	//return YES;
     return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
     [cellLoader release];
    [feedsTableView release];
    [_videosScrollView release];
    [selectedFeedLbl release];
    [VideosDownloadIndicator release];
    [prevButton release];
    [nextButton release];
    [videoStartEndLbl release];
    [feedsLbl release];
    [feedsPageControl release];

    [feedsScrollView release];
    [currentFeedCountryImage release];
    [currentFeedCategoryImage release];

    [feedHeaderView release];
 
    [upButton release];
    [downButton release];
    
    [feedSearchButton release];
    [feedManageButton release];
    [super dealloc];
}


-(void) loadFeedImagesDictionary
{
    //Load Country Flags Images
    
    NSArray * countryFlagImageKeys = [[NSArray alloc] initWithObjects: @"All Countries",@"Argentina",@"Australia",@"Brazil",@"Canada",@"Czech Republic",@"France",@"Germany",@"Great Britain",@"Hong Kong",@"India",@"Ireland",@"Israel",@"Italy",@"Japan",@"Mexico",@"Netherlands",@"New Zealand",@"Poland",@"Russia",@"South Africa",@"South Korea",@"Spain",@"Sweden",@"Taiwan",@"United States", nil];
    
    NSArray * countryFlagImages = [[NSArray alloc] initWithObjects: 
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
    
    
    feedFlagsImagesDictionary = [[NSDictionary alloc]initWithObjects:countryFlagImages forKeys:countryFlagImageKeys];
    
    [countryFlagImageKeys release];
    [countryFlagImages release];
    
    
    //Load Feed Categories Images
    
    NSArray * feedCategoriesImageKeys =  [[NSArray alloc] initWithObjects:@"All Categories",@"Film",@"Autos",@"Music",@"Animals",@"Sports",@"Travel",@"Games",@"Comedy",@"People",@"News",@"Entertainment",@"Education",@"How to",@"Non profit",@"Technology", nil];
    

    
    NSArray * feedCategoriesImages =  [[NSArray alloc] initWithObjects: 
                                       [UIImage imageNamed:@"all.png"],
                                       [UIImage imageNamed:@"film.png"],
                                       [UIImage imageNamed:@"autos.png"],
                                       [UIImage imageNamed:@"music.png"],
                                       [UIImage imageNamed:@"animals.png"],
                                       [UIImage imageNamed:@"sports.png"],
                                       [UIImage imageNamed:@"travel.png"],
                                       [UIImage imageNamed:@"games.png"],
                                       [UIImage imageNamed:@"comedy.png"],
                                       [UIImage imageNamed:@"people.png"],
                                       [UIImage imageNamed:@"news.png"],
                                       [UIImage imageNamed:@"entertainment.png"],
                                       [UIImage imageNamed:@"education.png"],
                                       [UIImage imageNamed:@"howto.png"],
                                       [UIImage imageNamed:@"nonprofit.png"],
                                       [UIImage imageNamed:@"technology.png"],
                                       nil];
    
    feedCategoriesImagesDictionary = [[NSDictionary alloc]initWithObjects:feedCategoriesImages forKeys:feedCategoriesImageKeys];
    [feedCategoriesImageKeys release];
    [feedCategoriesImages release];
}




#pragma mark - Table datafeed delegate methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

/*
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
 
 NSArray * sectionTitles = [NSArray arrayWithObject:@"Channels"];
 return sectionTitles;
 }
 */


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
     //NSLog(@"Num of Feeds:%d", [sectionInfo numberOfObjects]);
    
    NSUInteger numOfItemsReturned = [sectionInfo numberOfObjects];

    
    return numOfItemsReturned;
    
    
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"ActiveFeedCell";
    EZFeedsTableCell *cell = (EZFeedsTableCell *)[tableView dequeueReusableCellWithIdentifier:CellClassName];
    
    if (!cell)
    {
        
        NSArray *topLevelItems = [cellLoader instantiateWithOwner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];
        //UIView *bgColorView = [[UIView alloc] init];
        //[bgColorView setBackgroundColor:[UIColor blackColor]];
        //[cell setSelectedBackgroundView:bgColorView];
        //[bgColorView release];
    }
    
    /*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    */
 
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(EZFeedsTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    

    Feed *feedObject = (Feed *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    //NSLog(@"Localized Feed:%@", [managedObject giveDisplayNameLocalized] );
    //cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.feedNameLbl.text =  [NSString stringWithFormat:@"%d.%@",indexPath.row+1,[feedObject giveDisplayNameLocalizedSmall]];
    
    //[cell.feedNameLbl setNumberOfLines:2];
    //[cell.feedNameLbl sizeToFit];
    

    
    if([feedObject.feed_OR_search isEqualToString:@"FEED"])
    {
        //NSLog(@"Country:%@",managedObject.feedRegion);
        cell.feedFlagImageView.image = [feedFlagsImagesDictionary objectForKey:feedObject.feedRegion];
        //NSLog(@"Country:%@",managedObject.feedCategory);
        cell.feedCategoryImageView.image = [feedCategoriesImagesDictionary objectForKey:feedObject.feedCategory];
    }
    else 
    {
        cell.feedFlagImageView.image = nil;
        cell.feedCategoryImageView.image = [UIImage imageNamed:@"searchIcon.png"];
        
    }
    
    //cell.detailTextLabel.textColor = [UIColor blackColor];
    //cell.detailTextLabel.text = [managedObject valueForKey:@"feedURL"];
    
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    
}




- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    /*
     if (indexPath.row == 0 || indexPath.row ==1) {
     return NO;
     }
     */
    return YES;
}




#pragma mark - TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   /*
    Feed *feedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedFeedLbl.text = feedObject.displayName;
    //[self pushEditVideoFeed:(Feed *)feedObject];
    NSLog(@"Feed URL:%@",feedObject.feedURL);
    if([feedObject.feed_OR_search isEqualToString:@"FEED"])
    {
         [self.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self launchYoutubeAPIVideoFeedQuery:feedObject.feedURL startIndex:1 maxResults:27];
    }
    else
    {
         [self.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self launchYoutubeAPIVideoSearchQuery:feedObject.feedURL startIndex:1 maxResults:27];
        
    }
    */

        //NSLog(@"From TableView didSelectRowAtIndexPath");
    
    [self moveFeedListScrollViewToFeed:indexPath.row];

        [self showVideosForRow:indexPath.row];

   
    
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 110.0f;
}

-(void) deselectAllRowsTable:(UITableView *)table
{
    
    for (int i =0; i<[table numberOfRowsInSection:0]; i++) {
        [table deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
    }
    
}

#pragma mark - show videos for row

-(void) showVideosForRow:(int)rowNum
{
    
    start_index = 1;
    max_results = 50;
    
    int rowCount = self.fetchedResultsController.fetchedObjects.count;
    if(rowCount > 0 && rowCount>rowNum)
    {
        Feed *feedObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:rowNum inSection:0]];
        if(feedObject)
        {
                self.selectedFeedLbl.text = [NSString stringWithFormat:@"%d.%@",rowNum+1,[feedObject giveDisplayNameLocalized]];
                self.currentSelectedFeedActualRow = rowNum;
                [self showUpDownArrows];
            
                self.feedURL = feedObject.feedURL;
                //[self pushEditVideoFeed:(Feed *)feedObject];
                //NSLog(@"Feed URL:%@",feedObject.feedURL);
                if([feedObject.feed_OR_search isEqualToString:@"FEED"])
                {
                    feedType = @"FEED";
                    currentFeedCountryImage.image = [feedFlagsImagesDictionary objectForKey:feedObject.feedRegion];
                    currentFeedCategoryImage.image = [feedCategoriesImagesDictionary objectForKey:feedObject.feedCategory];
                    
                    [self.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    [self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 765, 602) animated:YES];
                    [self launchYoutubeAPIVideoFeedQuery:feedObject.feedURL startIndex:start_index maxResults:max_results];
                    [self videoFeedActive];
                }
                else
                {
                    feedType = @"SEARCH";

                    currentFeedCountryImage.image = nil;
                    currentFeedCategoryImage.image = [UIImage imageNamed:@"searchIcon.png"];;
                    [self.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    [self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 765, 602) animated:YES];
                    [self launchYoutubeAPIVideoSearchQuery:feedObject.feedURL startIndex:start_index maxResults:max_results];
                    [self videoFeedActive];
                    
                }
        }
        
         
        //[self.feedsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowNum inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
 
    
    
    
}

- (IBAction)showPrevious:(id)sender {
    
    [self.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 765, 602) animated:YES];
    
    
    if(start_index > max_results)
        start_index = start_index-max_results;
    
    if([self.feedType isEqualToString:@"FEED"])
    {
        [self launchYoutubeAPIVideoFeedQuery:self.feedURL startIndex:start_index maxResults:max_results];
    }
    else
    {
        [self launchYoutubeAPIVideoSearchQuery:self.feedURL startIndex:start_index maxResults:max_results ];
    }
    [self videoFeedActive];
}

- (IBAction)showNext:(id)sender {
    
    [self.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 765, 602) animated:YES];
    
    
    if(start_index < (600 - max_results))
        start_index = start_index+max_results;
    
    if([self.feedType isEqualToString:@"FEED"])
    {
        [self launchYoutubeAPIVideoFeedQuery:self.feedURL startIndex:start_index maxResults:max_results];
    }
    else
    {
        [self launchYoutubeAPIVideoSearchQuery:self.feedURL startIndex:start_index maxResults:max_results ];
    }
    [self videoFeedActive];
}

-(void) videoFeedActive
{
    [feedsTableView setUserInteractionEnabled:NO];
    
    //StartActivityIndicator
    [VideosDownloadIndicator startAnimating];

    if(start_index == 1)
    {
        [self.prevButton setHidden:YES];
    }
    else
    {
        [self.prevButton setHidden:NO];
    }
    
    //Disable Buttons
    [prevButton setEnabled:NO];
    [nextButton setEnabled:NO];
    [upButton setEnabled:NO];
    [downButton setEnabled:NO];
    

    
}


-(void) videoFeedComplete
{
    

    //Enable Buttons
    [prevButton setEnabled:YES];
    [nextButton setEnabled:YES];
    [upButton setEnabled:YES];
    [downButton setEnabled:YES];
    
    [feedsTableView setUserInteractionEnabled:YES];
    //StartActivityIndicator
    [VideosDownloadIndicator stopAnimating];
    
    
}

         


#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(isActive = %@)",[NSNumber numberWithBool:YES]];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sourceSite" cacheName:@"ACTIVEFEEDS"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}

-(void) clearCurrentFeedVideos
{
    
    
}

-(void) refreshFeedList
{
    
    //NSLog(@"------Refreshing FeedsList Table -----");
    
    [NSFetchedResultsController deleteCacheWithName:@"ACTIVEFEEDS"];
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.feedsTableView reloadData];     

    
    [self setFeedsScrollViewContentSize];
}


#pragma mark - Launch Channel Feed Query

-(void) launchYoutubeAPIVideoFeedQuery:(NSString *)feedURLString startIndex:(int)startIndex maxResults:(int)maxResults
{
  
    
    //https://gdata.youtube.com/feeds/api/standardfeeds/regionID/feedID_CATEGORY_NAME?v=2
    
    NSURL *feed_URL = [GDataServiceGoogleYouTube youTubeURLForFeedID:feedURLString];
    //youTubeURLForChannelsFeeds
    //NSLog(@"Invoking Feed:%@", feedURLString);
    
    GDataQueryYouTube * query = [GDataQueryYouTube  youTubeQueryWithFeedURL:feed_URL];
    [query setStartIndex:start_index];
    [query setMaxResults:max_results];
    
    [youTubeService fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(request:finishedWithFeed:error:)];
    
    self.videoStartEndLbl.text = [NSString stringWithFormat:@"(%d-%d)",start_index,start_index+max_results-1];
    
}


#pragma mark - Launch Channel Search Query

-(void) launchYoutubeAPIVideoSearchQuery:(NSString *)queryURLString startIndex:(int)startIndex maxResults:(int)maxResults
{
   
    
    /*
     https://gdata.youtube.com/feeds/api/videos?
     q=football+-soccer
     &orderby=published
     &start-index=11
     &max-results=10
     &v=2
     */
    
    //NSString * videoSearchString = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos?q=%@&orderby=%@&start-index=%d&max-results=%d&v=2",videoSearchQueryString,videoSearchSortString,start_index_1,max_results_1];
    NSString * videoSearchURLString = [NSString stringWithFormat:@"%@&start-index=%d&max-results=%d&v=2",queryURLString,startIndex,maxResults];
    NSURL *videoSearchURL = [NSURL URLWithString:videoSearchURLString];
    
    //youTubeURLForChannelsFeeds
    //NSLog(@"Invoking Search:%@", videoSearchURL);
    
    GDataQueryYouTube * query = [GDataQueryYouTube  youTubeQueryWithFeedURL:videoSearchURL];
    
    
    [youTubeService fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(request:finishedWithFeed:error:)];
    
     self.videoStartEndLbl.text = [NSString stringWithFormat:@"(%d-%d)",start_index,start_index+max_results-1];
}



#pragma mark - GData Youtube Data Feed returned

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
                NSArray *thumbnails = [mediaGroup mediaThumbnails];
                NSDate *uploadedDate = [[mediaGroup uploadedDate] date];
                //NSString * dateString = [dateFormatter stringFromDate:uploadedDate];
                NSString * dateString = [ls giveFriendlyDate:uploadedDate];
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
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:EZ_NO_INTERNET message:@"" delegate:self cancelButtonTitle:EZ_OK otherButtonTitles:nil]; 
                [alertView show]; 
                [alertView release]; 
            }
        }
        
    }
    
    
    
    [self videoFeedComplete];
    
}


#pragma mark - populate Channel Results

-(void) refreshVideoResults
{
    
    //NSLog(@"VideoCount while refreshing:%d",feedVideoResultsArray.count);

    float scrollViewWidth = self.videosScrollView.frame.size.width;
    if(scrollViewWidth < 400)
    {
        [self layoutVideoscrowded];
    }
    else 
    {
        [self layoutVideosSpreadOut];
    }
    
    [self ifVideoEmptyLoadFirstFromFeed];
    
}

-(void) layoutVideoscrowded
{
    
    //NSLog(@"VideoCount while refreshing:%d",feedVideoResultsArray.count);
    
    
    
    
    CGRect frame = self.videosScrollView.frame;
    int height = frame.size.height;
    
    
    
    
    int i = 1;
    int x = 0;
    //int xStart = 0;
    int xBuffer = 12;
    int yStart = 8;
    int yBuffer = 8;
    
    float videoCount = feedVideoResultsArray.count;
    //int rowCount = ceil(videoCount / 4.0);
    int pageCount = ceil(videoCount / 8.0);
    int scrollWidth = pageCount * 384;
    if(scrollWidth < 384)
        scrollWidth = 384;
    
    self.videosScrollView.contentSize =  CGSizeMake(scrollWidth, height);
    [self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 384, 642) animated:YES];
    
    
    int videoNum = 0;
    
    
    
    for (NSDictionary * videoRow in feedVideoResultsArray)
    {
        videoNum++;
        
        //Create Video Cell, Set the attributes
        EZFeedDisplayVideoCellView * feedVideoCellView = [[EZFeedDisplayVideoCellView alloc]init];
        
        feedVideoCellView.videoId = [videoRow objectForKey:@"videoId"];
        feedVideoCellView.videoSeqNoInPage = videoNum;
        feedVideoCellView.videoTitle = [videoRow objectForKey:@"videoTitle"];
        feedVideoCellView.channelId = [videoRow objectForKey:@"channelId"];
        feedVideoCellView.videoThumbNailURLString = [videoRow objectForKey:@"videoThumbnailString"];
        feedVideoCellView.videoURL = [videoRow objectForKey:@"videoURL"];
        
        feedVideoCellView.videoTitleLbl.text = [NSString stringWithFormat:@"%d. %@",videoNum+start_index-1,[videoRow objectForKey:@"videoTitle"]];
        feedVideoCellView.videoUploadDateLbl.text = [videoRow objectForKey:@"videoUploadDate"];
        
        [feedVideoCellView setImagedDownloadQueue:self.videoFeedDownloadQueue];
        feedVideoCellView.delegate = self;
        
        //Add Video Cell view as SubView
        CGRect frame = feedVideoCellView.frame;
        frame.origin.x = xBuffer+x;
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
            i = 4;
        else if(i ==4)
        {
            i = 1;
            x += (xBuffer+180);
            
            
            if(xBuffer == 11)
                xBuffer = 12;
            else if(xBuffer == 12)
                xBuffer = 11;
            
        }
    }
    
    [self setPageControl:8];

    
    
}


-(void)layoutVideosSpreadOut
{
    //NSLog(@"VideoCount while refreshing:%d",feedVideoResultsArray.count);
    
    //240 X 180
    //180 X 135
    
    
    
    CGRect frame = self.videosScrollView.frame;
    int height = frame.size.height;
    
    
    
    
    int i = 1;
    int j = 1;
    
    int x = 8;
    //int xStart = 0;
    int xBuffer = 7;
    int yStart = 7;
    int yBuffer = 7;
    
    float videoCount = feedVideoResultsArray.count;
    //int rowCount = ceil(videoCount / 3.0);
    int pageCount = ceil(videoCount / 12.0);
    int scrollWidth = pageCount * 914;
    
    
    if(scrollWidth < 914)
        scrollWidth = 914;
    self.videosScrollView.contentSize =  CGSizeMake(scrollWidth, height);
    
    [self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 914, 582) animated:YES];
    
    int videoNum = 0;
    int videoIndex = 0;
    
    
    for (NSDictionary * videoRow in feedVideoResultsArray)
    {
        videoNum++;
        
        //Create Video Cell, Set the attributes
        EZFeedDisplayVideoCellView * feedVideoCellView = [[EZFeedDisplayVideoCellView alloc]init];
        feedVideoCellView.videoIndex = videoIndex;
        videoIndex++;
        feedVideoCellView.videoId = [videoRow objectForKey:@"videoId"];
        feedVideoCellView.videoSeqNoInPage = videoNum;
        feedVideoCellView.videoTitle = [videoRow objectForKey:@"videoTitle"];
        feedVideoCellView.channelId = [videoRow objectForKey:@"channelId"];
        feedVideoCellView.videoThumbNailURLString = [videoRow objectForKey:@"videoThumbnailString"];
        feedVideoCellView.videoURL = [videoRow objectForKey:@"videoURL"];
        
        feedVideoCellView.videoTitleLbl.text = [NSString stringWithFormat:@"%d. %@",videoNum+start_index-1,[videoRow objectForKey:@"videoTitle"]];
        feedVideoCellView.videoUploadDateLbl.text = [videoRow objectForKey:@"videoUploadDate"];
        
        [feedVideoCellView setImagedDownloadQueue:self.videoFeedDownloadQueue];
        feedVideoCellView.delegate = self;
        
        //Add Video Cell view as SubView
        CGRect frame = feedVideoCellView.frame;
        frame.origin.x = x;
        frame.origin.y = yStart+(i-1)*(165+yBuffer);
        frame.size.width = 220;
        frame.size.height = 165;
        
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
            j++;
            
            if(j<5)
            {
                x += (xBuffer+220);
            }
            else {
                x += ((2*xBuffer)+220);
                j=1;
            }
            
            
           
            
        }
    }
    
    [self setPageControl:12];


    
}



-(void) reframeExistingVideosCrowded
{
    //Dont trigger when videoFeedActive
    
       
    
    
    CGRect frame = self.videosScrollView.frame;
    int height = frame.size.height;
    
    
    
    
    int i = 1;
    int x = 0;
    //int xStart = 0;
    int xBuffer = 12;
    int yStart = 8;
    int yBuffer = 8;
    
    float videoCount = feedVideoResultsArray.count;
    
    //int rowCount = ceil(videoCount / 4.0);
    int pageCount = ceil(videoCount / 8.0);
    
    int scrollWidth = pageCount*384;
    //NSLog(@"ContentSize:%d",scrollWidth);
    
    
    if(scrollWidth < 384)
        scrollWidth = 384;
    
     //NSLog(@"ContentSize:%d,%d",scrollWidth,height);
    
    self.videosScrollView.contentSize =  CGSizeMake(scrollWidth, height);
    //[self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 384, 642) animated:YES];
    
    
    int videoNum = 0;
    
    
    
    for (EZFeedDisplayVideoCellView * feedVideoCellView in self.videosScrollView.subviews)

    {
        videoNum++;
        
        //Create Video Cell, Set the attributes
        /*
        EZFeedDisplayVideoCellView * feedVideoCellView = [[EZFeedDisplayVideoCellView alloc]init];
        
        feedVideoCellView.videoId = [videoRow objectForKey:@"videoId"];
        feedVideoCellView.videoTitle = [videoRow objectForKey:@"videoTitle"];
        feedVideoCellView.channelId = [videoRow objectForKey:@"channelId"];
        feedVideoCellView.videoThumbNailURLString = [videoRow objectForKey:@"videoThumbnailString"];
        feedVideoCellView.videoURL = [videoRow objectForKey:@"videoURL"];
        
        feedVideoCellView.videoTitleLbl.text = [NSString stringWithFormat:@"%d. %@",videoNum+start_index-1,[videoRow objectForKey:@"videoTitle"]];
        feedVideoCellView.videoUploadDateLbl.text = [videoRow objectForKey:@"videoUploadDate"];
        
        [feedVideoCellView setImagedDownloadQueue:self.videoFeedDownloadQueue];
        feedVideoCellView.delegate = self;
         
         */
        
        //Add Video Cell view as SubView
        CGRect frame = feedVideoCellView.frame;
        frame.origin.x = xBuffer+x;
        frame.origin.y = yStart+(i-1)*(135+yBuffer);
        frame.size.width = 180;
        frame.size.height = 135;
        
        feedVideoCellView.frame = frame;
        

        
        //[ self.videosScrollView addSubview:feedVideoCellView];
        //[feedVideoCellView loadImageView];
        
        //Load Video Cell Images
        
        if(i == 1)
            i = 2;
        else if(i ==2)
            i = 3;
        else if(i ==3)
            i = 4;
        else if(i ==4)
        {
            i = 1;
            x += (xBuffer+180);
            
            
            if(xBuffer == 11)
                xBuffer = 12;
            else if(xBuffer == 12)
                xBuffer = 11;
            
        }
    }
    
    [self setPageControl:8];
    
     //NSLog(@"Video To Show:%d",self.videoToShowNum);
    
    int pageNumToShow = (ceil(self.videoToShowNum / 8.0))-1;
    
     //NSLog(@"Page No To Show:%d",pageNumToShow);
    
    
    CGRect scrollFrame = self.videosScrollView.frame;
    scrollFrame.origin.x = pageNumToShow * self.videosScrollView.frame.size.width;
    scrollFrame.origin.y = 0;
    
    int spaceLeft = self.videosScrollView.contentSize.width - scrollFrame.origin.x;
    if(spaceLeft < scrollFrame.size.width+1)
        {
            scrollFrame.origin.x = self.videosScrollView.contentSize.width - (self.videosScrollView.frame.size.width+1);
        }
    //NSLog(@"Scrolling to :%f,%f,%f,%f",scrollFrame.origin.x,scrollFrame.origin.y,scrollFrame.size.width,scrollFrame.size.height);
    [self.videosScrollView scrollRectToVisible:scrollFrame animated:NO];
    
    //CGFloat pageWidth = self.videosScrollView.frame.size.width;
    //int pageNum = floor((self.videosScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    feedsPageControl.currentPage = pageNumToShow;
       
}



-(void) reframeExistingVideosSpreadOut
{
    //Dont trigger when videoFeedActive
    
    
   
    
    
    
    
    CGRect frame = self.videosScrollView.frame;
    int height = frame.size.height;
    
    
    
    
    int i = 1;
    int j = 1;
    
    int x = 13;
    //int xStart = 0;
    int xBuffer = 13;
    int yStart = 8;
    int yBuffer = 8;
    
    float videoCount = feedVideoResultsArray.count;
    //int rowCount = ceil(videoCount / 3.0);
    int pageCount = ceil(videoCount / 12.0);
    int scrollWidth = 1024 * pageCount;
    
    if(scrollWidth < 1024)
        scrollWidth = 1024;
    
    self.videosScrollView.contentSize =  CGSizeMake(scrollWidth, height);
    
    //[self.videosScrollView scrollRectToVisible:CGRectMake(0, 0, 1024, 642) animated:YES];
    
    int videoNum = 0;
    
    
    
    //for (NSDictionary * videoRow in feedVideoResultsArray)
    for (EZFeedDisplayVideoCellView * feedVideoCellView in self.videosScrollView.subviews)

    {
        videoNum++;
        
        //Create Video Cell, Set the attributes
        //EZFeedDisplayVideoCellView * feedVideoCellView = [[EZFeedDisplayVideoCellView alloc]init];
        
        /*
        feedVideoCellView.videoId = [videoRow objectForKey:@"videoId"];
        feedVideoCellView.videoTitle = [videoRow objectForKey:@"videoTitle"];
        feedVideoCellView.channelId = [videoRow objectForKey:@"channelId"];
        feedVideoCellView.videoThumbNailURLString = [videoRow objectForKey:@"videoThumbnailString"];
        feedVideoCellView.videoURL = [videoRow objectForKey:@"videoURL"];
        
        feedVideoCellView.videoTitleLbl.text = [NSString stringWithFormat:@"%d. %@",videoNum+start_index-1,[videoRow objectForKey:@"videoTitle"]];
        feedVideoCellView.videoUploadDateLbl.text = [videoRow objectForKey:@"videoUploadDate"];
        
        [feedVideoCellView setImagedDownloadQueue:self.videoFeedDownloadQueue];
        feedVideoCellView.delegate = self;
         
         */
        
        //Add Video Cell view as SubView
        CGRect frame = feedVideoCellView.frame;
        frame.origin.x = x;
        frame.origin.y = yStart+(i-1)*(180+yBuffer);
        frame.size.width = 240;
        frame.size.height = 180;
        
        feedVideoCellView.frame = frame;
        
        //[ self.videosScrollView addSubview:feedVideoCellView];
        
        //[feedVideoCellView loadImageView];
        
        //Load Video Cell Images
        
        if(i == 1)
            i = 2;
        else if(i ==2)
            i = 3;
        else if(i ==3)
        {
            i = 1;
            j++;
            
            if(j<5)
            {
                x += (xBuffer+240);
            }
            else {
                x += ((2*xBuffer)+240);
                j=1;
            }
            
            
            
            
        }
    }
    
    [self setPageControl:12];
    
     //NSLog(@"Video To Show:%d",self.videoToShowNum);
    int pageNumToShow = (ceil(self.videoToShowNum / 12.0))-1;
     //NSLog(@"Page Num To Show:%d",pageNumToShow);
    
    CGRect scrollFrame = self.videosScrollView.frame;
    scrollFrame.origin.x = pageNumToShow * self.videosScrollView.frame.size.width;
    scrollFrame.origin.y = 0;
    //scrollFrame.size.width = 255;
    
    
    int spaceLeft = self.videosScrollView.contentSize.width - scrollFrame.origin.x;
    if(spaceLeft < scrollFrame.size.width)
    {
     scrollFrame.origin.x = self.videosScrollView.contentSize.width - self.videosScrollView.frame.size.width;
    }
    
    [self.videosScrollView scrollRectToVisible:scrollFrame animated:YES];
    
    //CGFloat pageWidth = self.videosScrollView.frame.size.width;
    //int pageNum = floor((self.videosScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    feedsPageControl.currentPage = pageNumToShow;
}


#pragma mark - Set Page Control

-(void) setPageControl:(int)videosPerPage
{
    
    feedsPageControl.numberOfPages = ceil((float)feedVideoResultsArray.count / videosPerPage);
    feedsPageControl.currentPage = 0;
    
    
    //feedsPageControl.frame = CGRectMake(2, 50, 162, 10);
    
    
}


#pragma mark - Playing Video in popup, Enter, Exit Full Screen

-(void) popVideo:(NSString *)videoId title:(NSString *)title
{
    [self.delegate popVideo:videoId title:title];
      
}
-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId
{
    
    [self.delegate popVideo:videoId title:title channelId:channelId];
     
    
}


-(void)loadVideoInPage:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelIdSent videoSeqNum:(int)videoSeqNum
{
    
    self.videoToShowNum = videoSeqNum;
    
    //self.videoViewController.delegate = self.delegate;
    //[self.playerView addSubview:self.videoViewController.view];
    
    
    self.videoViewController.videoId = videoId;
    self.videoViewController.videoTitle = title;
    self.videoViewController.channelId = channelIdSent;
   
    [self.videoViewController loadVideo];
    
    self.videoToShowNum = -1;
}

-(void)loadVideoInPage:(NSString *)videoId title:(NSString *)title videoSeqNum:(int)videoSeqNum
{
    
    self.videoToShowNum = videoSeqNum;
    
    //self.videoViewController.delegate = self.delegate;
    //[self.playerView addSubview:self.videoViewController.view];
    
    
    self.videoViewController.videoId = videoId;
    self.videoViewController.videoTitle = title;
    self.videoViewController.channelId = @"";
 
    [self.videoViewController loadVideo];
    
    self.videoToShowNum = -1;
    
}


- (void)youtubeFullScreenEnteredUIMoviePlayer:(NSNotification *)notification
{
    
    videoEnteredFullScreen4 = YES;
    
    if(popOver.isPopoverVisible)
    {
        [popOver dismissPopoverAnimated:YES];
    }
    
    
}

- (void)youtubeFullScreenExitedUIMoviePlayer:(NSNotification *)notification
{
    
    videoEnteredFullScreen4 = NO;
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
        if(!videoEnteredFullScreen4)
        {
            //NSLog(@"Releasing Video VC");
            [((TSVideoViewController *)popover.contentViewController).webView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [((TSVideoViewController *)popover.contentViewController).webView loadHTMLString:@"Bye" baseURL:nil];
            //popover.contentViewController = nil;
            //[videoViewController release];
        }
    }
    return YES;  
}


#pragma mark - Feed Preferences Delegate

-(void) doneWithFeedPreferences{
    //NSLog(@"Done with preferences");

    [self doReLayout];
    //int row = self.feedsTableView.indexPathForSelectedRow.row;
    //[self showVideosForRow:row];
    [self.delegate doneWithPreferences];
    
}

-(void)addedNewFeed
{
    self.reLayoutNeeded = YES;
    [self doReLayout];

    
}

-(void) editedFeed{
    
    self.reLayoutNeeded = YES;
    [self doReLayout];
    
}

-(void)deletedFeed
{
    self.reLayoutNeeded = YES;
    [self doReLayout];
    
}
-(void)movedFeed
{
    self.reLayoutNeeded = YES;
    [self doReLayout];

}

-(void) doReLayout
{
    //NSLog(@"start doReLayout");
    
    //Always clear old video feed...to overcome undownloaded images
    //[self.videosScrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.reLayoutNeeded) 
    {
        
        //NSLog(@"Reloading Channels View as relayout is needed");
        
        self.selectedFeedLbl.text = @"";
        
        //Refresh Channels Menu
        [self refreshFeedList];
        
        self.reLayoutNeeded = NO;

    }
    else
    {
        

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
                EZFeedDisplayVideoCellView * videoCell = (EZFeedDisplayVideoCellView *)subView;
                [videoCell loadImageView];
            }
        }
    }
    
}

- (IBAction)changePage:(id)sender {
    
    int page = feedsPageControl.currentPage;
    pageControlUsed = YES;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    
    
	// update the scroll view to the appropriate page
    CGRect frame = self.videosScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.videosScrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    
    
    
    
}

- (IBAction)showFeedSearch:(id)sender {
    [self.delegate showFeedSearch];
}

- (IBAction)showFeedPreferences:(id)sender {
    [self.delegate showFeedPreferences];
}

#pragma mark -VideosScrollView delegate methods 

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    pageControlUsed = NO;
    CGFloat pageWidth = self.videosScrollView.frame.size.width;// self.view.frame.size.width;
    //int offset = ((UIScrollView *)self.view).contentOffset.x;
    int pageNum = floor((self.videosScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    //currentChannelPageNumber = pageNum;
    feedsPageControl.currentPage = pageNum;
    //[self setUpPrevCurrentNextPagesForPageNum:pageNum];
}


#pragma mark Feeds Scroll View Content Size
-(void) setFeedsScrollViewContentSize
{
    int channelRows = [self.fetchedResultsController.fetchedObjects count];
    int channelRowHeight = 110;
    int height = (channelRows * channelRowHeight)+2;
    
    int minHeight = self.feedsScrollView.frame.size.height;
    if(height < minHeight)
        height = minHeight;
    
    self.feedsScrollView.contentSize =  CGSizeMake(self.feedsScrollView.frame.size.width,height);
    CGRect frame1 = self.feedsTableView.frame;//CGRectMake(0, 1, 320, height);
    frame1.size.height = height;
    //CGRect frame2 =  self.feedsTableView2.frame;//CGRectMake(321, 1, 319, height);
    //frame2.size.height = height;
    self.feedsTableView.frame = frame1;//CGSizeMake(self.channelsTableView.frame.size.width,height);
    //self.feedsTableView2.frame = frame2;//CGSizeMake(self.channelsTableView2.frame.size.width,height);
    
    //NSLog(@"-------->Top Scroll View content Size change to :%f,%d",self.topScrollView.frame.size.width,height);
    
    
}





         - (IBAction)upButtonPressed:(id)sender 
        {
            [self highlightFeedName:self.currentSelectedFeedActualRow+1];
             [self showVideosForRow:self.currentSelectedFeedActualRow+1];
            
         }

         - (IBAction)downButtonPressed:(id)sender 
        {
            [self highlightFeedName:self.currentSelectedFeedActualRow-1];
             [self showVideosForRow:self.currentSelectedFeedActualRow-1];
            
         }

-(void) highlightFeedName:(int)actualRow
{

            [self.feedsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:actualRow inSection:0 ] animated:YES scrollPosition:UITableViewScrollPositionTop];
 

    
    [self moveFeedListScrollViewToFeed:actualRow];
    
}

-(void)moveFeedListScrollViewToFeed:(int)feedNum
{
    
    int rowNum = feedNum;//floor(feedNum / 2.0) + 1;
    int scrollIdealPosition = 110;
    int rowPosition = (rowNum-1)*110;
    
    CGPoint scrollPosition = self.feedsScrollView.contentOffset;
    int scrollToPosition = rowPosition - scrollIdealPosition;
    CGRect scrollFrame = self.feedsScrollView.frame;
    
    if(scrollToPosition > 0)
    {
        
        scrollFrame.origin.y = scrollToPosition;
        [self.feedsScrollView scrollRectToVisible:scrollFrame animated:YES];
    }
    else if(scrollPosition.y >0)
    {
        scrollFrame.origin.y = 0;
        [self.feedsScrollView scrollRectToVisible:scrollFrame animated:YES];
    }
}


#pragma mark - Let Channel Screen handle playing video

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
                                           self.feedType,@"feed_Channel_Type",
                                           self.selectedFeedLbl.text,@"feed_Channel_Title",
                                           currentFeedCountryImage.image,@"feed_Channel_FlagImg",
                                           currentFeedCategoryImage.image,@"feed_Channel_Category_Channel_img",
                                           nil ];
    
    
    [self.delegate loadAllVideosInExternalPlayerWithVideoSetArray:videoSetArray feedChannelInfo:feed_OR_Channel_info StartingWithVideoIndex:index];
}

-(void) loadAllVideosInExternalPlayerWithVideoSetArray:(NSArray*)videoSetArray  feedChannelInfo:(NSDictionary *)feed_OR_Channel_info StartingWithVideoIndex:(int)index{
    
    [self.delegate loadAllVideosInExternalPlayerWithVideoSetArray:videoSetArray feedChannelInfo:feed_OR_Channel_info StartingWithVideoIndex:index];
    
}


@end
