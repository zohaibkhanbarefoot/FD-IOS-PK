//
//  LMGaugeView.m
//  LMGaugeView
//
//  Created by LMinh on 01/08/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMGaugeView.h"

#define kDefaultStartAngle                      M_PI_4
#define kDefaultEndAngle                        M_PI_4
#define kDefaultMinValue                        0
#define kDefaultMaxValue                        100
#define kDefaultLimitValue                      50
#define kDefaultNumOfDivisions                  0
#define kDefaultNumOfSubDivisions               0

#define kDefaultRingThickness                   15
#define kDefaultRingBackgroundColor             [UIColor colorWithWhite:0.9 alpha:1]
#define kDefaultRingColor                       [UIColor colorWithRed:133.0/255.0 green:193.0/255.0 blue:233.0/255.0 alpha:1.0]

#define kDefaultDivisionsRadius                 1.25
#define kDefaultDivisionsColor                  [UIColor colorWithWhite:0.5 alpha:1]
#define kDefaultDivisionsPadding                12

#define kDefaultSubDivisionsRadius              0.75
#define kDefaultSubDivisionsColor               [UIColor colorWithWhite:0.5 alpha:0.5]

#define kDefaultLimitDotRadius                  2
#define kDefaultLimitDotColor                   [UIColor redColor]

#define kDefaultValueFont                       [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:60]
#define kDefaultValueTextColor                  [UIColor colorWithWhite:0.1 alpha:1]

#define kDefaultUnitOfMeasurement               @"DISTRACTIONS"
#define kDefaultUnitOfMeasurementFont           [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15]
#define kDefaultUnitOfMeasurementTextColor      [UIColor colorWithWhite:0.3 alpha:1]
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
@interface LMGaugeView ()
// For calculation
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) CGFloat divisionUnitAngle;
@property (nonatomic, assign) CGFloat divisionUnitValue;

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *unitOfMeasurementLabel;
/*@property CGFloat startAngle =
 @property CGFloat endAngle = degreesToRadians(640);*/
@end

@implementation LMGaugeView

#pragma mark - INIT

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    if (!self.backgroundColor) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    // Set default values
    _startAngle = degreesToRadians(270);//kDefaultStartAngle;
    _endAngle = degreesToRadians(640);//kDefaultEndAngle;
    
    _value = kDefaultMinValue;
    _minValue = kDefaultMinValue;
    _maxValue = kDefaultMaxValue;
    _limitValue = kDefaultLimitValue;
    _numOfDivisions = kDefaultNumOfDivisions;
    _numOfSubDivisions = kDefaultNumOfSubDivisions;
    
    // Ring
    _ringThickness = kDefaultRingThickness;
    _ringBackgroundColor = kDefaultRingBackgroundColor;
    
    // Divisions
    _divisionsRadius = kDefaultDivisionsRadius;
    _divisionsColor = kDefaultDivisionsColor;
    _divisionsPadding = kDefaultDivisionsPadding;
    
    // Subdivisions
    _subDivisionsRadius = kDefaultSubDivisionsRadius;
    _subDivisionsColor = kDefaultSubDivisionsColor;
    
    // Limit dot
    _showLimitDot = YES;
    _limitDotRadius = kDefaultLimitDotRadius;
    _limitDotColor = kDefaultLimitDotColor;
    
    // Value Text
    _valueFont = kDefaultValueFont;
    _valueTextColor = kDefaultValueTextColor;
    
    // Unit Of Measurement
    _showUnitOfMeasurement = YES;
    _unitOfMeasurement = kDefaultUnitOfMeasurement;
    _unitOfMeasurementFont = kDefaultUnitOfMeasurementFont;
    _unitOfMeasurementTextColor = kDefaultUnitOfMeasurementTextColor;
}


#pragma mark - ANIMATION

