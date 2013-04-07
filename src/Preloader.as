package 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author 
	 */
	public class Preloader extends MovieClip 
	{
		
		private var _preloaderMovie:MovieClip = new preloaderMovie();
		private var _loading:MovieClip;
		
		public function Preloader() 
		{
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			
			addChild(_preloaderMovie);
			_loading = _preloaderMovie.loadingBar;
			_loading.stop();
			addEventListener(Event.ENTER_FRAME, checkFrame);
		}
		
		private function checkFrame(e:Event):void 
		{
			var bytesLoaded:Number = stage.loaderInfo.bytesLoaded;
            var bytesTotal:Number = stage.loaderInfo.bytesTotal;
            var percent:int = 0;
    
            //подсчитываем процент загрузки флешки
            if (bytesTotal>0)
            {
                percent = int(bytesLoaded/bytesTotal*100);
                //s = percent+"%";
            }
            if (percent < 100) {
                percent++;
            }
            // обновляем прогресс бар
            //this.txt.text="LOADING... "+s;
            //this.progressBar.gotoAndStop(percent+1);
            _loading.gotoAndStop(percent);
            
            // Если флешка полностью загрузились, 
            //то переходим на второй кадр
            if (bytesLoaded==bytesTotal || bytesTotal==0)
            {
				loadingFinished();
            }
		}
		
		
		private function loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			_loading.gotoAndStop(100);
			_loading.startBtn.addEventListener(MouseEvent.CLICK, onMainMenu, false, 0, true);
		}
		
		private function onMainMenu(e:MouseEvent):void 
		{
			_loading.startBtn.removeEventListener(MouseEvent.CLICK, onMainMenu, false);
			removeChild(_preloaderMovie);
			_loading = null;
			_preloaderMovie = null;
			startup();
		}
		
		private function startup():void 
		{
			var mainClass:Class = getDefinitionByName("Main") as Class;
			if (parent == stage) stage.addChildAt(new mainClass() as DisplayObject, 0);
			else addChildAt(new mainClass() as DisplayObject, 0);
		}
		
	}
	
}