//
//  KKPinCodeTextField.m
//  KolesaKz
//
//  Created by Amirzhan on 30.06.17.ios
//  Copyright © 2017 Eugene Valeyev. All rights reserved.
//
#import "KKPinCodeTextField.h"
static const CGFloat KKTextFieldPadding = 20;
static const CGFloat KKDigitToBorderSpace = 10;
static const NSUInteger KKDefaultDigitsCount = 6;
static const CGFloat KKDefaultBorderHeight = 4;
static const CGFloat KKDefaultBordersSpacing = 10;
@interface KKPinCodeTextField() <UITextFieldDelegate>
@property (strong, nonatomic) NSMutableArray <CALayer *> *borders;
//@property (strong, nonatomic) NSMutableArray <CALayer *> *backgrounds;
@end
@implementation KKPinCodeTextField
@synthesize digitsCount = _digitsCount;
@synthesize borderHeight = _borderHeight;
@synthesize bordersSpacing = _bordersSpacing;
@synthesize filledDigitBorderColor = _filledDigitBorderColor;
@synthesize emptyDigitBorderColor = _emptyDigitBorderColor;
#pragma mark Initializers
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup {
    [self setupBorders];
    //    [self setupBackgrounds];
    [self configureDefaultValues];
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}
- (void)setupBorders {
    BOOL isRTL = [self isRightToLeft];
    NSUInteger highlightIndex = isRTL ? self.digitsCount - 1 : 0;

    // Remove existing borders
    for (CALayer *border in self.borders) {
        [border removeFromSuperlayer];
    }

    // Create new borders and highlight the first/last based on RTL or LTR
    self.borders = [NSMutableArray new];
    for (NSUInteger i = 0; i < self.digitsCount; i++) {
        CALayer *border = [CALayer layer];
        border.borderWidth = self.borderHeight;
        
        // Highlight the first border in LTR and the last border in RTL
        if (i == highlightIndex) {
            border.borderColor = self.filledDigitBorderColor.CGColor;
        } else {
            border.borderColor = self.emptyDigitBorderColor.CGColor;
        }

        [self.borders addObject:border];
        [self.layer addSublayer:border];
    }
}
- (void)updateBorderColor {
    [self configureBorderColorAtIndex:self.text.length];
}
- (void)configureDefaultValues {
    self.delegate = self;
    self.adjustsFontSizeToFitWidth = NO;
    self.keyboardType = UIKeyboardTypeNumberPad;
    self.textAlignment = NSTextAlignmentCenter;
    self.borderStyle = UITextBorderStyleNone;
}
- (BOOL)isRightToLeft {
    return [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
}
#pragma mark Overriden methods
- (void)layoutSubviews {
    [super layoutSubviews];
    for (int i = 0; i < self.borders.count; i++) {
        CALayer *border = self.borders[i];
        //        CALayer *background = self.backgrounds[i];
        CGFloat xPos = ([self borderWidth] + self.bordersSpacing) * i + KKTextFieldPadding;
        border.frame = CGRectMake(xPos, 0, [self borderWidth], CGRectGetHeight(self.frame) - self.borderHeight);
        border.cornerRadius = 12;
    }
}
- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.height += self.borderHeight * 2 + KKDigitToBorderSpace;
    return size;
}
- (BOOL)becomeFirstResponder {
    [self configureInitialSpacingAtIndex:self.text.length];
    return [super becomeFirstResponder];
}
#pragma mark Public methods
- (void)clearText {
    self.text = nil;
    for (int i = 0; i < self.borders.count; i++) {
        CALayer *border = self.borders[i];
        if (i == 0){
            border.borderColor = self.filledDigitBorderColor.CGColor;
        }else{
            border.borderColor = self.emptyDigitBorderColor.CGColor;
        }
    }
    [self configureInitialSpacingAtIndex:0];
}
#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *currentString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSUInteger length = [currentString length];
    if (![self isOnlyNumbersString:string]) {
        return NO;
    }
    if (length > self.digitsCount) {
        return NO;
    }
    return YES;
}
#pragma mark Actions
- (void)textFieldDidChange:(UITextField *)sender {
    NSUInteger length = sender.text.length;
    [self configureBorderColorAtIndex:length];
    [self configureInitialSpacingAtIndex:length];
    [self addSpacingToTextWithLength:length];
}
- (void)configureBorderColorAtIndex:(NSUInteger)index {
    BOOL isRTL = [self isRightToLeft];
    NSUInteger count = [_borders count];
    
    for (NSUInteger i = 0; i < count; i++) {
        CALayer *border = self.borders[i];
        NSUInteger adjustedIndex = isRTL ? (count - 1 - i) : i;

        // Highlight the next empty digit's border
        if (adjustedIndex == index) {
            border.borderColor = self.filledDigitBorderColor.CGColor;
        } else {
            border.borderColor = self.emptyDigitBorderColor.CGColor;
        }
    }
}
- (void)configureInitialSpacingAtIndex:(NSUInteger)index {
    NSTextAlignment alignment = [self isRightToLeft] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.textAlignment = alignment;
    if (index == 0) {
        [self addInitialSpacing:KKTextFieldPadding];
    } else if (index == 1) {
        NSDictionary *userAttributes = @{NSFontAttributeName: self.font};
        CGFloat textWidth = [self.text sizeWithAttributes: userAttributes].width;
        CGFloat spacing = ([self borderWidth] - textWidth) / 2 + KKTextFieldPadding;
        [self addInitialSpacing:spacing];
    } else if (index == self.digitsCount) {
        [self addInitialSpacing:35.5];
    }
}
- (void)addSpacingToTextWithLength:(NSUInteger)length {
    if (length == 0) {
        self.attributedText = [[NSAttributedString alloc] initWithString:@""];
        return;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName: self.font}];
    
    CGFloat totalCellWidth = [self borderWidth] + self.bordersSpacing;
    
    for (NSUInteger i = 0; i < length; i++) {
        CGFloat charWidth = [self widthForCharacterAtIndex:i inString:self.text];
        CGFloat nextCharWidth = i < length - 1 ? [self widthForCharacterAtIndex:i + 1 inString:self.text] : 0;
        CGFloat spacing = (totalCellWidth - charWidth) / 2 + (totalCellWidth - nextCharWidth) / 2;
        
        if (i < length - 1) {
            [attributedString addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(i, 1)];
        }
    }
    
    self.attributedText = attributedString;
}
- (CGFloat)widthForCharacterAtIndex:(NSUInteger)index inString:(NSString *)string {
    if (index >= string.length) return 0;
    
    NSRange range = NSMakeRange(index, 1);
    NSString *character = [string substringWithRange:range];
    NSDictionary *attributes = @{NSFontAttributeName: self.font};
    CGSize size = [character sizeWithAttributes:attributes];
    
    return size.width;
}
- (CGFloat)widthForSingleCharacter {
    NSDictionary *userAttributes = @{NSFontAttributeName: self.font};
    NSString *singleChar = @"0";
    CGSize size = [singleChar sizeWithAttributes:userAttributes];
    return size.width;
}
- (CGFloat)spacingToDigitAtIndex:(NSUInteger)index attributedText:(NSMutableAttributedString *)attributedString {
    NSDictionary *userAttributes = @{NSFontAttributeName: self.font};
    NSString *text = [attributedString.string substringWithRange:NSMakeRange(index, 1)];
    CGFloat textWidth = [text sizeWithAttributes:userAttributes].width;
    CGFloat textSpacing = ([self borderWidth] - textWidth) / 2;
    return textSpacing;
}
#pragma mark Property getters/setters
- (NSUInteger)digitsCount {
    if (!_digitsCount) {
        return KKDefaultDigitsCount;
    }
    return _digitsCount;
}
- (void)setDigitsCount:(NSUInteger)digitsCount {
    _digitsCount = digitsCount;
    [self clearText];
    [self setupBorders];
}
- (CGFloat)borderHeight {
    if (!_borderHeight) {
        return KKDefaultBorderHeight;
    }
    return _borderHeight;
}
- (void)setBorderHeight:(CGFloat)borderHeight {
    _borderHeight = borderHeight;
    [self clearText];
    [self setupBorders];
}
- (CGFloat)bordersSpacing {
    if (!_bordersSpacing) {
        return KKDefaultBordersSpacing;
    }
    return _bordersSpacing;
}
- (void)setBordersSpacing:(CGFloat)bordersSpacing {
    _bordersSpacing = bordersSpacing;
    [self clearText];
    [self layoutIfNeeded];
}
- (UIColor *)filledDigitBorderColor {
    if (!_filledDigitBorderColor) {
        return UIColor.lightGrayColor;
    }
    return _filledDigitBorderColor;
}
- (void)setFilledDigitBorderColor:(UIColor *)filledDigitBorderColor {
    _filledDigitBorderColor = filledDigitBorderColor;
    [self configureBorderColors];
}
- (UIColor *)emptyDigitBorderColor {
    if (!_emptyDigitBorderColor) {
        return UIColor.redColor;
    }
    return _emptyDigitBorderColor;
}
- (void)setEmptyDigitBorderColor:(UIColor *)emptyDigitBorderColor {
    _emptyDigitBorderColor = emptyDigitBorderColor;
    [self configureBorderColors];
}
- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    super.delegate = self;
}
- (void)setAdjustsFontSizeToFitWidth:(BOOL)adjustsFontSizeToFitWidth {
    super.adjustsFontSizeToFitWidth = NO;
}
- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    super.keyboardType = UIKeyboardTypeNumberPad;
}
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if ([self isRightToLeft]) {
        super.textAlignment = NSTextAlignmentRight;
    } else {
        super.textAlignment = NSTextAlignmentLeft;
    }
}
- (void)setBorderStyle:(UITextBorderStyle)borderStyle {
    super.borderStyle = UITextBorderStyleNone;
}
#pragma mark Private methods
- (CGFloat)borderWidth {
    CGFloat totalSpacing = (self.digitsCount - 1) * self.bordersSpacing;
    return (CGRectGetWidth(self.frame) - KKTextFieldPadding * 2 - totalSpacing) / self.digitsCount;
}
- (void)addInitialSpacing:(CGFloat)width {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = paddingView;
}
- (BOOL)isOnlyNumbersString:(NSString *)string {
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [string rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}
- (void)configureBorderColors {
    for (CALayer *border in self.borders) {
        NSUInteger count = [self.borders indexOfObject:border];
        BOOL isFilled = self.text.length > count;
        border.borderColor = isFilled ? self.filledDigitBorderColor.CGColor : self.emptyDigitBorderColor.CGColor;
    }
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
        [self setupBorders];
        
        [self configureBorderColorAtIndex:self.text.length];
    }
}
@end
