package com.snaptopixels.TheWind
{
	import starling.core.Starling;
	import starling.events.Event;
	import starling.utils.AssetManager;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;

	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;

	[SWF(width="2048", height="1536", frameRate="60", backgroundColor="#999999")]

	public class Main extends Sprite
	{
		private var mStarling : Starling;

		public function Main()
		{		
			var stageWidth : int = 2048;
			var stageHeight : int = 1536;
			var iOS : Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;

			Starling.multitouchEnabled = true;
			Starling.handleLostContext = !iOS;

			var viewPort : Rectangle = RectangleUtil.fit(new Rectangle(0, 0, stageWidth, stageHeight), new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), ScaleMode.SHOW_ALL, iOS);

			var scaleFactor : int = 1;
			var appDir : File = File.applicationDirectory;
			var assets : AssetManager = new AssetManager(scaleFactor);

			assets.verbose = true;
			assets.enqueue(appDir.resolvePath("assets"));

			mStarling = new Starling(SampleDistriqt, stage, viewPort);
			mStarling.stage.stageWidth = stageWidth;
			mStarling.stage.stageHeight = stageHeight;
			mStarling.simulateMultitouch = false;
			mStarling.enableErrorChecking = false;
			mStarling.showStatsAt( "center", "top", 2 );

			mStarling.addEventListener(starling.events.Event.ROOT_CREATED, function() : void {
				var entry : SampleDistriqt = mStarling.root as SampleDistriqt;
				entry.start(assets, mStarling.nativeStage);
				mStarling.start();
			});

			NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, function(e : *) : void {
				mStarling.start();
			});

			NativeApplication.nativeApplication.addEventListener(flash.events.Event.DEACTIVATE, function(e : *) : void {
				mStarling.stop(true);
			});
		}
	}
}
