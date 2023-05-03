#import <CCColorCube.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

struct SBIconImageInfo {
  CGSize size;
  CGFloat scale;
  CGFloat continuousCornerRadius;
};

@interface MPArtworkColorAnalysis : NSObject
@end

@interface MPMutableArtworkColorAnalysis : MPArtworkColorAnalysis
@property(nonatomic, retain) UIColor *backgroundColor;
@property(nonatomic, getter=isBackgroundColorLight) BOOL backgroundColorLight;
@property(nonatomic, retain) UIColor *primaryTextColor;
@property(nonatomic, getter=isPrimaryTextColorLight) BOOL primaryTextColorLight;
@property(nonatomic, retain) UIColor *secondaryTextColor;
@property(nonatomic, getter=isSecondaryTextColorLight)
    BOOL secondaryTextColorLight;
@end

@interface MPArtworkColorAnalyzer : NSObject
- (instancetype)initWithImage:(UIImage *)image algorithm:(NSInteger)algorithm;
- (void)analyzeWithCompletionHandler:
    (void (^)(MPArtworkColorAnalyzer *,
              MPMutableArtworkColorAnalysis *))completionHandler;
@end

@interface MTPillView : UIView
@end

@interface MTLumaDodgePillView : MTPillView
@property(nonatomic) NSInteger style;
@end

@interface SBIcon : NSObject
- (UIImage *)generateIconImage:(int)arg1;
- (UIImage *)generateIconImageWithInfo:(struct SBIconImageInfo)info;
@end

@interface SBLeafIcon : SBIcon
- (NSString *)applicationBundleID;
@end

@interface SBHIconModel : NSObject
- (NSSet<SBLeafIcon *> *)leafIcons;
@end

@interface SBIconModel : SBHIconModel
@end

@interface SBIconController
@property(nonatomic, strong) SBIconModel *model;
+ (instancetype)sharedInstanceIfExists;
@end

@interface SBApplication : NSObject
@property(nonatomic, readonly, strong) NSString *bundleIdentifier;
@end

@interface SpringBoard : UIApplication
- (SBApplication *)_accessibilityFrontMostApplication;
@end