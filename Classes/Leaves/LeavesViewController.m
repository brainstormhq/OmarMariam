//
//  LeavesViewController.m
//  Leaves
//
//  Created by Tom Brow on 4/18/10.
//  Copyright Tom Brow 2010. All rights reserved.
//

#import "LeavesViewController.h"

@implementation LeavesViewController

@synthesize leavesView;

- (id)init {
    if (self = [super init]) {
		leavesView = [[LeavesView alloc] initWithFrame:CGRectZero];

        leavesView.mode = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? LeavesViewModeSinglePage : LeavesViewModeFacingPages;
    }
	
	NSString *pathToAudio = [[NSBundle mainBundle] pathForResource:@"flip" ofType:@"mp3"];
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pathToAudio];
	
	if (fileExists) {
		
		audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pathToAudio] error:NULL];
		[audioPlayer prepareToPlay];
	}
	
    return self;
}

- (void)dealloc {
	[leavesView release];
	
	if (audioPlayer != nil) {
		[audioPlayer release];
		audioPlayer = nil;
	}
    [super dealloc];
}

#pragma mark -
#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
	return 0;
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	
}

#pragma mark -
#pragma mark LeavesViewDelegate

- (void) leavesView:(LeavesView *)leavesView didTurnToPageAtIndex:(NSUInteger)pageIndex
{
	if ([audioPlayer isPlaying]) 
	{
		[audioPlayer stop];
	}
	
	[audioPlayer play];	
}

#pragma mark -
#pragma mark  UIViewController methods

- (void)loadView {
	[super loadView];
	leavesView.frame = self.view.bounds;
	leavesView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:leavesView];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	leavesView.dataSource = self;
	leavesView.delegate = self;
	[leavesView reloadData];
}


#pragma mark -
#pragma mark Interface rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        leavesView.mode = LeavesViewModeSinglePage;
    } else {
        leavesView.mode = LeavesViewModeFacingPages;
    }
}

@end