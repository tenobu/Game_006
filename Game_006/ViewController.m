//
//  ViewController.m
//  Game_006
//
//  Created by 寺内 信夫 on 2014/10/01.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"


@interface ViewController()
{
	
@private
	
	NSInteger integer_MyTensu;
	
	NSString *string_1;
	
	NSTimer *timer, *timer2, *timer_Kieru;
	
	
//	UIImageView *imageView_[4];
//
	UIAccelerationValue speedX_;
	UIAccelerationValue speedY_;

	NSInteger integer_BallCount;
	
	NSMutableArray *array_Ball;
	
}

//@property ReminderViewController *remin;

@end


@implementation ViewController
{
	//MCBrowserViewController *_browserViewController;
	AppDelegate *app;
	UILabel *aiteno;
	int i;
}

/*
 @synthesize myPeerID;
 @synthesize serviceType;
 @synthesize nearbyServiceAdvertiser;
 @synthesize nearbyServiceBrowser;
 @synthesize session;
 
 @synthesize myself;
 @synthesize companion;
 */


- (void)viewDidLoad
{
	[super viewDidLoad];

	app = [[UIApplication sharedApplication] delegate];
	//app.stepDelegate = nil;//「self」では「相容れない'~'から'id<~>'に格納しようとしているよ」と出る。
	
	NSLog(@"%s %s:%d", __PRETTY_FUNCTION__, __FILE__, __LINE__);
 
	// Multipeer Connectivityの初期化→サービス提供
	self.serviceType = SERVICE_TYPE;
	
	MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
	
	self.session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionOptional];
	self.session.delegate = self;
	//self.session = session;

	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:10];
	[info setObject:@"1.0" forKey:@"version"];
	
	//MCAdvertiserAssistant *assistant = [[MCAdvertiserAssistant alloc] initWithServiceType: self.serviceType
	self.assistant = [[MCAdvertiserAssistant alloc] initWithServiceType: self.serviceType
														  discoveryInfo: info
																session: self.session];
	self.assistant.delegate = self;
	
	[self.assistant start];
	
	//self.assistant = assistant;
	//_remin = [[ReminderViewController alloc]init];
	
	NSNotificationCenter*   nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(success) name:@"tuuti" object:nil];
	
	
	//固定
//	_myself.text = [UIDevice currentDevice].name;
	
	NSLog(@"---------------%@",[UIDevice currentDevice].name);
	/*    _companion.text = [didReceiveData: fromPeer:];
	 NSLog(@"==========%@",);
	 
	 AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	 appDelegate.stepDelegate = self;
	 
	 */
	//return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone);
	
	//---------------------------------------
	
	timer = [NSTimer scheduledTimerWithTimeInterval: 0.5
											 target: self
										   selector: @selector( aprivate )
										   userInfo: nil
											repeats: YES];
	
	//背景色を白に指定
	self.view.backgroundColor = [UIColor whiteColor];
	
	array_Ball = [[NSMutableArray alloc] init];
	
	[self initBall];
	
	self.label_TekiTensu_2.hidden = YES;
	self.label_TekiTensu_3.hidden = YES;
	self.label_TekiTensu_4.hidden = YES;
	
}


/*
 -(void)kirakira
 {
 
 if (i == 0)
 {
 self.hosi.hidden = YES;
 i = 1;
 }else
 {
 self.hosi.hidden = NO;
 i = 0;
 }
 
 }
 */
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//加速度センサーからの値取得開始
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.updateInterval = 1.0 / 30.0;
	accelerometer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	speedX_ = speedY_ = 0.0;
	
	//加速度センサーからの値取得終了
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.delegate = nil;
}

