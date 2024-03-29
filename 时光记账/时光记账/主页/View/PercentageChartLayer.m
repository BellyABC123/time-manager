//
//  PercentageChartLayer.m
//  PercentageChart
//
//  Created by Xavi Gil on 10/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PercentageChartLayer.h"

@implementation PercentageChartLayer

@dynamic percentage;

@synthesize text;

@synthesize mainColor;
@synthesize secondaryColor;
@synthesize lineColor;

@synthesize fontName;
@synthesize fontSize;


- (id)initWithLayer:(id)aLayer 
{
    if (self = [super initWithLayer:aLayer]) 
    {
        if ([aLayer isKindOfClass:[PercentageChartLayer class]]) 
        {            
            PercentageChartLayer *layer = (PercentageChartLayer *)aLayer;
            
            if ([layer respondsToSelector:@selector(setContentsScale:)])
            {
                layer.contentsScale = [[UIScreen mainScreen] scale];
            }
            
            self.percentage = layer.percentage;
            
            self.text = layer.text;
            
            self.mainColor = layer.mainColor;
            self.secondaryColor = layer.secondaryColor;            
            self.lineColor = layer.lineColor;         
            
            self.fontName = layer.fontName;
            self.fontSize = layer.fontSize;
        }
    }
    
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key 
{    
    if( [key isEqualToString:@"percentage"] )
        return YES;
    
    return [super needsDisplayForKey:key];
}

-(void)drawInContext:(CGContextRef)ctx 
{
    CGSize sizeControl = [@"sample" sizeWithFont:[UIFont fontWithName:self.fontName size:self.fontSize] constrainedToSize:self.frame.size];
    
    CGPoint center = CGPointMake( self.bounds.size.width/2, self.bounds.size.height - sizeControl.height - 10.0 );
    CGFloat radius = MIN( center.x, center.y ) - 1;

    CGFloat startingAngleRad = DEG2RAD( INITIAL_ANGLE );
    CGFloat endingAngleRad = DEG2RAD( ENDING_ANGLE );
    CGFloat currentAngle = INITIAL_ANGLE + ( INITIAL_ANGLE * self.percentage/100.0 );
    CGFloat currentAngleRad = DEG2RAD( currentAngle );
    
    CGPoint startingPoint = CGPointMake( center.x + radius * cosf(startingAngleRad), center.y + radius * sinf(startingAngleRad) );
    CGPoint endPoint = CGPointMake( center.x + radius * cosf(currentAngleRad) , center.y + radius * sinf(currentAngleRad) );
    
    // Arc
    CGContextBeginPath( ctx );
    CGContextMoveToPoint( ctx, center.x, center.y );    
    CGContextAddLineToPoint( ctx, startingPoint.x, startingPoint.y );
    CGContextAddArc( ctx, center.x, center.y, radius, startingAngleRad, currentAngleRad, NO );
    CGContextClosePath(ctx);
    
    CGContextSetFillColorWithColor( ctx, self.mainColor.CGColor );
    CGContextSetStrokeColorWithColor( ctx, self.mainColor.CGColor );
    CGContextSetLineWidth( ctx, 1 );
    
    CGContextDrawPath( ctx, kCGPathFillStroke );
    
    // Background
    CGContextBeginPath( ctx );
    CGContextMoveToPoint( ctx, center.x, center.y );    
    CGContextAddLineToPoint( ctx, endPoint.x, endPoint.y );
    CGContextAddArc( ctx, center.x, center.y, radius, currentAngleRad, endingAngleRad, NO );
    CGContextClosePath(ctx);
    
    CGContextSetFillColorWithColor( ctx, self.secondaryColor.CGColor );
    CGContextSetStrokeColorWithColor( ctx, self.secondaryColor.CGColor );
    CGContextSetLineWidth( ctx, 1 );
    
    CGContextDrawPath( ctx, kCGPathFillStroke );

    // Center & progress line
    CGContextBeginPath( ctx );    
    CGContextMoveToPoint( ctx, center.x, center.y );
    CGRect rect = CGRectMake( center.x - CENTER_WIDTH/2, center.y - CENTER_WIDTH/2, CENTER_WIDTH, CENTER_WIDTH );
    CGContextAddEllipseInRect( ctx, rect );
    CGContextMoveToPoint( ctx, center.x, center.y );
    CGContextAddLineToPoint( ctx, endPoint.x, endPoint.y );
    
    CGContextClosePath(ctx);
    
    CGContextSetFillColorWithColor( ctx, self.lineColor.CGColor );
    CGContextSetStrokeColorWithColor( ctx, self.lineColor.CGColor );
    CGContextSetLineCap( ctx, kCGLineCapRound );
    CGContextSetLineWidth( ctx, 3 );
    
    CGContextDrawPath( ctx, kCGPathFillStroke );
    
    CGContextSetTextMatrix( ctx, CGAffineTransformMakeScale( 1.0, -1.0 ));
    
    NSString *str = [NSString stringWithFormat:@"%.1f%@ %@", self.percentage, @"%", self.text];
    CGSize strSize = [str sizeWithFont:[UIFont fontWithName:self.fontName size:self.fontSize] 
                     constrainedToSize:self.frame.size];
    
    CTFontRef sysUIFont = CTFontCreateWithName( (__bridge CFStringRef)self.fontName, self.fontSize, NULL ); 
    
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)sysUIFont, (id)kCTFontAttributeName,
                                    self.mainColor.CGColor, (id)kCTForegroundColorAttributeName, nil];    
    NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:str 
                                                               attributes:attributesDict];
    
    CTLineRef lineref = CTLineCreateWithAttributedString( (__bridge CFAttributedStringRef)attributedStr );
    CGContextSetTextPosition( ctx, center.x - ( strSize.width/2.0 ), center.y + strSize.height );
    CTLineDraw( lineref, ctx );
    
    CFRelease( lineref );
	CFRelease( sysUIFont );
    
}

@end
