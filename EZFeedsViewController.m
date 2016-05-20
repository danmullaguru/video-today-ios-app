//
//  TSPreferencesViewController.m
//  TSVideos
//
//  Created by dan mullaguru on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EZFeedsViewController.h"

#import "Feed.h"

#define CHANNEL_LIMIT				25

@interface EZFeedsViewController ()
-(void) pushEditVideoFeed:(Feed *)feedObject flagImage:(UIImage *)flagImg categoryImage:(UIImage *)categoryImg;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)saveContext;
-(BOOL) isNewFeedActivatble;
-(void) showChannelSearch;
-(void) loadFeedImagesDictionary;
@end
 

@implementation EZFeedsViewController

@synthesize ls;
@synthesize currentFeedsTableView;
@synthesize editButton;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize delegate;
@synthesize ezFeedsImageView;

@synthesize feedFlagsImagesDictionary;
@synthesize feedCategoriesImagesDictionary;



static NSString *CellClassName = @"EZFeedsTableCell";

UIPopoverController * popOver;

BOOL userDataModelChange1 = NO;

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
    //self.title = @"EZ Feeds";
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWithPreferencesLocal:)];
    
    //Set background image
    UIImage * bGImg = [UIImage imageNamed:@"feedEditbackground.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bGImg];
    
    [self setVCtoCurrentLanguage];
}