- (void)strokeGauge
{
    /*!
     *  Set progress for ring layer
     */
    CGFloat progress = self.maxValue ? (self.value - self.minValue)/(self.maxValue - self.minValue) : 0;
    self.progressLayer.strokeEnd = progress;
    
    /*!
     *  Set ring stroke color
     */
    UIColor *ringColor = kDefaultRingColor;
    if (self.delegate && [self.delegate respondsToSelector:@selector(gaugeView:ringStokeColorForValue:)]) {
        ringColor = [self.delegate gaugeView:self ringStokeColorForValue:self.value];
    }
    self.progressLayer.strokeColor = ringColor.CGColor;
}


#pragma mark - CUSTOM DRAWING

- (void)drawRect:(CGRect)rect
{
    /*!
     *  Prepare drawing
     */
    self.divisionUnitValue = self.numOfDivisions ? (self.maxValue - self.minValue)/self.numOfDivisions : 0;
    self.divisionUnitAngle = self.numOfDivisions ? (M_PI * 2 - ABS(self.endAngle - self.startAngle))/self.numOfDivisions : 0;
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    CGFloat ringRadius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2 - self.ringThickness/2;
    //CGFloat dotRadius = ringRadius - self.ringThickness/2 - self.divisionsPadding - self.divisionsRadius/2;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /*!
     *  Draw the ring background
     */
    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, 0, M_PI * 2, 0);
    CGContextSetStrokeColorWithColor(context, [self.ringBackgroundColor colorWithAlphaComponent:0.3].CGColor);
    CGContextStrokePath(context);
    
    /*!
     *  Draw the ring progress background
     */
    CGContextSetLineWidth(context, self.ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, self.startAngle, self.endAngle, 0);
    CGContextSetStrokeColorWithColor(context, self.ringBackgroundColor.CGColor);
    CGContextStrokePath(context);
    
    /*!
     *  Draw divisions and subdivisions
     */
    
    /*!
     *  Progress Layer
     */
    if (!self.progressLayer)
    {
        self.progressLayer = [CAShapeLayer layer];
        self.progressLayer.contentsScale = [[UIScreen mainScreen] scale];
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.lineCap = kCALineJoinBevel;
        self.progressLayer.lineJoin = kCALineJoinBevel;
        [self.layer addSublayer:self.progressLayer];
        self.progressLayer.strokeEnd = 0;
    }
    self.progressLayer.frame = CGRectMake(center.x - ringRadius - self.ringThickness/2,
                                          center.y - ringRadius - self.ringThickness/2,
                                          (ringRadius + self.ringThickness/2) * 2,
                                          (ringRadius + self.ringThickness/2) * 2);
    self.progressLayer.bounds = self.progressLayer.frame;
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:self.progressLayer.position
                                                                radius:ringRadius
                                                            startAngle:_startAngle
                                                              endAngle:_endAngle
                                                             clockwise:YES];
    self.progressLayer.path = smoothedPath.CGPath;
    self.progressLayer.lineWidth = self.ringThickness;
    
    /*!
     *  Value Label
     */
    if (!self.valueLabel)
    {
        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.backgroundColor = [UIColor clearColor];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        self.valueLabel.text = [NSString stringWithFormat:@"%0.f", self.value];
        self.valueLabel.font = self.valueFont;
        self.valueLabel.adjustsFontSizeToFitWidth = YES;
        self.valueLabel.minimumScaleFactor = 5/self.valueLabel.font.pointSize;
        self.valueLabel.textColor = [UIColor colorWithRed:40.0/255.0 green:116.0/255.0 blue:166.0/255.0 alpha:1.0];
        
        [self addSubview:self.valueLabel];
    }
    
    
    CGFloat insetX = self.ringThickness + self.divisionsPadding * 2 + self.divisionsRadius;
    self.valueLabel.frame = CGRectInset(self.progressLayer.frame, insetX, insetX);
    self.valueLabel.frame = CGRectOffset(self.valueLabel.frame, 0, self.showUnitOfMeasurement ? -self.divisionsPadding/2 : 0);
    
    /*!
     *  Unit Of Measurement Label
     */
    if (!self.unitOfMeasurementLabel)
    {
        self.unitOfMeasurementLabel = [[UILabel alloc] init];
        self.unitOfMeasurementLabel.backgroundColor = [UIColor clearColor];
        self.unitOfMeasurementLabel.textAlignment = NSTextAlignmentCenter;
        self.unitOfMeasurementLabel.text = self.unitOfMeasurement;
        self.unitOfMeasurementLabel.font = self.unitOfMeasurementFont;
        self.unitOfMeasurementLabel.adjustsFontSizeToFitWidth = YES;
        self.unitOfMeasurementLabel.minimumScaleFactor = 5/self.unitOfMeasurementLabel.font.pointSize;
        self.unitOfMeasurementLabel.textColor = [UIColor colorWithRed:40.0/255.0 green:116.0/255.0 blue:166.0/255.0 alpha:1.0];
        
        [self addSubview:self.unitOfMeasurementLabel];
        self.unitOfMeasurementLabel.hidden = !self.showUnitOfMeasurement;
    }
    self.unitOfMeasurementLabel.frame = CGRectMake(self.valueLabel.frame.origin.x,
                                                   self.valueLabel.frame.origin.y + CGRectGetHeight(self.valueLabel.frame) - 10,
                                                   CGRectGetWidth(self.valueLabel.frame),
                                                   20);
}


