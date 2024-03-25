@interface UIView (BetterAlarm)
-(id)_viewControllerForAncestor;
@end

@interface _UIStatusBarStyleAttributes : NSObject
@property (nonatomic,copy) UIFont * font;
@property (nonatomic,copy) UIFont * emphasizedFont;
@end

@interface _UIStatusBarStringView : UILabel
@property (nonatomic,copy) NSString * originalText;
-(void)applyStyleAttributes:(_UIStatusBarStyleAttributes *)arg1;
@end

@interface MTAlarm : NSObject
@property (nonatomic,readonly) NSDate * nextFireDate;
@property (assign,getter=isEnabled,nonatomic) BOOL enabled;
@property (nonatomic,readonly) BOOL repeats;
@property (nonatomic,copy) NSDate * keepOffUntilDate;
@property (assign,nonatomic) BOOL sleepSchedule;
@end

@interface MTAlarmCache : NSObject
@property (nonatomic,retain) MTAlarm * nextAlarm;
@end

@interface MTAlarmManager : NSObject
    //@property (nonatomic,retain) MTAlarmCache * cache;
    -(id)updateAlarm:(id)arg1 ;
    -(MTAlarm *)nextAlarmSync;
@end

@interface _UIStatusBarItem : NSObject
@end

@interface _UIStatusBarCellularItem : _UIStatusBarItem
@property (nonatomic,retain) _UIStatusBarStringView * serviceNameView;
@property (assign,nonatomic) BOOL marqueeServiceName;
@property (assign,nonatomic) BOOL reducesFontSize;
@end

@interface _UIStatusBarCellularCondensedItem : _UIStatusBarCellularItem
@end

@interface _UIStatusBarIndicatorItem : _UIStatusBarItem
@end

@interface BetterAlarmStatusBarStringView : _UIStatusBarStringView
@end

@interface UIImage (BetterAlarm)
- (UIImage *)scaleImageToSize:(CGSize)newSize;
@end

@interface FigCaptureClientSessionMonitor : NSObject
@property (readonly) NSString * applicationID; 
@end

@interface FigCaptureClientSessionMonitorClient : NSObject
@property (nonatomic,readonly) NSString * applicationID;
@end

@interface SpringBoard : UIApplication
-(void)applicationOpenURL:(id)arg1;
@end

@interface SBScheduledAlarmObserver
    +(id)sharedInstance;
@end