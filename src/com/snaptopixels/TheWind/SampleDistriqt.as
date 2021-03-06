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
		public static const DEV_KEY : String = "";
		private var _devKey : String;

		private static var sAssets : AssetManager;

		private var particleX_min_value : Number = -1500;
		private var particleX_max_value : Number = 1500;
		private var particleX_range : Number = particleX_max_value - particleX_min_value;
		private var particleX_position : Number;

		private var pitch_min_value : Number = -90;
		private var pitch_max_value : Number = 90;
		private var pitch_range : Number = pitch_max_value - pitch_min_value;

		private var tiltPercentage : Number;
		private var dragPercentage : Number;

		private var particle : FFParticleSystem;
		private var sysOpt : SystemOptions;

		private var azimuth : Number;
		private var pitch : Number;
		private var roll : Number;
		private var nativeStage : *;

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
			sysOpt = SystemOptions.fromXML( sAssets.getXml( "SnowParticle" ), sAssets.getTexture( "texture_snow" ) );
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
		}

		private function deviceMotion_updateHandler(event : DeviceMotionEvent) : void
		{
			switch (event.type)
			{
				case DeviceMotionEvent.UPDATE_EULER: {
					azimuth = rad2deg( event.values[0] );
					pitch = rad2deg( event.values[1] );
					roll = rad2deg( event.values[2] );
					break;			
				}
			}

			tiltPercentage = pitch / (pitch_range * 0.5);
			particleX_position = Math.round( particleX_range * tiltPercentage );

			if (nativeStage.deviceOrientation == "rotatedRight") particleX_position = -particleX_position;

			particle.gravityX = particleX_position;

		}

	}
}
