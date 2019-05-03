package;

class Main extends openfl.display.Sprite
{
	public function new()
	{

		super();

		var s = new openfl.display.Sprite();
		s.graphics.beginFill(0x00FF00);
		s.graphics.drawRoundRect(0, 0, 100, 100, 10, 10);
		s.x = 100;
        s.y = 100;
		addChild(s);
	}
}