//加速度センサーからの通知
- (void)accelerometer:(UIAccelerometer *)accelerometer
		didAccelerate:(UIAcceleration *)acceleration
{

	for ( NSMutableDictionary *dic in array_Ball ) {
		
		UIImageView *imageView = [dic objectForKey: @"image_view"];
		
		NSNumber *number = [dic objectForKey: @"speed_x"];
		float speed_x = number.floatValue;
		
		number           = [dic objectForKey: @"speed_y"];
		float speed_y = number.floatValue;
		
		speed_x += acceleration.x;
		speed_y += acceleration.y;
		
		CGFloat posX = imageView.center.x + speed_x;
		CGFloat posY = imageView.center.y - speed_y;
		
		//端にあたったら跳ね返る処理
		if (posX < 0.0) {
			
			posX = 0.0;
			
			//左の壁にあたったら0.4倍の力で跳ね返る
			speed_x *= -0.4;
			
		} else if (posX > self.view.bounds.size.width) {
			
			posX = self.view.bounds.size.width;
			
			//右の壁にあたったら0.4倍の力で跳ね返る
			speed_x *= -0.4;
			
		}
		if (posY < 0.0) {
			
			posY = 0.0;
			
			//上の壁にあたっても跳ね返らない
			speed_y = 0.0;
			
		} else if (posY > self.view.bounds.size.height) {
			
			posY = self.view.bounds.size.height;
			
			//下の壁にあたったら1.5倍の力で跳ね返る
			speed_y *= -1.5;
			
		}
		
		imageView.center = CGPointMake( posX, posY );
		
		NSNumber *number_x = [[NSNumber alloc] initWithFloat: speed_x];
		NSNumber *number_y = [[NSNumber alloc] initWithFloat: speed_y];
		
		[dic setObject: imageView forKey: @"image_view"];
		[dic setObject: number_x  forKey: @"speed_x"];
		[dic setObject: number_y  forKey: @"speed_y"];
		
	}
	
}

//ローパスフィルタ
- (CGFloat)lowpassFilter:(CGFloat)accel before:(CGFloat)before
{
	static const CGFloat kFilteringFactor = 0.1;
	return (accel * kFilteringFactor) + (before * (1.0 - kFilteringFactor));
}

//ハイパスフィルタ
- (CGFloat)highpassFilter:(CGFloat)accel before:(CGFloat)before
{
	return (accel - [self lowpassFilter:accel before:before]);
}

- (void)showAlert:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
	// BLog();
	if(error){
		//        NSLog(@"[error localizedDescription] %@", [error localizedDescription]);
	}
	
}

-(BOOL)shouldAutorotate
{
	return NO;
}


/*
 //多分これは重要！！！後で解読せよ！！
 - (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
 {
 
 NSLog(@"found Peer : %@", peerID.displayName);
 //[self showAlert:@"found Peer" message:peerID.displayName];
 // if([self isPhone]){
 // _companion.text = peerID.displayName;
 // }else{
 // _companion.text = peerID.displayName;
 // }
 // [nearbyServiceBrowser invitePeer:peerID toSession:session withContext:[@"Welcome" dataUsingEncoding:NSUTF8StringEncoding] timeout:10];
 }
 
 */
/*
 - (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
 {
 
 }
 */

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
	if(error){
		//        NSLog(@"%@", [error localizedDescription]);
		[self showAlert:@"ERROR didNotStartAdvertisingPeer" message:[error localizedDescription]];
	}
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler
{
	
	invitationHandler(TRUE, self.session);
	[self showAlert:@"didReceiveInvitationFromPeer" message:@"accept invitation!"];
}


// Multipeer Connectivityで接続先を見つけるUIを表示する
- (IBAction)connect:(UIButton *)sender;
{
	
	//AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	
	MCBrowserViewController *_browserViewController = [[MCBrowserViewController alloc] initWithServiceType: self.serviceType session: self.session];
	
	_browserViewController.delegate = self;
	_browserViewController.minimumNumberOfPeers = kMCSessionMinimumNumberOfPeers;
	_browserViewController.maximumNumberOfPeers = kMCSessionMaximumNumberOfPeers;
	
	[self presentViewController:_browserViewController animated:YES completion:NULL];
	
	
	//    NSLog(@"kokohatottayo-------------------");
	
}

//キャンセルでviewを隠す
-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
	[browserViewController dismissViewControllerAnimated:YES completion:NULL];
}
//完了でviewをかくす
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController;
{
	[self aprivate];
	
	[browserViewController dismissViewControllerAnimated:YES completion:NULL];
}
// デバイスの表示可否
- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info;
{
	//    NSLog(@"browserViewController:%@ shouldPresentNearbyPeer:%@ withDiscoveryInfo:%@", browserViewController, peerID, info);
	NSString *version = [info objectForKey:@"version"];
	if ([@"1.0" isEqualToString:version]) {
		return YES;
	};
	return NO;
}
-(void)success {
	
}

