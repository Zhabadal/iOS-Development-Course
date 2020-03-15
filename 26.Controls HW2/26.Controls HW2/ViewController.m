//
//  ViewController.m
//  26.Controls HW2
//
//  Created by Александр on 05.02.2020.
//  Copyright © 2020 Badmaev. All rights reserved.
//

#import "ViewController.h"

typedef enum {
    ASScaleStatusMin,
    ASScaleStatusMax,
} ASScaleStatus;

@interface ViewController ()

@property (assign, nonatomic) CGFloat animationSpeed;
@property (assign, nonatomic) CGFloat animationScale;
@property (assign, nonatomic) CGFloat animationScaleCorrection;
@property (assign, nonatomic) CGFloat animationRotationAngle;
@property (assign, nonatomic) CGFloat animationTranslationOffsetX;
@property (assign, nonatomic) CGFloat animationTranslationOffsetY;
@property (assign, nonatomic) CGRect animationTranslationArea;
@property (assign, nonatomic) CGPoint animationTranslationPosition;

@property (assign, nonatomic) NSUInteger animationOptions;
@property (assign, nonatomic) NSInteger animationRotationDirection;
@property (assign, nonatomic) NSInteger animationMargin;

@property (assign, nonatomic) ASScaleStatus scaleStatus;

@property (assign, nonatomic) CGAffineTransform animationTransform;
@property (assign, nonatomic) CGAffineTransform animationScaleTransform;
@property (assign, nonatomic) CGAffineTransform animationRotationTransform;
@property (assign, nonatomic) CGAffineTransform animationTranslationTransform;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.animationSpeed = self.speedSlider.value;
    self.animationTransform = self.animationView.transform = CGAffineTransformIdentity;
    self.animationRotationTransform = self.animationScaleTransform = self.animationTranslationTransform = CGAffineTransformIdentity;
    self.animationOptions = UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState;
    self.animationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld", self.imagesControl.selectedSegmentIndex]];
    self.speedSliderMin.text = [NSString stringWithFormat:@"%1.1f", self.speedSlider.minimumValue];
    self.speedSliderCurrent.text = [NSString stringWithFormat:@"%1.1f", self.speedSlider.value];
    self.animationScale = 1.f;
    self.scaleStatus = ASScaleStatusMin;
    self.animationMargin = 20;
    self.animationTranslationOffsetX = 0.f;
    self.animationTranslationOffsetY = 0.f;
    NSInteger imageSide = (int)(CGRectGetWidth(self.animationView.bounds)) / 2;
    self.animationTranslationArea = CGRectMake(self.animationMargin + imageSide, self.animationMargin + imageSide, (int)CGRectGetWidth(self.view.bounds) - 2 * (self.animationMargin + imageSide), (int)(CGRectGetHeight(self.view.bounds)/8*5) - 2 * (self.animationMargin + imageSide));
    
    self.animationTranslationPosition = CGPointMake(CGRectGetMidX(self.animationTranslationArea), CGRectGetMidY(self.animationTranslationArea));
    [self animateView];
    NSLog(@"viewDidLoad started...");
}

#pragma mark - Actions

- (IBAction)changedImageValue:(UISegmentedControl *)sender {
    
    self.animationView.backgroundColor = [UIColor clearColor];
    self.animationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld", self.imagesControl.selectedSegmentIndex]];
    NSLog(@"imageValue = %ld", self.imagesControl.selectedSegmentIndex);
}

- (IBAction)changedSpeedValue:(UISlider *)sender {
    
    self.animationSpeed = self.speedSlider.value;
    self.speedSliderCurrent.text = [NSString stringWithFormat:@"%1.1f", self.speedSlider.value];
}

- (IBAction)changedScaleValue:(UISwitch *)sender {
    
    (self.scaleSwitch.isOn) ? NSLog(@"scaleSwitch is On") : NSLog(@"scaleSwitch is Off");
}

- (IBAction)changedRotationValue:(UISwitch *)sender {
    
    (self.rotationSwitch.isOn) ? (self.animationRotationDirection = (arc4random() % 2 == 1) ? 1 : -1) : 0;
    (self.rotationSwitch.isOn) ? NSLog(@"rotationSwitch is On") : NSLog(@"rotationSwitch is Off");
    self.animationScaleCorrection = (self.rotationSwitch.isOn) ? 1.f : self.animationTransform.a;
}

#pragma mark - Private methods

- (void)animateView {
    
    // translation check
    [self defineImagePosition];
    
    // scale check
    self.animationScale = (self.scaleStatus == ASScaleStatusMin) ? (1.4f/1) : (1 / (1.4f*1));
    self.animationScale = (self.scaleSwitch.isOn) ? (self.animationScale / self.animationScaleCorrection) : 1.f;
    self.animationScaleTransform = CGAffineTransformMakeScale(self.animationScale, self.animationScale);
    self.animationScaleCorrection = 1.f;
    
    // rotation check
    self.animationTransform = CGAffineTransformConcat(self.animationScaleTransform, self.animationRotationTransform);
    self.animationTransform = CGAffineTransformConcat(self.animationTransform, self.animationTranslationTransform);
    self.animationRotationAngle = (self.rotationSwitch.isOn) ? ((120 * M_PI/180) * self.animationRotationDirection) : 0;
    self.animationRotationTransform = CGAffineTransformRotate(self.animationTransform, self.animationRotationAngle);
    self.animationTransform = self.animationRotationTransform;
    
    // animation
    [UIImageView animateWithDuration:self.animationSpeed
                               delay:0
                             options:self.animationOptions
                          animations:^{
        self.animationView.transform = self.animationTransform;
    }
                          completion:^(BOOL finished) {
        self.scaleStatus = (self.scaleStatus == ASScaleStatusMin) ? ASScaleStatusMax : ASScaleStatusMin;
        [self animateView];
    }];
}

- (void)defineImagePosition {
    
    if (self.translationSwitch.isOn) {
        self.animationTranslationOffsetX = (float)(arc4random() % 10 + 40) * ((arc4random() % 2 == 1) ? 1 : -1);
        self.animationTranslationOffsetY = (float)(arc4random() % 10 + 40) * ((arc4random() % 2 == 1) ? 1 : -1);
        
        CGPoint nextImagePosition = CGPointMake(self.animationTranslationPosition.x + self.animationTranslationOffsetX, self.animationTranslationPosition.y + self.animationTranslationOffsetY);
        
        if (CGRectContainsPoint(self.animationTranslationArea, nextImagePosition)) {
            
            self.animationTranslationTransform = CGAffineTransformMakeTranslation(self.animationTranslationOffsetX, self.animationTranslationOffsetY);
            self.animationTranslationPosition = nextImagePosition;
            NSLog(@"nextImagePosition = %@", NSStringFromCGPoint(nextImagePosition));
            
        } else {
            [self defineImagePosition];
        }
        
    } else {
        self.animationTranslationTransform = CGAffineTransformIdentity;
    }
}

@end
