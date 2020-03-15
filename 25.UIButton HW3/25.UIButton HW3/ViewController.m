//
//  ViewController.m
//  25.UIButton HW3
//
//  Created by Александр on 04.02.2020.
//  Copyright © 2020 Badmaev. All rights reserved.
//

#import "ViewController.h"

typedef enum {
    CalculatorButtonPoint           = 10,
    CalculatorButtonSign            = 11,
    CalculatorButtonPersent         = 12,
    CalculatorButtonDivision        = 13,
    CalculatorButtonMultipliction   = 14,
    CalculatorButtonSubtraction     = 15,
    CalculatorButtonAddition        = 16,
    CalculatorButtonEqual           = 17,
    CalculatorButtonReset           = 20,
} CalculatorButton;

typedef enum {
    LastMathOperationPersent        = 1,
    LastMathOperationDivision       = 2,
    LastMathOperationMultiplication = 3,
    LastMathOperationSubtraction    = 4,
    LastMathOperationAddition       = 5
} LastMathOperation;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel* calculatorDisplayLabel;
@property (weak, nonatomic) IBOutlet UILabel* operationDisplayLabel;
@property (weak, nonatomic) IBOutlet UIButton *zeroButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* allButtons;

@property (assign, nonatomic) double firstNumber;
@property (assign, nonatomic) double secondNumber;
@property (strong, nonatomic) NSMutableString* typeNumber;
@property (assign, nonatomic) NSUInteger lastMathOperation;
@property (assign, nonatomic) BOOL typeNextNumber;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstNumber = (double)0.f;
    self.secondNumber = (double)0.f;
    self.lastMathOperation = 0;
    self.typeNumber = [NSMutableString string];
    
    for (UIButton* button in self.allButtons) {
        button.layer.cornerRadius = CGRectGetWidth(button.frame)/2;
    }
    self.zeroButton.layer.cornerRadius = CGRectGetHeight(self.zeroButton.frame)/2;
    
    self.calculatorDisplayLabel.adjustsFontSizeToFitWidth = YES;
    self.calculatorDisplayLabel.text = @"0";
}

#pragma mark - Auxiliary Methods

- (void)appendNumberToString:(NSInteger)numberButton {
    // метод добавляет в конец строки цифру которую нажимаем на экране
    
    // поиск точки в строке
    NSRange seekPoint = [self.typeNumber rangeOfString:@"."];
    
    switch (numberButton) {
        case 0:
            [self.typeNumber appendString:@"0"];
            break;
        case 1:
            [self.typeNumber appendString:@"1"];
            break;
        case 2:
            [self.typeNumber appendString:@"2"];
            break;
        case 3:
            [self.typeNumber appendString:@"3"];
            break;
        case 4:
            [self.typeNumber appendString:@"4"];
            break;
        case 5:
            [self.typeNumber appendString:@"5"];
            break;
        case 6:
            [self.typeNumber appendString:@"6"];
            break;
        case 7:
            [self.typeNumber appendString:@"7"];
            break;
        case 8:
            [self.typeNumber appendString:@"8"];
            break;
        case 9:
            [self.typeNumber appendString:@"9"];
            break;
        case CalculatorButtonPoint:
            // если точка найдена
            if (seekPoint.location == NSNotFound) {
                // и точка является первой кнопкой которую мы нажимаем
                if ([self.typeNumber length] == 0) {
                    [self.typeNumber appendString:@"0."];
                } else {
                    [self.typeNumber appendString:@"."];
                }
            }
            break;
        default:
            break;
    }
    self.calculatorDisplayLabel.text = self.typeNumber;
}