//perrIDを！！！！
- (void)aprivate
{
	//送信先の Peer を指定する
	//小さなデータをすべての接続先に送信する場合は、connectedPeers
	//送信先を制限したい場合届けたい送信先のみで構成したNSArrayを指定する
	//self.session = app.session;
//	NSArray *peerIDs = self.session.connectedPeers;
//	
//	for (int count = 0; count < peerIDs.count; count++)
//	{
//		MCPeerID *peerID = [peerIDs objectAtIndex:count];
//		switch (count)
//		{
//			case 0:
//				_companion.text = peerID.displayName;
//				
//				if (i == 0)
//				{
//					self.hosi.hidden = YES;
//					i = 1;
//				}else
//				{
//					self.hosi.hidden = NO;
//					i = 0;
//				}
//				break;
//			case 1:
//				_companion1.text = peerID.displayName;
//				
//				if (i == 0)
//				{
//					self.hosi1.hidden = YES;
//					i = 1;
//				}else
//				{
//					self.hosi1.hidden = NO;
//					i = 0;
//				}
//				
//				
//				break;
//			case 2:
//				_companion2.text = peerID.displayName;
//				if (i == 0)
//				{
//					self.hosi2.hidden = YES;
//					i = 1;
//				}else
//				{
//					self.hosi2.hidden = NO;
//					i = 0;
//				}
//				
//				break;
//			case 3:
//				_companion3.text = peerID.displayName;
//				if (i == 0)
//				{
//					self.hosi3.hidden = YES;
//					i = 1;
//				}else
//				{
//					self.hosi3.hidden = NO;
//					i = 0;
//				}
//				
//				break;
//			case 4:
//				_companion4.text = peerID.displayName;
//				if (i == 0)
//				{
//					self.hosi4.hidden = YES;
//					i = 1;
//				}else
//				{
//					self.hosi4.hidden = NO;
//					i = 0;
//				}
//				
//			default:
//				break;
//		}
//	}

	self.label_TekiTensu_1.text = string_1;
	
	[self tamaDown];
	
}

//    NSMutableArray *labels = [[NSMutableArray alloc] init];
//
//    for (peerIDs in dic)
//    {
//        //ラベル配置スタート
//        aiteno= [[UILabel alloc]initWithFrame:CGRectMake(0, 600+(i*90), 230 , 80)];
//        aiteno.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:0.3];
//
//
//        [labels addObject:aiteno];
//
//        i++;
//    }

// Found a nearby advertising peer
- (void)  browser: (MCNearbyServiceBrowser *)browser
	    foundPeer: (MCPeerID *)peerID
withDiscoveryInfo: (NSDictionary *)info{
	
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
	
}
#pragma mark - MCAdvertiserAssistantDelegate
// 接続要求が来た
- (void)advertiserAssitantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant;
{
	NSLog(@"-advertiserAssitantWillPresentInvitation:%@", advertiserAssistant);
	
}

// 接続要求が完了した
- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant;
{
	NSLog(@"-advertiserAssistantDidDismissInvitation:%@", advertiserAssistant);
	
}
////ループ------------------------------
//-(void)loop
//{
//	//    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:10];
//	//    [info setObject:@"1.0" forKey:@"version"];
//	MCAdvertiserAssistant *assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:self.serviceType discoveryInfo:nil session:_session];
//	assistant.delegate = self;
//	
//	NSLog(@"11111111111111111111111111111");
//	[self.assistant start];
//	[self loop2];
//	
//}
//-(void)loop2
//{
//	
//	time = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(loop) userInfo:nil repeats:YES];
//}
//---------------------------------------------------
#pragma mark - MCSessionDelegate
// 接続相手の状態が変わった
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state;
{
	NSLog(@"-session:peer: %@ didChangeState: %@", peerID.displayName, (state == MCSessionStateNotConnected ? @"NotConnected" : (state == MCSessionStateConnecting ? @"Connecting" : @"Connected")));
	
	switch (state) {
		case MCSessionStateNotConnected:// 切断した
			
			break;
		case MCSessionStateConnecting:		// 接続中
			break;
		case MCSessionStateConnected:		// 接続できた
			NSLog(@"ココ通ってる？");
			self.session = session;
			
			break;
		default:
			break;
	}
}

