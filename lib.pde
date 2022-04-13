class LineType
{
	float x0, y0, x1, y1;
	float weight;

	public LineType(float x0, float y0, float x1, float y1, float weight)
	{
		this.x0 = x0; this.y0 = y0; this.x1 = x1; this.y1 = y1; this.weight = weight; 
	}

	void draw()
	{
		strokeWeight(weight);
		line(x0, y0, x1, y1);
	}

	void drawScaled(float tx, float ty, float s)
	{
		float a = x0 * s + tx;
		float b = y0 * s + ty;
		float c = x1 * s + tx;
		float d = y1 * s + ty;
		strokeWeight(weight);
		line(a, b, c, d);
	}
}

class Sketch
{
	void Setup()
	{
	}

	void Draw()
	{
	}
}