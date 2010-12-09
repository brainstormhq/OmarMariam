//
//  LineView.m
//  OmarMariam
//
//  Created by A.L.L.Y.K. on 11/4/10.
//  Copyright 2010 Brainstorm Technologies Sdn Bhd. All rights reserved.
//

#import "LineView.h"


CGFloat distance(CGPoint a, CGPoint b);

@implementation LineView

@synthesize viewController, correct, start, redrawToPrevious, dragged, touchEnded;
@synthesize	objectTouched, objectTagged, lines;
@synthesize currentTouchPoint, startTouchPoint;

- (void)awakeFromNib {

	// Initialization code
	self.objectTouched = [[NSString alloc] init];
	self.lines = [[NSMutableArray alloc] init];
	self.redrawToPrevious = NO;
	self.dragged = NO;
	self.touchEnded = NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	[self drawLine:rect];
}

- (void)dealloc {
	[self.objectTouched release];
	[self.lines release];
	
    [super dealloc];
}

- (void)drawLine:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextClearRect(context, rect);
	CGContextSetLineWidth(context, 5.0f);
	CGFloat gray[4] = {0.0f, 0.0f, 0.0f, 1.0f};
	CGContextSetStrokeColor(context, gray);
	
	if ([self.lines count]) 
	{
		for (NSArray *arr in self.lines) 
		{
			CGPoint point = CGPointFromString([arr valueForKey:@"startTouchPoint"]);
			//NSLog(@"%@", NSStringFromCGPoint(point));
			CGContextMoveToPoint(context, point.x, point.y);
			
			point = CGPointFromString([arr valueForKey:@"currentTouchPoint"]);
			CGContextAddLineToPoint(context, point.x, point.y);
			CGContextStrokePath(context);
		}
	}
	
	if (!correct && !touchEnded) {
		CGContextMoveToPoint(context, self.startTouchPoint.x, self.startTouchPoint.y);
		CGContextAddLineToPoint(context, self.currentTouchPoint.x, self.currentTouchPoint.y);
	}

	CGContextStrokePath(context);
	
}

- (void)cleanUp {
	// clear lines array.
	[self.lines removeAllObjects];
	
	// set scalar values to zero;
	objectTagged = 0;
	currentTouchPoint = startTouchPoint = CGPointZero;
	objectTouched = @"";
	correct = NO;
	start = NO;
	
	[self setNeedsDisplay];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [event.allTouches anyObject];
	self.startTouchPoint = [touch locationInView:self];

	self.correct = NO;
	self.dragged = NO;
	touchEnded = NO;
	
	for (UITouch *touch in touches) 
	{
		// check if touch in wordView.
		for (UILabel *word in [self.viewController wordViews]) 
		{
			CGRect wordRect = [word.superview convertRect:word.frame toView:self];
			if (CGRectContainsPoint(wordRect, [touch locationInView:self])) 
			{
				self.startTouchPoint = [touch locationInView:self];
				self.objectTouched = @"word";
				self.objectTagged = word.tag;
				self.start = YES;
				break;
			}
		}
		
		// check if touch in pictureView.
		for (UILabel *picture in [self.viewController pictureViews]) 
		{
			CGRect pictureRect = [picture.superview convertRect:picture.frame toView:self];
			if (CGRectContainsPoint(pictureRect, [touch locationInView:self])) 
			{
				self.startTouchPoint = [touch locationInView:self];
				self.objectTouched = @"picture";
				self.objectTagged = picture.tag;
				self.start = YES;
				break;
			}
		}
	}

	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	dragged = YES;
	if ([[touches allObjects] count] > 0)  
	{
		self.currentTouchPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];

		if (self.objectTouched == @"picture" || self.objectTouched == @"word") 
		{
			[self setNeedsDisplay];
		}
	}
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.start = NO;
	self.correct = NO;
	touchEnded = YES;
	
	UITouch *touch = [event.allTouches anyObject];
	
	CGPoint touchPoint = [touch locationInView:self];
	dragged = distance(touchPoint, startTouchPoint);
	
	if (self.objectTouched == @"picture" && dragged) 
	{
		for (UILabel *word in [self.viewController wordViews])
		{
			CGRect wordRect = [word.superview convertRect:word.frame toView:self];
			if (CGRectContainsPoint(wordRect, self.currentTouchPoint) 
				&& word.tag == self.objectTagged) 
			{
				self.correct = YES;
				NSMutableDictionary	*line = [[NSMutableDictionary alloc] init];

				[line setValue:NSStringFromCGPoint(self.startTouchPoint) forKey:@"startTouchPoint"];
				[line setValue:NSStringFromCGPoint(self.currentTouchPoint) forKey:@"currentTouchPoint"];
				
				[self.lines addObject:line];
				
				[line release];
				
				/*
				 * Check question and move to next level if completed.
				 */
				self.viewController.questionLeft = self.viewController.questionLeft - 1;
				
				[self.viewController checkLevelCompletion];

				break;
			}
		}
	}
	else if (self.objectTouched == @"word" && dragged) 
	{
		for (UIImageView *picture in [self.viewController pictureViews])
		{
			CGRect pictureRect = [picture.superview convertRect:picture.frame toView:self];
			if (CGRectContainsPoint(pictureRect, self.currentTouchPoint)
				&& picture.tag == self.objectTagged) 
			{
				self.correct = YES;
				NSMutableDictionary *line = [[NSMutableDictionary alloc] init];
				
				[line setValue:NSStringFromCGPoint(self.startTouchPoint) forKey:@"startTouchPoint"];
				[line setValue:NSStringFromCGPoint(self.currentTouchPoint) forKey:@"currentTouchPoint"];

				[self.lines addObject:line];

				[line release];
				
				/*
				 * Check question and move to next level if completed.
				 */
				self.viewController.questionLeft = self.viewController.questionLeft - 1;
				
				[self.viewController checkLevelCompletion];
				
				break;
			}
		}
	}
	
	[self setNeedsDisplay];
	
}

@end
