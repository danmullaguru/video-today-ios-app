//
//  EditVideoFeedViewController.m
//  TSVideos
//
//  Created by dan mullaguru on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditVideoFeedViewController.h"

#define CHANNEL_LIMIT				25

@implementation EditVideoFeedViewController
@synthesize delegate;
@synthesize displayName;
@synthesize ls;
@synthesize isActive;
@synthesize sourceSite;
@synthesize feedObject;
@synthesize videoFeed;
@synthesize isMadeActive;
@synthesize isActiveStatusChanged;
@synthesize flagImage;
@synthesize categoryImage;
@synthesize saveButton;

@synthesize managedObjectContext = __managedObjectContext;


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
    // Do any additional setup after loading the view from its nib.
    ls = [LocalizationSystem sharedLocalSystem];
    
    // Using feedObject
    self.title = @"Edit Channel";
    //self.userId.text = feedObject.sourceUserId;
    self.sourceSite.text = @""; //feedObject.sourceSite;
    self.displayName.text = [feedObject giveDisplayNameLocalized];
    //self.maxVideos.text = [feedObject.numOfVideosToKeep stringValue];
    //NSString * thumbQuality = feedObject.thumbnailQuality;
    /*
    if([thumbQuality isEqualToString:@"High"])
        self.thumbnailSelection.selectedSegmentIndex =  0;
    else
        self.thumbnailSelection.selectedSegmentIndex = 1;
     */
    self.isActive.on = [feedObject.isActive boolValue];
    
    self.managedObjectContext = [feedObject managedObjectContext];
    self.isMadeActive = NO;
    self.isActiveStatusChanged = NO;    
    
    UIImage *savebutton_img = [[UIImage alloc] initWithContentsOfFile:ls.savebutton_path];
    if(!savebutton_img)
    {
        savebutton_img = [[UIImage alloc] initWithContentsOfFile:ls.savebutton_mainBundle_path];
    }
    
    [saveButton setImage:savebutton_img forState:UIControlStateNormal];
    [savebutton_img release];
    
}

- (void)viewDidUnload
{
    [self setDisplayName:nil];
    
    [self setIsActive:nil];
    [self setSourceSite:nil];

    [self setFlagImage:nil];
    [self setCategoryImage:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)editVideoFeedLocal:(id)sender {
     //NSManagedObjectContext *mo = [feedObject managedObjectContext];
    
    //if(self.displayName.text.length <3)
    //{
        
        //self.displayName.text = ;
    //}

    //feedObject.displayName = self.displayName.text;
    NSNumber * active = [NSNumber numberWithBool:self.isActive.on];
    feedObject.isActive = active;
 
    
       
    
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    
    
    //[self.delegate editActiveStatusForFeed:feedObject.sourceUserId changed:self.isActiveStatusChanged toStatus:self.isMadeActive] ;
    [self.delegate editVideoFeedRecord];
    
    
}

-(IBAction)activeStatusChanged:(id)sender
    {
        

    
        
        
    }


- (CGSize)contentSizeForViewInPopover{
    return  CGSizeMake(550, 225);
}

- (void)dealloc {
    [displayName release];
 
   
    [isActive release];
   
    [sourceSite release];
  
    [flagImage release];
    [categoryImage release];
    [saveButton release];
    [super dealloc];
}
@end
