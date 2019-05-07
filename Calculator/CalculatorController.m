//
//  CalculatorController.m
//  Calculator
//
//  Created by x.wang on 2019/5/7.
//  Copyright © 2019 x.wang. All rights reserved.
//

#import "CalculatorController.h"

#define CELL_W_H (([UIScreen mainScreen].bounds.size.width - 10) / 4)

@interface CalculatorCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *lab;
@property (nonatomic, strong) UIView *bg;

@end

@implementation CalculatorCell

- (UILabel *)lab {
    if (!_lab) {
        _lab = [[UILabel alloc] init];
        _lab.textAlignment = NSTextAlignmentCenter;
        _lab.font = [UIFont systemFontOfSize:30];
    }
    return _lab;
}

- (UIView *)bg {
    if (!_bg) {
        _bg = [[UIView alloc] init];
        _bg.layer.cornerRadius = (CELL_W_H-10)/2;
    }
    return _bg;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView addSubview:self.bg];
    [self.contentView addSubview:self.lab];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bg.frame = CGRectMake(5, 5, self.frame.size.width-10, CELL_W_H-10);
    self.lab.frame = CGRectMake(5, 5, CELL_W_H-10, CELL_W_H-10);
}

@end

@interface CalculatorController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *tips;
@property (weak, nonatomic) IBOutlet UILabel *input;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionHeight;

@property (strong, nonatomic) NSArray *datasource;
@property (strong, nonatomic) NSString *tipsStr;
@property (strong, nonatomic) NSString *inputStr;
@property (strong, nonatomic) NSIndexPath *idxP;
@property (strong, nonatomic) NSNumber *tempNum;

@end

@implementation CalculatorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _collectionHeight.constant = CELL_W_H * 5;
    _datasource = @[@[@"AC",@"±",@"%",@"÷"], @[@"7",@"8",@"9",@"×"], @[@"4",@"5",@"6",@"－"], @[@"1",@"2",@"3",@"＋"], @[@"0",@".",@"＝"]];
    _input.text = @"0";
    _tips.text = nil;
}


#pragma mark -

- (void)collectionCell:(CalculatorCell *)cell colorWithIndexPath:(NSIndexPath *)indexPath {
    NSArray *temp = self.datasource[indexPath.section];
    cell.lab.textColor = [UIColor whiteColor];
    if (indexPath.item == temp.count-1) {
        cell.bg.backgroundColor = [UIColor orangeColor];
        if (self.idxP && indexPath.section == self.idxP.section) {
            cell.bg.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            cell.lab.textColor = [UIColor orangeColor];
        }
    } else if (indexPath.section == 0) {
        cell.bg.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        cell.lab.textColor = [UIColor darkTextColor];
    } else {
        cell.bg.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    }
}

- (NSInteger)maxLengthWithInput:(NSString *)input {
    NSInteger max = 9;
    if ([input containsString:@"."]) {
        max += 1;
    }
    if ([input hasPrefix:@"-"]) {
        max += 1;
    }
    return max;
}

