//
//  ViewController.m
//  22. Touches HW
//
//  Created by Александр on 30.01.2020.
//  Copyright © 2020 Badmaev. All rights reserved.
//

#import "ViewController.h"

const NSInteger countCellToRow = 8;
const CGFloat sizeCheckerRelativeToCell = 0.7;

@interface ViewController ()
@property (weak, nonatomic) UIView* board;
@property (weak, nonatomic) UIView* draggingChecker;
@property (strong, nonatomic) NSMutableSet* freeCells;
@property (strong, nonatomic) NSMutableArray* checkers;
@property (assign, nonatomic) CGPoint touchOffset;
@property (assign, nonatomic) CGPoint previousPositionDraggedChecker;
@end

@implementation ViewController

#pragma mark - Drawing

- (NSMutableArray*) fillBoard:(CGRect)board withFillingFreeCells:(NSMutableSet*)freeCells withFillingCheckers:(NSMutableArray*)checkers {
    
    CGFloat sideCell = CGRectGetWidth(board) / countCellToRow;
    
    NSMutableArray* array = [NSMutableArray array];
    
    CGRect cellRect = CGRectMake(0, 0, sideCell, sideCell);
    
    for (NSInteger i = 0; i < 8; i++) {
        for (NSInteger j = 0; j < 4; j++) {
            
            if (i % 2) {
                cellRect.origin.x = j * 2 * sideCell;
            } else {
                cellRect.origin.x = (j * 2 + 1) * sideCell;
            }
            cellRect.origin.y = i * sideCell;
            
            UIView* cell = [[UIView alloc] initWithFrame:cellRect];
            cell.backgroundColor = [UIColor blackColor];
            [array addObject:cell];
            
            CGFloat sideChecker = sideCell * sizeCheckerRelativeToCell;
            
            if (i < 3) {
                UIView* checkerWhite = [[UIView alloc] initWithFrame: CGRectMake(cellRect.origin.x + sideCell * 0.5 * (1 - sizeCheckerRelativeToCell), cellRect.origin.y + sideCell * 0.5 * (1 - sizeCheckerRelativeToCell), sideChecker, sideChecker)];
                
                checkerWhite.backgroundColor = [UIColor whiteColor];
                checkerWhite.layer.cornerRadius = sideChecker * 0.5f;
                [array addObject:checkerWhite];
                [checkers addObject:checkerWhite];
            } else if (i > 4) {
                UIView* checkerRed = [[UIView alloc] initWithFrame: CGRectMake(cellRect.origin.x + sideCell * 0.5 * (1 - sizeCheckerRelativeToCell), cellRect.origin.y + sideCell * 0.5 * (1 - sizeCheckerRelativeToCell), sideChecker, sideChecker)];
                
                checkerRed.backgroundColor = [UIColor redColor];
                checkerRed.layer.cornerRadius = sideChecker * 0.5f;
                [array addObject:checkerRed];
                [checkers addObject:checkerRed];
            } else {
                // center points of all black cells
                [freeCells addObject:[NSValue valueWithCGPoint:cell.center]];
            }
        }
    }
    return array;
}

#pragma mark - Events

- (void)viewDidLoad {
    [super viewDidLoad];
        
    CGFloat minSide = MIN(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    
    UIView* boardView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - minSide / 2,
                                                                 CGRectGetMidY(self.view.bounds) - minSide / 2,
                                                                 minSide, minSide)];
    boardView.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.8];
    boardView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.board = boardView;
    
    [self.view addSubview:boardView];
    
    self.freeCells = [NSMutableSet set];
    self.checkers = [NSMutableArray array];
    
    NSMutableArray* array = [self fillBoard:self.board.bounds withFillingFreeCells:self.freeCells withFillingCheckers:self.checkers];
    
    for (UIView* cell in array) {
        [self.board addSubview:cell];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL) isCheckerView:(UIView*)currentView {
    for (UIView* view in self.checkers) {
        if ([view isEqual:currentView]) {
            return YES;
        }
    }
    return NO;
}

- (void) breakAnimationChecker:(UIView*)checker {
    [UIView animateWithDuration:0.3f animations:^{
        checker.transform = CGAffineTransformIdentity;
        checker.alpha = 1.f;
    }];
}

- (void) moveChecker:(UIView*)checker onPosition:(CGPoint)position {
    checker.center = position;
}

- (CGPoint) findFreeCellFor:(CGPoint)pointChecker {
    
    // diagonal length of board
    CGFloat minLength = sqrtf(powf(CGRectGetWidth(self.board.bounds), 2) +
                              powf(CGRectGetHeight(self.board.bounds), 2));
    CGPoint nearestPoint = CGPointZero;
    
    NSArray* arrayPoint = [self.freeCells allObjects];
    
    for (NSInteger i = 0; i < [arrayPoint count]; i++) {
        CGPoint point = [[arrayPoint objectAtIndex:i] CGPointValue];
        CGFloat dx = fabs(point.x - pointChecker.x);
        CGFloat dy = fabs(point.y - pointChecker.y);
        // length between points
        CGFloat length = sqrtf(powf(dx, 2) + powf(dy, 2));
        
        if (length < minLength) {
            minLength = length;
            nearestPoint = point;
        }
    }
    return nearestPoint;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.board];
    UIView* checkerView = [self.board hitTest:point withEvent:event];
    if ([self isCheckerView:checkerView]) {
        self.previousPositionDraggedChecker = checkerView.center;
        self.draggingChecker = checkerView;
        self.touchOffset = CGPointMake(CGRectGetMidX(self.draggingChecker.frame) - point.x,
                                       CGRectGetMidY(self.draggingChecker.frame) - point.y);
        [self.draggingChecker.layer removeAllAnimations];
        [self.board bringSubviewToFront:self.draggingChecker];
        [UIView animateWithDuration:0.3f animations:^{
            self.draggingChecker.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
            self.draggingChecker.alpha = 0.6;
        }];
    } else {
        self.draggingChecker = nil;
        self.previousPositionDraggedChecker = CGPointZero;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.draggingChecker) {
        
        UITouch* touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.board];
        if ([self.board pointInside:point withEvent:event]) {
            
            self.draggingChecker.center = CGPointMake(point.x + self.touchOffset.x,
                                                      point.y + self.touchOffset.y);
        } else {
            
            [self breakAnimationChecker:self.draggingChecker];
            [self moveChecker:self.draggingChecker onPosition:self.previousPositionDraggedChecker];
            self.draggingChecker = nil;
            self.previousPositionDraggedChecker = CGPointZero;
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.draggingChecker) {
        
        [self breakAnimationChecker:self.draggingChecker];
        
        [self.freeCells addObject:[NSValue valueWithCGPoint:self.previousPositionDraggedChecker]];
        
        CGPoint pointNearestFreeCell = [self findFreeCellFor:CGPointMake(self.draggingChecker.center.x + self.touchOffset.x, self.draggingChecker.center.y + self.touchOffset.y)];
        
        [self moveChecker:self.draggingChecker onPosition:pointNearestFreeCell];
        
        [self.freeCells removeObject:[NSValue valueWithCGPoint:pointNearestFreeCell]];
        
        self.draggingChecker = nil;
        self.previousPositionDraggedChecker = CGPointZero;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.draggingChecker) {
        
        [self breakAnimationChecker:self.draggingChecker];
        [self moveChecker:self.draggingChecker onPosition:self.previousPositionDraggedChecker];
        self.draggingChecker = nil;
        self.previousPositionDraggedChecker = CGPointZero;
    }
}

@end
