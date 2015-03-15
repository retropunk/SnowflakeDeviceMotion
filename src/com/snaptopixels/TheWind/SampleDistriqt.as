package com.snaptopixels.TheWind
{
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.AssetManager;
	import starling.utils.rad2deg;

	import de.flintfabrik.starling.display.FFParticleSystem;
	import de.flintfabrik.starling.display.FFParticleSystem.SystemOptions;

	import com.distriqt.extension.devicemotion.DeviceMotion;
	import com.distriqt.extension.devicemotion.DeviceMotionOptions;
	import com.distriqt.extension.devicemotion.SensorRate;
	import com.distriqt.extension.devicemotion.events.DeviceMotionEvent;

	public class SampleDistriqt extends Sprite
	{
		public static const DEV_KEY 		: String = "538bd275ac27850e08ec091724a4be8cd14d6119SV8H38I7ud72FnjR1cXM7ckyo0hMXCKqU28KXg8/OKO7pf1VEVLmpso4KaVPELLr3Q5ujByfepUciwc5tlCvA6U2tGkkyVHYxSt/snHfFvAFWM5DmjW/AKLz83+5J8ZxKm1HijXbjby9vLDzbU/GAETC9OT8Mw2XjfKHUW6F0MNZ2XFOTqj3oW++J4Ju6NeLh5Cz7R5S69SLMZjDVEPwDCDtpBGpt10YqCsm8ePNmWsT4JMoAy03Xbe75QIOjdCgl4cN16QRXMHVl0LjMlnF1sBhqYPzuAPoEgV85w0Z9u0iRTMa4+G4gMNH/dHwlK1efkkh/gSN2HAgWCafAXgygQ==";
		private var _devKey 						: String;
		
		private static var sAssets 			: AssetManager;
		
		private var particleX_min_value : Number = -1500;
		private var particleX_max_value : Number = 1500;
		private var particleX_range 		: Number = particleX_max_value - particleX_min_value;
		private var particleX_position 	: Number;
		
		private var pitch_min_value 		: Number = -90;
		private var pitch_max_value 		: Number = 90;
		private var pitch_range 				: Number = pitch_max_value - pitch_min_value;
		
		private var tiltPercentage 			: Number;
		private var dragPercentage 			: Number;
		private var isUsingTouch				: Boolean = false;
		
		private var particle 						: FFParticleSystem;
		private var sysOpt 							: SystemOptions;

		private var azimuth 						: Number;
		private var pitch 							: Number;
		private var roll 								: Number;
		private var nativeStage 				: *;

		public function SampleDistriqt(devKey : String = DEV_KEY)
		{
			_devKey = devKey;
		}

		public function start(assets : AssetManager, _nativeStage : *) : void
		{
			sAssets = assets;
			nativeStage = _nativeStage;
			sAssets.loadQueue( function(_ratio : Number) : void
			{
				if (_ratio == 1)
				{
					startApp();
				}
			} );
		}

		private function startApp() : void
		{
			sysOpt = SystemOptions.fromXML( sAssets.getXml( "Snow1" ), sAssets.getTexture( "texture" ) );
			FFParticleSystem.init( 2048, false, 1024, 4 );
			particle = new FFParticleSystem( sysOpt );
			addChild( particle );

			particle.emitterX = 1024;
			particle.scaleY = -1;
			particle.gravityX = 0;
			particle.start();

			if (DeviceMotion.isSupported)
			{
				DeviceMotion.init( _devKey );

				DeviceMotion.service.addEventListener( DeviceMotionEvent.UPDATE_EULER, deviceMotion_updateHandler );

				var options : DeviceMotionOptions = new DeviceMotionOptions();
				options.rate = SensorRate.SENSOR_DELAY_NORMAL;
				options.algorithm = DeviceMotionOptions.ALGORITHM_NATIVE;
				options.format = DeviceMotionOptions.FORMAT_EULER;

				DeviceMotion.service.register( options );
			}
			
			this.stage.addEventListener( TouchEvent.TOUCH, handleTouch );
		}

		private function deviceMotion_updateHandler(event : DeviceMotionEvent) : void
		{
			switch (event.type)
			{
				case DeviceMotionEvent.UPDATE_EULER: {
					azimuth = rad2deg(event.values[0]);
					pitch = rad2deg(event.values[1]);
					roll = rad2deg(event.values[2]);
					break;			
				}
			}
			
			if(!isUsingTouch)
			{
				tiltPercentage = pitch / (pitch_range * 0.5);
				particleX_position = Math.round( particleX_range * tiltPercentage );

				if (nativeStage.deviceOrientation == "rotatedRight") particleX_position = -particleX_position;

				particle.gravityX = particleX_position;
			}
			
		}

		private function handleTouch(event : TouchEvent) : void
		{
			var touchMove : Touch = event.getTouch( this.stage, TouchPhase.MOVED );
			var touchEnd : Touch = event.getTouch( this.stage, TouchPhase.ENDED );

			if (touchMove)
			{
				isUsingTouch = true;
				dragPercentage = (touchMove.globalX / 2048);
				particleX_position = Math.round( particleX_range * dragPercentage - particleX_max_value );
				
				if(nativeStage.deviceOrientation == "rotatedRight")
				{
					particleX_position = -particleX_position;
				}
				particle.gravityX = particleX_position;
			}
			if (touchEnd)
			{
				isUsingTouch = false;
				particle.gravityX = 0;
			}
		}

	}
}