// dataを受け取った
// サブスレッドで受けてる
// 送信元： - (BOOL)sendData:(NSData *)data toPeers:(NSArray *)peerIDs withMode:(MCSessionSendDataMode)mode error:(NSError **)error;
- (void)session: (MCSession *)session
 didReceiveData: (NSData *)data
	   fromPeer: (MCPeerID *)peerID;
{
	
	NSLog(@"-session: didReceiveData: fromPeer:%@", peerID.displayName);

 //   NSError *error;
	
	//	dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	//
	//	NSString *title = [dic objectForKey:@"title"];
	//	NSString *note = [dic objectForKey:@"note"];
	//
	//	NSLog(@"タイトル %@ 本文　%@", title, note);
	//	[self saveRiminder:title note:note];
	
	//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
	//    if (!error) {
	//        NSLog(@"data = %@", json);
	//        [self.stepDelegate recvDictionary:json];
	//    }
	
	NSString *string = [[NSString alloc] initWithData: data
											 encoding: NSUTF8StringEncoding];
	
	//self.label_TekiTensu_1.text = [NSString stringWithFormat: @"敵１    %@", string];
	string_1 = [NSString stringWithFormat: @"敵１    %@", string];
	
	[self initBall];
	
	NSLog( @"count = %d", [array_Ball count] );
	
	timer2 = [NSTimer scheduledTimerWithTimeInterval: 0.1
											  target: self
											selector: @selector( tamaDown )
											userInfo: nil
											 repeats: NO];

}

