import processing.svg.*;
import java.util.*;

// My old tree
// String axiom = "Y";
// String rule = "Y->BX, F->FX[FX[+XF]], X->FF[+XZ++X-F[+ZX]][-X++F-X], Z->[+F-X-F][++ZX]";
// float angle = 20;
// boolean randomize = true;

// String axiom = "F+F+F+F";
// String rule = "F->F+F-F-FF+F+F-F";
// float angle = 90;
// boolean randomize = false;

// String axiom = "YF";
// String rule = "X->YF+XF+Y, Y->XF-YF-X";
// float angle = 60;
// boolean randomize = false;

String axiom = "FX";
String rule = "X->X+YF+, Y->-FX-Y";
float angle = 90;
boolean randomize = false;

boolean generateSvg = true;
String production;
int iterations = 14;
float segmentLen = 5.0;
ArrayList<LineType> lines = new ArrayList<LineType>(1000);

float minX = 200000, maxX = -200000, minY = 200000, maxY = -200000;
float lW = 0, lH = 0;
float translateX = 0, translateY = 0, scale = 1;

void setup()
{
	// size(800, 800, SVG, "test.svg");
	size(800, 800);
	background(255);
	stroke(0);
	println("Building production...");
	buildProduction(randomize);
	println("Building render structure...");
	generateLSysRender(randomize);
	computeScale();
	println("Done with setup!");
	println("Number of lines: " + lines.size());
	println("minX: " + minX + " maxX: " + maxX + " minY: " + minY + " maxY: " + maxY);
	println("w: " + lW + " h: " + lH);
}

int noLinesToDraw = 0;

void draw()
{
	background(255);
	if (generateSvg)
		beginRecord(SVG, "output/output_"+timestamp()+".svg");

	noLinesToDraw += 3;
	if (noLinesToDraw > lines.size())
		noLinesToDraw = 0;
	drawLinesUpTo(-1);
	if (generateSvg)
		endRecord();
	noLoop();
}

void computeScale()
{
	lW = maxX - minX;
	lH = maxY - minY;
	float xBound = width - 20;
	float yBound = height - 20;

	if (lW > lH)
	{
		scale = xBound / lW;
	}
	else
	{
		scale = yBound / lH;
	}

	translateX = 10 - (minX * scale);
	translateY = (height - 10) - (maxY * scale);
}

void drawLinesUpTo(int num)
{
	if (num < 0 || num > lines.size())
		num = lines.size();
	for (int i = 0; i < num; i++)
	{
		// lines.get(i).draw();
		lines.get(i).drawScaled(translateX, translateY, scale);
	}
}

void buildProduction(boolean randomize)
{
	HashMap<String, String> rules = new HashMap<String, String>();
	HashMap<String, String> invertedRules = new HashMap<String, String>();
	String regex = "\\s*(\\w)\\s*->\\s*([\\w\\[\\]+-]+)";
	String[][] parsed = matchAll(rule, regex);
	for (int i = 0; i < parsed.length; i++)
	{
		rules.put(parsed[i][1], parsed[i][2]);
		invertedRules.put(parsed[i][1], parsed[i][2].replace("+", "!").replace("-", "+").replace("!", "-"));
	}

	if (rules.isEmpty())
		return;

	production = axiom;
	String builderStr = "";
	for (int i = 0; i < iterations; i++)
	{
		for (int j = 0; j < production.length(); j++)
		{
			String c = str(production.charAt(j));
			if (rules.containsKey(c))
			{
				// builderStr = builderStr + rules.get(c);
				if (randomize && random(0, 1) < 0.5)
				{
					builderStr = builderStr + invertedRules.get(c);
				}
				else
				{
					builderStr = builderStr + rules.get(c);
				}
			}
			else
			{
				builderStr = builderStr + c;
			}
		}
		production = builderStr;
		builderStr = "";
	}
	println(production);
}

void generateLSysRender(boolean randomize)
{
	float cx = 0;
	float cy = 0;
	float ca = 0;
	float cw = 1;
	ArrayDeque<Float> stack = new ArrayDeque<Float>();
	int prodLen = production.length();
	for (int i = 0; i < prodLen; i++) {
		char c = production.charAt(i);

		switch (c) {
			case 'f':
			case 'F':
				float len = segmentLen;
				float ang_rand = 0; 
				if (randomize)
					angle = random(-0.1, 0.1);
				float nx = cx + len * sin(ca + ang_rand);
				float ny = cy + len * -cos(ca + ang_rand);
				// strokeWeight(cw);
				// line(cx, cy, nx, ny);
				lines.add(new LineType(cx, cy, nx, ny, cw));

				minX = min(minX, cx, nx);
				minY = min(minY, cy, ny);
				maxX = max(maxX, cx, nx);
				maxY = max(maxY, cy, ny);

				cx = nx;
				cy = ny;
			break;
			case '+':
				ca += angle * (PI / 180);
			break;
			case '-':
				ca -= angle * (PI / 180);
			break;
			case '[':
				// stack.add(cx, cy, ca, cw);
				stack.push(cx);
				stack.push(cy);
				stack.push(ca);
				stack.push(cw);
				// cw = cw * 0.5;
			break;
			case ']':
				cw = stack.pop();
				ca = stack.pop();
				cy = stack.pop();
				cx = stack.pop();
			break;
		}
	}
}

String timestamp() 
{
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}