-(void) loadFeedImagesDictionary
{
    //Load Country Flags Images
    
    NSArray * countryFlagImageKeys = [[NSArray alloc] initWithObjects: @"All Countries",@"Argentina",@"Australia",@"Brazil",@"Canada",@"Czech Republic",@"France",@"Germany",@"Great Britain",@"Hong Kong",@"India",@"Ireland",@"Israel",@"Italy",@"Japan",@"Mexico",@"Netherlands",@"New Zealand",@"Poland",@"Russia",@"South Africa",@"South Korea",@"Spain",@"Sweden",@"Taiwan",@"United States", nil];
    
    NSArray * countryFlagImages =  [[NSArray alloc] initWithObjects: 
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
    [countryFlagImages release];
    [countryFlagImageKeys release];
    
    
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
    [feedCategoriesImages release];
    [feedCategoriesImageKeys release];
}


-(void) setVCtoCurrentLanguage
{
    ls = [LocalizationSystem sharedLocalSystem];
    
    //Load localized images
    //NSLog(@"change_order_path:%@",ls.change_order_path);
    //NSLog(@"change_order_mainBundle_path:%@",ls.change_order_mainBundle_path);
    
    
    
    UIImage *change_order_img = [[UIImage alloc] initWithContentsOfFile:ls.change_order_path];
    if(!change_order_img)
    {
        change_order_img = [[UIImage alloc] initWithContentsOfFile:ls.change_order_mainBundle_path];
    }
    [editButton setImage:change_order_img forState:UIControlStateNormal];
    [change_order_img release];
    
    
    UIImage *savebutton_img = [[UIImage alloc] initWithContentsOfFile:ls.savebutton_path];
    if(!savebutton_img)
    {
        savebutton_img = [[UIImage alloc] initWithContentsOfFile:ls.savebutton_mainBundle_path];
    }
        [editButton setImage:savebutton_img forState:UIControlStateSelected];
    [savebutton_img release];
     
    UIImage *feeds_active_img = [[UIImage alloc] initWithContentsOfFile:ls.top_feeds_active_path ];
    if(!feeds_active_img)
    {
        feeds_active_img = [[UIImage alloc] initWithContentsOfFile:ls.top_feeds_active_mainBundle_path];
    }
    
    ezFeedsImageView.image = feeds_active_img;
    [feeds_active_img release];
    
        
}



- (void)viewDidUnload
{
    [self setCurrentFeedsTableView:nil];
    [self setEditButton:nil];
    [self setEzFeedsImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [cellLoader release];
    [currentFeedsTableView release];
    [editButton release];
    [ezFeedsImageView release];
    [super dealloc];
}

#pragma mark - Table datasource delegate methods

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
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    static NSString *CellIdentifier = @"FeedEditCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
     */
    
    EZFeedsTableCell *cell = (EZFeedsTableCell *)[tableView dequeueReusableCellWithIdentifier:CellClassName];
    
    if (!cell)
    {
        
        NSArray *topLevelItems = [cellLoader instantiateWithOwner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(EZFeedsTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   
    /*
    Feed *feedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    BOOL activeState = [feedObject.isActive boolValue];
    if(! activeState)
    {
        //cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.alpha = 0.4;
        //cell.detailTextLabel.alpha = 0.4;
    }
    else
    {
        //cell.backgroundColor = [UIColor blackColor];
        //cell.textLabel.text 
        cell.textLabel.alpha = 1.0;
        //cell.detailTextLabel.alpha = 1.0; 
        
    }
    cell.showsReorderControl = YES;
    cell.textLabel.font = [UIFont fontWithName:@"chalkduster" size:22];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d.%@",indexPath.row+1,[feedObject giveDisplayNameLocalized]]; 
  */
    
    
    Feed *feedObject = (Feed *) [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.feedNameLbl.text =  [NSString stringWithFormat:@"%d.%@",indexPath.row+1,[feedObject giveDisplayNameLocalized]];
    
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
    

    //cell.feedFlagImageView.image = [feedFlagsImagesDictionary objectForKey:feedObject.feedRegion];
    //cell.feedCategoryImageView.image = [feedCategoriesImagesDictionary objectForKey:feedObject.feedCategory];
    
    BOOL activeState = [feedObject.isActive boolValue];
    if(! activeState)
    {
        cell.feedNameLbl.alpha = 0.4;
    }
    else 
    {
        cell.feedNameLbl.alpha = 1.0;
    }
    
    cell.showsReorderControl = YES;
    cell.feedNameLbl.font = [UIFont fontWithName:@"chalkduster" size:20];
    cell.feedNameLbl.textColor = [UIColor darkGrayColor];


    
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Feed * source = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if([source.isSystemInstalled boolValue])
        {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"System Channel" message:@"This channel can not be deleted. Please click on the channel to inActivate." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
             [alert release];
        }
        else
        {
                [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
                
                // Save the context.
                NSError *error = nil;
                if (![context save:&error]) 
                    {

                        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        abort();
                    }
                [self.delegate deletedFeed]; 
        }
        
    }   
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


- (void)tableView:(UITableView *)tableView 
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
      toIndexPath:(NSIndexPath *)destinationIndexPath;
{  
    

    
    
    userDataModelChange1 = YES;
    
    /*
    if(destinationIndexPath.row <2)
        destinationIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
     */
    
    NSMutableArray *things = [[self.fetchedResultsController fetchedObjects] mutableCopy];
   
    NSManagedObject *thing = [[self fetchedResultsController] objectAtIndexPath:sourceIndexPath];
    
    [things removeObject:thing];

    [things insertObject:thing atIndex:[destinationIndexPath row]];

    int i = 1;
    for (NSManagedObject *mo in things)
    {
        [mo setValue:[NSNumber numberWithInt:i++] forKey:@"displayOrder"];
    }
    
    [things release], things = nil;
    
    [self saveContext];
    
    [NSFetchedResultsController deleteCacheWithName:@"SOURCES"];
    [self.fetchedResultsController fetchedObjects];
    [self.currentFeedsTableView reloadData];
   // [self fetchedResultsController];   
    
    [self.delegate movedFeed];
    
    userDataModelChange1 = NO;
     
    
}


#pragma mark - TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //NSLog(@"%@",feedObject.feedRegion);
    //NSLog(@"%@",feedObject.feedCategory);
    [self pushEditVideoFeed:(Feed *)feedObject flagImage:[feedFlagsImagesDictionary objectForKey:feedObject.feedRegion] categoryImage:[feedCategoriesImagesDictionary objectForKey:feedObject.feedCategory]];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 55.0f;
}






- (IBAction)editChannels:(id)sender 
{
    
    UIButton * button = (UIButton *)sender;
    
    if(!button.isSelected)
    {
        [self.currentFeedsTableView setEditing: YES animated: YES];
        [self.editButton setSelected:YES];
    }
    else
    {
/*
        int i = 1;
        for(Feed *source in self.fetchedResultsController.fetchedObjects) {
            NSString * sourceName = source.displayName;
            source.displayOrder = [NSNumber numberWithInt:i++];
        }
        [self saveContext]; 
        [NSFetchedResultsController deleteCacheWithName:@"SOURCES"];
        [self.fetchedResultsController fetchedObjects];
     */   
        [self.currentFeedsTableView setEditing: NO animated: YES];
        [self.editButton setSelected:NO];
    }
        
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
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sourceSite" cacheName:@"FEEDS"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {

	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (userDataModelChange1) return;
    
    [self.currentFeedsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (userDataModelChange1) return;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.currentFeedsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.currentFeedsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (userDataModelChange1) return;
    
    UITableView *tableView = self.currentFeedsTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (userDataModelChange1) return;
    
    [self.currentFeedsTableView endUpdates];
}

#pragma mark - Pop Video..let homepage do it

-(void) popVideo:(NSString *)videoId title:(NSString *)title
{
    [self.delegate popVideo:videoId title:title];
    
}

-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId;
{
    
    [self.delegate popVideo:videoId title:title channelId:channelId];
    
}

-(void) loadAllVideosInExternalPlayerWithVideoSetArray:(NSArray*)videoSetArray  feedChannelInfo:(NSDictionary *)feed_OR_Channel_info StartingWithVideoIndex:(int)index
{
    
[self.delegate loadAllVideosInExternalPlayerWithVideoSetArray:videoSetArray feedChannelInfo:feed_OR_Channel_info StartingWithVideoIndex:index];
    
}




#pragma mark - Add/Edit Video Feed

-(void) doneWithPreferencesLocal:(id)sender {

    [self.delegate doneWithFeedPreferences];
}
    


- (IBAction)addButtonPressed:(id)sender {
    
    [self showChannelSearch];
    
    /*
     
    AddVideoFeedViewController *addVideoFeedViewController = [[AddVideoFeedViewController alloc] initWithNibName:@"AddVideoFeedViewController" bundle:nil];
    addVideoFeedViewController.delegate = self;
    //addVideoFeedViewController.managedObjectContext = self.managedObjectContext;
    //[self.navigationController pushViewController:addVideoFeedViewController animated:YES];
    
    popOver = [[UIPopoverController alloc]initWithContentViewController:addVideoFeedViewController];
    CGRect popRect = CGRectMake(160,30,160,60);
    //UIEdgeInsets insets = UIEdgeInsetsMake(0, 48, 0, 0);
    //[popOver setPopoverLayoutMargins:insets];
    
    [popOver presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    */
    
}


-(void) showChannelSearch
{
    EZFeedSearchViewController * feedSearchVC = [[EZFeedSearchViewController alloc]init];
    feedSearchVC.managedObjectContext = self.managedObjectContext;
    feedSearchVC.delegate = self;
    [self.navigationController pushViewController:feedSearchVC animated:YES];
    //[channelSearchVC release];
    
}


-(void) pushEditVideoFeed:(Feed *)feedObject flagImage:(UIImage *)flagImg categoryImage:(UIImage *)categoryImg
{
    
   
        EditVideoFeedViewController * editVideoFeedViewController = [[EditVideoFeedViewController alloc]init];
        editVideoFeedViewController.delegate = self;
        editVideoFeedViewController.feedObject = feedObject;

        
       //[self.navigationController pushViewController:editVideoFeedViewController animated:YES];
        
        popOver = [[UIPopoverController alloc]initWithContentViewController:editVideoFeedViewController];
        CGRect popRect = CGRectMake(160,90,160,60);
        //UIEdgeInsets insets = UIEdgeInsetsMake(0, 48, 0, 0);
        //[popOver setPopoverLayoutMargins:insets];
        
        if([feedObject.feed_OR_search isEqualToString:@"FEED"])
        {
            //NSLog(@"Country:%@",managedObject.feedRegion);
            editVideoFeedViewController.flagImage.image = [feedFlagsImagesDictionary objectForKey:feedObject.feedRegion];
            //NSLog(@"Country:%@",managedObject.feedCategory);
            editVideoFeedViewController.categoryImage.image = [feedCategoriesImagesDictionary objectForKey:feedObject.feedCategory];
        }
        else 
        {
            editVideoFeedViewController.flagImage.image = nil;
            editVideoFeedViewController.categoryImage.image = [UIImage imageNamed:@"searchIcon.png"];
            
        }

    
        [popOver presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

    
}





#pragma mark - Add/EditViewControllerDelegate methods

-(void) addNewVideoFeedRecord:(NSMutableDictionary *)videoFeed informAboutFeeds:(BOOL)inform
{
    [videoFeed retain];
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSNumber * displayOrderNum = [NSNumber numberWithInt:[Feed nextDisplayOrderNumberInManagedObjectContext:context]];
    [videoFeed setObject:displayOrderNum forKey:@"displayOrder"];
    
    [Feed insertFeedIfNew:videoFeed inManagedObjectContext:context];
    
    [self saveContext];
    [videoFeed release];
    
    if(inform)
    {
        [self.delegate addedNewFeed];
    }

}

-(void) informAboutNewFeeds
{
    
    [self.delegate addedNewFeed];
}

-(void) editVideoFeedRecord

{
    [self saveContext];
    [self.currentFeedsTableView reloadData];
    
    [popOver dismissPopoverAnimated:YES];
    [self.delegate editedFeed];
    
}

-(void) editActiveStatusForFeed:(NSString *) sourceId changed:(BOOL)changed toStatus:(BOOL)isMadeActive
{
    if(changed)
    {

        if(isMadeActive)
        {
            [self.delegate editedFeed];
            //[self.delegate addedNewFeed:sourceId]; 
        }
        else
        {
            [self.delegate editedFeed];
            //[self.delegate removedFeed:sourceId]; 
            
        }
    }
    
}

-(BOOL) isNewFeedActivatble
{
    BOOL isActivatable = YES;

    
    return isActivatable;
}

#pragma mark - save changes in managedObjectContext 

- (void)saveContext {
    
    NSError *error = nil;
    if (__managedObjectContext != nil) {
        if ([__managedObjectContext hasChanges] && ![__managedObjectContext save:&error]) {

            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
} 




@end