- (NSString *)formatStrFromNum:(NSNumber *)num {
    NSString *str = [NSString stringWithFormat:@"%@", num];
    str = str.lowercaseString;
    NSInteger max = [self maxLengthWithInput:str];
    if (str.length > max) {
        NSArray *arr = [str componentsSeparatedByString:@"."];
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        if (arr.count == 2 && (max - [arr.firstObject length] >= 4) && ![arr.firstObject containsString:@"e"]) {
            // 使用科学计数法
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            // 小数位最多位数
            numberFormatter.maximumFractionDigits = max - [arr.firstObject length] - 1;
            str = [numberFormatter stringFromNumber:num];
        } else {
            // 使用科学计数法
            numberFormatter.numberStyle = NSNumberFormatterScientificStyle;
            // 整数最少位数
            numberFormatter.minimumIntegerDigits = 1;
            // 小数位最多位数
            numberFormatter.maximumFractionDigits = 3;
            str = [numberFormatter stringFromNumber:num];
        }
    }
    if ([str containsString:@"."]) {
        NSString *theString = str;
        for(NSInteger i = theString.length-1; i >= 0; i--){
            NSRange range = NSMakeRange(i, 1);
            NSString *s = [theString substringWithRange:range];
            if ([s isEqualToString:@"0"] || [s isEqualToString:@"."]) {
                str = [str substringToIndex:i];
            } else {
                break;
            }
        }
    }
    return str;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.datasource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.datasource[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CalculatorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalculatorCell" forIndexPath:indexPath];
    cell.lab.text = self.datasource[indexPath.section][indexPath.item];
    [self collectionCell:cell colorWithIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4 && indexPath.item == 0) {
        return CGSizeMake(CELL_W_H * 2, CELL_W_H);
    }
    return CGSizeMake(CELL_W_H, CELL_W_H);
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    CalculatorCell *cell = (CalculatorCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSArray *temp = self.datasource[indexPath.section];
    if (indexPath.item == temp.count-1) {
        cell.bg.backgroundColor = [UIColor colorWithRed:1.0 green:0.7 blue:0.4 alpha:1.0];
    } else if (indexPath.section == 0) {
        cell.bg.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    } else {
        cell.bg.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    CalculatorCell *cell = (CalculatorCell *)[collectionView cellForItemAtIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf collectionCell:cell colorWithIndexPath:indexPath];
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *temp = self.datasource[indexPath.section];
    NSString *str = temp[indexPath.item];
    NSString *input = self.input.text;
    NSInteger max = [self maxLengthWithInput:input];
    if (indexPath.item == temp.count-1) {
        CGFloat a = input.floatValue;
        if (self.idxP) {
            CGFloat b = self.tempNum.floatValue;
            switch (self.idxP.section) {
                case 0: // ÷
                    b = b / a;
                    break;
                case 1: // x
                    b = b * a;
                    break;
                case 2: // -
                    b = b - a;
                    break;
                case 3: // +
                    b = b + a;
                    break;
                default:
                    break;
            }
            self.tempNum = [NSNumber numberWithFloat:b];
        } else {
            self.tempNum = [NSNumber numberWithFloat:a];
        }
        if (indexPath.section == 4) {
            self.idxP = nil;
            self.input.text = [self formatStrFromNum:self.tempNum];
            self.tempNum = nil;
            self.tips.text = nil;
        } else {
            self.idxP = indexPath;
            self.tips.text = [self formatStrFromNum:self.tempNum];
            self.input.text = @"0";
        }
    } else if (indexPath.section == 0) {
        switch (indexPath.item) {
            case 0: // AC
                self.input.text = @"0";
                self.tips.text = nil;
                self.tempNum = nil;
                self.idxP = nil;
                break;
            case 1: // ±
                if ([input containsString:@"-"]) {
                    self.input.text = [input stringByReplacingOccurrencesOfString:@"-" withString:@""];
                } else if (![input isEqualToString:@"0"]) {
                    self.input.text = [@"-" stringByAppendingString:input];
                }
                break;
            case 2: // %
                if (![input isEqualToString:@"0"]) {
                    CGFloat f = input.floatValue;
                    f = f * 0.01;
                    self.input.text = [self formatStrFromNum:[NSNumber numberWithFloat:f]];
                }
                break;
            default:
                break;
        }
    } else { // ., 0~9
        if (input.length == max) {
            return;
        }
        if ([str isEqualToString:@"."]) {
            // 已包含小数点
            if (![input containsString:@"."]) {
                input = [input stringByAppendingString:str];
            }
        } else if ([input isEqualToString:@"0"]){
            // 没有输入
            if (![str isEqualToString:@"0"]) {
                input = str;
            }
        } else {
            input = [input stringByAppendingString:str];
        }
        self.input.text = input;
    }
    [self.collectionView reloadData];
}

@end