// 相手からストリームデータを受けた
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID;
{
	NSLog(@"-session: didReceiveStream: withName:%@ fromPeer:%@", streamName, peerID.displayName);
	// Stream をdelegateで処理するように設定
	[stream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	stream.delegate = self;
	[stream open];
}

// リソースの受信が始まった
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress;
{
	NSLog(@"-session: didStartReceivingResourceWithName:%@ fromPeer:%@ withProgress:", resourceName, peerID.displayName);
	// progress に進捗が入る
	[progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
}

// リソースの受信を完了した
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error;
{
	NSLog(@"-session: didFinishReceivingResourceWithName:%@ fromPeer:%@ atURL: withError:", resourceName, peerID.displayName);
	// localURLにファイルがある
	dispatch_async(dispatch_get_main_queue(), ^{
	});
}

// 接続先の証明書を確認して接続可否を判断する
- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler;
{
	NSLog(@"-session: didReceiveCertificate:%@ fromPeer:%@ certificateHandler:", certificate, peerID.displayName);
	certificateHandler(YES);
}

#pragma mark - KVO
// KVOの通知を受ける
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
	NSLog(@"%@ -observeValueForKeyPath:%@ ofObject:%@ change:%@ context:", NSStringFromClass(self.class), keyPath, object, change);
	if ([@"fractionCompleted" isEqualToString:keyPath]) {
		NSNumber *number = [change objectForKey:@"new"];
		dispatch_async(dispatch_get_main_queue(), ^{
			// 進捗値を評価
			// number.doubleValue;
			NSLog(@"-> %@", number);
		});
	}
}

#pragma mark - NSStreamDelegate
// ストリームの状態が変化した
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;
{
	NSLog(@"-stream: handleEvent: %@%@%@%@%@%@",
		  streamEvent & NSStreamEventNone ? @"NSStreamEventNone, " : @"",
		  streamEvent & NSStreamEventOpenCompleted ? @"NSStreamEventOpenCompleted, " : @"",
		  streamEvent & NSStreamEventHasBytesAvailable ? @"NSStreamEventHasBytesAvailable, " : @"",
		  streamEvent & NSStreamEventHasSpaceAvailable ? @"NSStreamEventHasSpaceAvailable, " : @"",
		  streamEvent & NSStreamEventErrorOccurred ? @"NSStreamEventErrorOccurred, " : @"",
		  streamEvent & NSStreamEventEndEncountered ? @"NSStreamEventEndEncountered, " : @""
		  );
	// データ受信
	if (streamEvent & NSStreamEventHasBytesAvailable) {
		int32_t steps;
		NSInputStream *input = (NSInputStream*)theStream;
		[input read:(uint8_t*)&steps maxLength:sizeof(int32_t)];
		// read
	}
	// 終了
	if (streamEvent & NSStreamEventEndEncountered) {
		[theStream close];
		[theStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	}
}
- (void)saveRiminder:(NSString *)title note:(NSString *) note
{
	
	EKEventStore *eventStore = [[EKEventStore alloc] init];
	
	EKReminder *postReminder = [EKReminder reminderWithEventStore:eventStore];
	
	postReminder.title = title;
	postReminder.notes = note;
	postReminder.calendar = [eventStore defaultCalendarForNewReminders];
	
	//   postReminder.alarms = [EKAlarm alarmWithAbsoluteDate:alarmDate];
	NSError *error;
	BOOL success = [eventStore saveReminder:postReminder commit:YES error:&error];
	if (!success) {
		// 投稿失敗時
		NSLog(@"%@",[error description]);
		
		
		NSLog(@"!!!!!!!!!!!!!!!!!!!!!!");
		
	} else {
		
		UILocalNotification *noti = [UILocalNotification new];//alloc] init];
		[noti setAlertBody:note];
  //      [noti setAlertAction:@"open"];
		//       [noti setSoundName:UILocalNotificationDefaultSoundName];
		[[UIApplication sharedApplication] scheduleLocalNotification:noti];//presentLocalNotificationNow:noti];
		
		//        NSNotification *noti = [NSNotification notificationWithName:@"tuuti" object:self userInfo:dic];
		//        [[NSNotificationCenter defaultCenter] postNotification:noti];
	}
	
	
	//- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
	
}



#pragma mark - MCBrowserViewControllerDelegate
//- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController;
//{
//	[browserViewController dismissViewControllerAnimated:YES completion:NULL];
//}
//- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController;
//{
//	[browserViewController dismissViewControllerAnimated:YES completion:NULL];
//}
//- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info;
//{
//	
//}
//- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
//{
//}
//- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
//{
//	
//}

- (IBAction)button_Action:(id)sender
{

	integer_MyTensu += 10;
	
	NSString *string = [NSString stringWithFormat: @"%06ld", integer_MyTensu];
	self.label_MyTensu.text = [NSString stringWithFormat: @"自分    %@", string];

	NSError *error = nil;
	
	//送信する文字列を作成
	//NSData へ文字列を変換
	NSData *data = [string dataUsingEncoding: NSUTF8StringEncoding];
 
	//送信先の Peer を指定する
	NSArray *peerIDs = self.session.connectedPeers;
 
	[self.session sendData: data
				   toPeers: peerIDs
				  withMode: MCSessionSendDataReliable
					 error: &error];

	if ( error ) {
	
		NSLog( @"%@", error );
		
	}
	
}

- (void)initBall
{

	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	
	//UIImageView追加
	UIImage* image = [UIImage imageNamed: @"ball.png"];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	
	imageView.center = self.view.center;
	
	imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	[self.view addSubview:imageView];
	
	
	float speed_x = 0.0, speed_y = 0.0;
	NSNumber *number_x = [[NSNumber alloc] initWithFloat: speed_x];
	NSNumber *number_y = [[NSNumber alloc] initWithFloat: speed_y];
	
	[dic setObject: imageView forKey: @"image_view"];
	[dic setObject: number_x  forKey: @"speed_x"];
	[dic setObject: number_y  forKey: @"speed_y"];
	
	
	[array_Ball addObject: dic];
	
}

- (void)tamaDown
{
	
	int index;
	
loop:
	
	index = 0;
	
	for ( NSMutableDictionary *dic in array_Ball ) {
		
		UIImageView *imageView = [dic objectForKey: @"image_view"];
		
		NSInteger ix = imageView.center.x;
		NSInteger iy = imageView.center.y;
		NSInteger ax = self.imageView_Ana.center.x;
		NSInteger ay = self.imageView_Ana.center.y;
		
		NSLog( @"%ld > %ld && %ld < %ld && %ld > %ld && %ld < %ld", ix, ax - 20, ix, ax + 20, iy, ay - 20, iy, ay + 20 );
		
		if ( ix > ax - 20 && ix < ax + 20 &&
			iy > ay - 20 && iy < ay + 20     ) {
			
			imageView.hidden = YES;
			
			integer_MyTensu += 10;
			
			NSString *string = [NSString stringWithFormat: @"%06ld", integer_MyTensu];
			self.label_MyTensu.text = [NSString stringWithFormat: @"自分    %@", string];
			
			NSError *error = nil;
			
			//送信する文字列を作成
			//NSData へ文字列を変換
			NSData *data = [string dataUsingEncoding: NSUTF8StringEncoding];
			
			//送信先の Peer を指定する
			NSArray *peerIDs = self.session.connectedPeers;
			
			[self.session sendData: data
						   toPeers: peerIDs
						  withMode: MCSessionSendDataReliable
							 error: &error];
			
			if ( error ) {
				
				NSLog( @"%@", error );
				
			}
			
			[imageView removeFromSuperview];
			
			[array_Ball removeObjectAtIndex: index];
			
			timer_Kieru = [NSTimer scheduledTimerWithTimeInterval: 5.0
														   target: self
														 selector: @selector( tabaArawaru )
														 userInfo: nil
														  repeats: NO];
			
			goto loop;
			
		}

		index ++;
		
	}
	
}

- (void)tabaArawaru
{

	[self initBall];
	
}

@end
