#import "Tweak.h"

static bool isBlackOrWhite(UIColor *color) {
  CGFloat r, g, b;
  [color getRed:&r green:&g blue:&b alpha:NULL];
  r = round(r * 255.0);
  g = round(g * 255.0);
  b = round(b * 255.0);
  return (r > 232 && g > 232 && b > 232) || (r < 23 && g < 23 && b < 23);
}

%hook MTLumaDodgePillView
- (void)_updateStyle {
  %orig;
  if ([(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication])
    self.style = 0;
}
- (void)layoutSubviews {
  %orig;
  MTLumaDodgePillView *pillView = self;
  SBApplication *app =
      [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
  if (!app) return;
  NSArray<SBLeafIcon *> *icons =
      ((SBIconController *)[%c(SBIconController) sharedInstanceIfExists])
          .model.leafIcons.allObjects;
  NSUInteger iconIdx =
      [icons indexOfObjectPassingTest:^BOOL(SBLeafIcon *icon, NSUInteger idx, BOOL *stop) {
        if ([[icon applicationBundleID] isEqualToString:app.bundleIdentifier]) {
          *stop = YES;
          return YES;
        }
        return NO;
      }];
  if (iconIdx == NSNotFound) return;
  SBLeafIcon *icon = icons[iconIdx];
  UIImage *iconImage;
  if ([icon respondsToSelector:@selector(generateIconImage:)]) {
    iconImage = [icon generateIconImage:2];
  } else {
    struct SBIconImageInfo imageInfo;
    imageInfo.size = CGSizeMake(60, 60);
    imageInfo.scale = [UIScreen mainScreen].scale;
    imageInfo.continuousCornerRadius = 12;
    iconImage = [icon generateIconImageWithInfo:imageInfo];
  }
  [[[MPArtworkColorAnalyzer alloc] initWithImage:iconImage algorithm:0]
      analyzeWithCompletionHandler:^(MPArtworkColorAnalyzer *analyzer,
                                     MPMutableArtworkColorAnalysis *analysis) {
        UIColor *backgroundColor = analysis.backgroundColor;
        CCColorCube *colorCube = [[CCColorCube alloc] init];
        NSArray *ccColors = [colorCube extractColorsFromImage:iconImage
                                                        flags:CCAvoidWhite | CCAvoidBlack
                                                   avoidColor:backgroundColor];
        dispatch_async(dispatch_get_main_queue(), ^{
          if (isBlackOrWhite(analysis.backgroundColor) && ccColors.count != 0)
            pillView.backgroundColor = ccColors[0];
          else
            pillView.backgroundColor = backgroundColor;
        });
      }];
}
%end

static void add_image(const struct mach_header *mh, intptr_t vmaddr_slide) {
  Dl_info dlinfo;
  if (!dladdr(mh, &dlinfo)) return;
  if (!strcmp(dlinfo.dli_fname, "/System/Library/CoreServices/SpringBoard.app/SpringBoard"))
    %init;
}

%ctor {
  _dyld_register_func_for_add_image(add_image);
}