- (void)setMathOperationWithTag:(UIButton*)sender withEqualOperation:(BOOL)needEqualOperation {
    // в методе реализуется возможность смены математической операции, если не было введено второе число. Иначе нажатие кнопки с математической операцией вызывает метод действия кнопки "="
    
    double signValue;
    
    switch (sender.tag) {
        case CalculatorButtonAddition:
            if (needEqualOperation) {
                [self actionEqual:sender];
            }
            self.operationDisplayLabel.text = [NSString stringWithFormat:@"+"];
            self.lastMathOperation = LastMathOperationAddition;
            break;
        case CalculatorButtonSubtraction:
            if (needEqualOperation) {
                [self actionEqual:sender];
            }
            self.operationDisplayLabel.text = [NSString stringWithFormat:@"-"];
            self.lastMathOperation = LastMathOperationSubtraction;
            break;
        case CalculatorButtonMultipliction:
            if (needEqualOperation) {
                [self actionEqual:sender];
            }
            self.operationDisplayLabel.text = [NSString stringWithFormat:@"*"];
            self.lastMathOperation = LastMathOperationMultiplication;
            break;
        case CalculatorButtonDivision:
            if (needEqualOperation) {
                [self actionEqual:sender];
            }
            self.operationDisplayLabel.text = [NSString stringWithFormat:@"/"];
            self.lastMathOperation = LastMathOperationDivision;
            break;
        case CalculatorButtonPersent:
            if (needEqualOperation) {
                [self actionEqual:sender];
            }
            self.operationDisplayLabel.text = [NSString stringWithFormat:@"%%"];
            self.lastMathOperation = LastMathOperationPersent;
            break;
        case CalculatorButtonSign:
            // рализация нажатия "+/-"
            signValue = [self.typeNumber doubleValue] - [self.typeNumber doubleValue] * 2;
            self.typeNumber = [NSMutableString string];
            [self.typeNumber appendString:[NSString stringWithFormat:@"%.14g", signValue]];
            self.calculatorDisplayLabel.text = [NSString stringWithFormat:@"%.14g", signValue];
            break;
        default:
            self.calculatorDisplayLabel.text = @"ERROR";
            break;
    }
}

#pragma mark - Actions

- (IBAction)typeNumberButton:(UIButton*)sender {
    
    // проверка состояния:"была ли нажата кнопка с математическими операциями", если да, то запоминаем первое число
    if (self.typeNextNumber) {
        self.firstNumber = [self.typeNumber doubleValue];
        self.typeNumber = [NSMutableString string];
    }
    
    // проверка: начинаем ли вводить новое число. С помощью этой проверки обходим ошибку, когда у второго числа не нажимается ноль
    if ([self.typeNumber length] == 0) {
        // если ноль это первая цифра которую нажимаем, то ничего не происходит
        if (!(sender.tag == 0)) {
            [self appendNumberToString:sender.tag];
        }
    } else {
        [self appendNumberToString:sender.tag];
    }
    
    // продолжаем вводить число
    self.typeNextNumber = NO;
}

- (IBAction)actionResetButton:(UIButton*)sender {
    // реализация кнопки АС
    self.calculatorDisplayLabel.text = @"0";
    self.operationDisplayLabel.text = @" ";
    self.firstNumber = (double)0.f;
    self.secondNumber = (double)0.f;
    self.typeNumber = [NSMutableString string];
}

- (IBAction)actionArithmeticOperations:(UIButton*)sender {
    // ставим метку что было нажатие на кнопку с математической операции, следовательно необходимо запомнить число и быть готовым к набору нового. Это действие реализуется в другом методе -(IBAction)typeNumberButton:(UIButton*)sender, что позволяет нам выбирать математическое действие несколько раз
    self.typeNextNumber = YES;
    
    // если первое число уже "запомнили", то нажатие кнопки с математической операцией вызывает метод с действием кнопки "=", иначе мы можем просто менять действие
    if (self.firstNumber) {
        [self setMathOperationWithTag:sender withEqualOperation:YES];
    } else {
        [self setMathOperationWithTag:sender withEqualOperation:NO];
    }
}

- (IBAction)actionEqual:(UIButton*)sender {
    
    self.secondNumber = [self.typeNumber doubleValue];
    self.typeNumber = [NSMutableString string];
    double result;
    
    switch (self.lastMathOperation) {
        case LastMathOperationAddition:
            result = self.firstNumber + self.secondNumber;
            break;
        case LastMathOperationSubtraction:
            result = self.firstNumber - self.secondNumber;
            break;
        case LastMathOperationMultiplication:
            result = self.firstNumber * self.secondNumber;
            break;
        case LastMathOperationDivision:
            result = self.firstNumber / self.secondNumber;
            break;
        case LastMathOperationPersent:
            result = self.firstNumber / 100 * self.secondNumber;
            break;
        default:
            result = 0.f;
            break;
    }
    self.calculatorDisplayLabel.text = [NSString stringWithFormat:@"%.14g", (double)result];
    self.operationDisplayLabel.text = @" ";
    self.firstNumber = 0.f;
    self.secondNumber = 0.f;
    [self.typeNumber appendString:[NSString stringWithFormat:@"%.14g", (double)result]];
    self.typeNextNumber = YES;
}

@end
