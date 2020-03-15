//
//  ViewController.h
//  26.Controls HW2
//
//  Created by Александр on 05.02.2020.
//  Copyright © 2020 Badmaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *animationView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *imagesControl;
@property (weak, nonatomic) IBOutlet UISwitch *translationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *scaleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *rotationSwitch;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (weak, nonatomic) IBOutlet UILabel *speedSliderMin;
@property (weak, nonatomic) IBOutlet UILabel *speedSliderCurrent;

- (IBAction)changedImageValue:(UISegmentedControl *)sender;
- (IBAction)changedScaleValue:(UISwitch *)sender;
- (IBAction)changedRotationValue:(UISwitch *)sender;
- (IBAction)changedSpeedValue:(UISlider *)sender;

@end