#pragma mark - SUPPORT

- (CGFloat)angleFromValue:(CGFloat)value
{
    CGFloat level = self.divisionUnitValue ? (value - self.minValue)/self.divisionUnitValue : 0;
    CGFloat angle = level * self.divisionUnitAngle + self.startAngle;
    return angle;
}

- (void)drawDotAtContext:(CGContextRef)context
                  center:(CGPoint)center
                  radius:(CGFloat)radius
               fillColor:(CGColorRef)fillColor
{
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, 0, M_PI * 2, 0);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextFillPath(context);
}


#pragma mark - PROPERTIES

- (void)setValue:(CGFloat)value
{
    _value = MIN(value, _maxValue);
    _value = MAX(_value, _minValue);
    
    /*!
     *  Set text for value label
     */
    self.valueLabel.text = [NSString stringWithFormat:@"%0.f", _distractions];
    
    /*!
     *  Trigger the stoke animation of ring layer.
     */
    [self strokeGauge];
}

- (void)setMinValue:(CGFloat)minValue
{
    if (_minValue != minValue && minValue < _maxValue) {
        _minValue = minValue;
        
        [self setNeedsDisplay];
    }
}

- (void)setMaxValue:(CGFloat)maxValue
{
    if (_maxValue != maxValue && maxValue > _minValue) {
        _maxValue = maxValue;
        
        [self setNeedsDisplay];
    }
}

- (void)setLimitValue:(CGFloat)limitValue
{
    if (_limitValue != limitValue && limitValue >= _minValue && limitValue <= _maxValue) {
        _limitValue = limitValue;
        
        [self setNeedsDisplay];
    }
}

- (void)setNumOfDivisions:(NSUInteger)numOfDivisions
{
    if (_numOfDivisions != numOfDivisions) {
        _numOfDivisions = numOfDivisions;
        
        [self setNeedsDisplay];
    }
}

- (void)setNumOfSubDivisions:(NSUInteger)numOfSubDivisions
{
    if (_numOfSubDivisions != numOfSubDivisions) {
        _numOfSubDivisions = numOfSubDivisions;
        
        [self setNeedsDisplay];
    }
}

- (void)setRingThickness:(CGFloat)ringThickness
{
    if (_ringThickness != ringThickness) {
        _ringThickness = ringThickness;
        
        [self setNeedsDisplay];
    }
}

