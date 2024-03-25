#import "Headers.h"
#include <dlfcn.h>

//UIFont *emphasizedFont;
BOOL showsNextAlarm = NO;

@implementation BetterAlarmStatusBarStringView
	-(void)didMoveToWindow {
		[super didMoveToWindow];
		
		UITapGestureRecognizer *singlePress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBetterAlarmTap)];
		[self setUserInteractionEnabled:YES];
		[self addGestureRecognizer:singlePress];
	}

	-(void)applyStyleAttributes:(_UIStatusBarStyleAttributes *)arg1 {
		[super applyStyleAttributes:arg1];
		//emphasizedFont = arg1.emphasizedFont;
		NSMutableAttributedString *attrString = [self.attributedText mutableCopy];
		[attrString addAttribute:NSFontAttributeName value:arg1.emphasizedFont range:NSMakeRange(0, attrString.length)];

		self.attributedText = attrString;		
	}

	-(void)handleBetterAlarmTap {

		if (!showsNextAlarm) return;

		NSBundle *sleepBundle = [NSBundle bundleWithPath:@"/Applications/SleepLockScreen.app"];
		NSBundle *timerFramework = [NSBundle bundleWithIdentifier:@"com.apple.mobiletimer-framework"];

		MTAlarmManager *manager = [[%c(SBScheduledAlarmObserver) sharedInstance] valueForKey:@"_alarmManager"];
		MTAlarm *nextAlarm = [manager nextAlarmSync];
		NSString *alarmTime = [NSDateFormatter localizedStringFromDate:nextAlarm.nextFireDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];

		NSString *title = [NSString stringWithFormat:[sleepBundle localizedStringForKey:@"UPCOMING_ALARM_FORMAT" value:@"%@" table:nil], alarmTime];

		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleActionSheet];

		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[sleepBundle localizedStringForKey:@"ALARM_ALERT_CANCEL" value:@"Cancel" table:nil] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
		[alertController addAction:cancelAction];

		if (nextAlarm.repeats || nextAlarm.sleepSchedule) {
			UIAlertActionStyle style = nextAlarm.sleepSchedule ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault;
			UIAlertAction *skipAction = [UIAlertAction actionWithTitle:[sleepBundle localizedStringForKey:@"ALARM_ALERT_SKIP" value:@"Skip Alarm" table:nil] style:style handler:^(UIAlertAction * action) {
				nextAlarm.keepOffUntilDate = [nextAlarm.nextFireDate dateByAddingTimeInterval:60];
				[manager updateAlarm:nextAlarm];

				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
					[self setText:self.originalText];
				});
			}];
			[alertController addAction:skipAction];
		}
		
		if (!nextAlarm.sleepSchedule) {
			UIAlertAction *disableAction = [UIAlertAction actionWithTitle:[timerFramework localizedStringForKey:@"HSPhsP" value:@"Disable Alarm" table:@"AlarmIntents"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
				nextAlarm.enabled = NO;
				[manager updateAlarm:nextAlarm];

				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
					[self setText:self.originalText];
				});
				
			}];
			[alertController addAction:disableAction];
		}
		
		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated: YES completion: nil];
		#pragma clang diagnostic pop
	}

	-(void)setText:(NSString *)text {

			showsNextAlarm = NO;
			// Save this so we can call setText later when the user manually disabled the alarm
			if (self.originalText == nil) self.originalText = text;

			MTAlarmManager *manager = [[%c(SBScheduledAlarmObserver) sharedInstance] valueForKey:@"_alarmManager"];
			MTAlarm *nextAlarm = [manager nextAlarmSync];

			// Create an NSDate that points to the time the alarm can be away at max
			NSDate *now = [[NSDate alloc] init];
			NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
			[dateComponents setHour:12];
			NSCalendar *calendar = [NSCalendar currentCalendar];
			NSDate *maxDate = [calendar dateByAddingComponents:dateComponents toDate:now options:0];

			if (nextAlarm != nil && ([maxDate compare:nextAlarm.nextFireDate] == NSOrderedDescending)) {
				NSString *customText = nil;

				NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
				dateFormatter.timeStyle = NSDateFormatterShortStyle;
				customText = [dateFormatter stringFromDate:nextAlarm.nextFireDate];

				NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:customText];

				UIImage *iconImage = [UIImage systemImageNamed:@"alarm.fill"];
				NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
				
				int fontSize = 18;
				int fontSizePadder = 2;
				double aspectMultiplier = 1;

				UIFont *titleFont = [UIFont systemFontOfSize:fontSize + fontSizePadder weight:UIFontWeightBold];

				double aspect = (iconImage.size.width / iconImage.size.height);
				iconImage = [iconImage scaleImageToSize:CGSizeMake(titleFont.capHeight * aspect*aspectMultiplier, titleFont.capHeight*aspectMultiplier)];
				iconImage = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

				//float mid = titleFont.descender + titleFont.capHeight;
				//float y = titleFont.descender - iconImage.size.height / 2 + mid + 1.5;
				float y = (titleFont.capHeight - iconImage.size.height)/2.f - 1;
				[textAttachment setBounds:CGRectIntegral(CGRectMake(0, y, iconImage.size.width, iconImage.size.height))];		

				// Load the alarm icon and scale / color it
				// UIImage *iconImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconAlarm]]];
				//iconImage = [iconImage scaleImageToSize:CGSizeMake(emphasizedFont.capHeight ?: 15, emphasizedFont.capHeight ?: 15)];
				//iconImage = [iconImage scaleImageToSize:CGSizeMake(13, 13)];
				iconImage = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
				textAttachment.image = iconImage;		

				NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];

				// Prepend the icon and a space to the string
				[attributedString insertAttributedString:[[NSMutableAttributedString alloc] initWithString:@" "] atIndex:0];
				[attributedString insertAttributedString:attrStringWithImage atIndex:0];

				// Set the bold text here. Usually it gets set in applyStyleAttributes, but after a respring setText gets called after that, therefore overwriting the attributes
				NSDictionary *attributesFromString = [self.attributedText attributesAtIndex:0 longestEffectiveRange:nil inRange:NSMakeRange(0, self.attributedText.length)];
				if (attributesFromString[NSFontAttributeName]) {
					[attributedString addAttribute:NSFontAttributeName value:attributesFromString[NSFontAttributeName] range:NSMakeRange(0, attributedString.length)];
				}

				self.attributedText = attributedString;
				showsNextAlarm = YES;

				return;
			} else {
				self.attributedText = [[NSMutableAttributedString alloc] initWithString:@"No Alarms !"];
				return;
			}

		[super setText:text];
	}

@end

%hook _UIStatusBarCellularCondensedItem
	-(void)_create_serviceNameView {
		%orig;
		_UIStatusBarStringView *view = [self serviceNameView];
		object_setClass(view, [BetterAlarmStatusBarStringView class]);
	}

	-(void)applyStyleAttributes:(id)arg1 toDisplayItem:(id)arg2
	{
		%orig;
		self.marqueeServiceName = NO;
		self.reducesFontSize = NO;		
	}
%end