- (void)setRingBackgroundColor:(UIColor *)ringBackgroundColor
{
    if (_ringBackgroundColor != ringBackgroundColor) {
        _ringBackgroundColor = ringBackgroundColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setDivisionsRadius:(CGFloat)divisionsRadius
{
    if (_divisionsRadius != divisionsRadius) {
        _divisionsRadius = divisionsRadius;
        
        [self setNeedsDisplay];
    }
}

- (void)setDivisionsColor:(UIColor *)divisionsColor
{
    if (_divisionsColor != divisionsColor) {
        _divisionsColor = divisionsColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setDivisionsPadding:(CGFloat)divisionsPadding
{
    if (_divisionsPadding != divisionsPadding) {
        _divisionsPadding = divisionsPadding;
        
        [self setNeedsDisplay];
    }
}

- (void)setSubDivisionsRadius:(CGFloat)subDivisionsRadius
{
    if (_subDivisionsRadius != subDivisionsRadius) {
        _subDivisionsRadius = subDivisionsRadius;
        
        [self setNeedsDisplay];
    }
}

- (void)setSubDivisionsColor:(UIColor *)subDivisionsColor
{
    if (_subDivisionsColor != subDivisionsColor) {
        _subDivisionsColor = subDivisionsColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setShowLimitDot:(BOOL)showLimitDot
{
    if (_showLimitDot != showLimitDot) {
        _showLimitDot = showLimitDot;
        
        [self setNeedsDisplay];
    }
}

- (void)setLimitDotRadius:(CGFloat)limitDotRadius
{
    if (_limitDotRadius != limitDotRadius) {
        _limitDotRadius = limitDotRadius;
        
        [self setNeedsDisplay];
    }
}

- (void)setLimitDotColor:(UIColor *)limitDotColor
{
    if (_limitDotColor != limitDotColor) {
        _limitDotColor = limitDotColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setValueFont:(UIFont *)valueFont
{
    if (_valueFont != valueFont) {
        _valueFont = valueFont;
        
        self.valueLabel.font = _valueFont;
        self.valueLabel.minimumScaleFactor = 10/_valueFont.pointSize;
    }
}

- (void)setValueTextColor:(UIColor *)valueTextColor
{
    if (_valueTextColor != valueTextColor) {
        _valueTextColor = valueTextColor;
        
        self.valueLabel.textColor = _valueTextColor;
    }
}

- (void)setShowUnitOfMeasurement:(BOOL)showUnitOfMeasurement
{
    if (_showUnitOfMeasurement != showUnitOfMeasurement) {
        _showUnitOfMeasurement = showUnitOfMeasurement;
        
        self.unitOfMeasurementLabel.hidden = !_showUnitOfMeasurement;
    }
}

- (void)setUnitOfMeasurement:(NSString *)unitOfMeasurement
{
    if (_unitOfMeasurement != unitOfMeasurement) {
        _unitOfMeasurement = unitOfMeasurement;
        
        self.unitOfMeasurementLabel.text = _unitOfMeasurement;
    }
}

- (void)setUnitOfMeasurementFont:(UIFont *)unitOfMeasurementFont
{
    if (_unitOfMeasurementFont != unitOfMeasurementFont) {
        _unitOfMeasurementFont = unitOfMeasurementFont;
        
        self.unitOfMeasurementLabel.font = _unitOfMeasurementFont;
        self.unitOfMeasurementLabel.minimumScaleFactor = 10/_unitOfMeasurementFont.pointSize;
    }
}

- (void)setUnitOfMeasurementTextColor:(UIColor *)unitOfMeasurementTextColor
{
    if (_unitOfMeasurementTextColor != unitOfMeasurementTextColor) {
        _unitOfMeasurementTextColor = unitOfMeasurementTextColor;
        
        self.unitOfMeasurementLabel.textColor = _unitOfMeasurementTextColor;
    }
}

@end
