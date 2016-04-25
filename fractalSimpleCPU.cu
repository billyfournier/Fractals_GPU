//nvcc fractalSimpleCPU.cu -o temp -lglut -lGL -lm

#include <GL/glut.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>


#define A  -0.52
#define B  0.57

unsigned int window_width = 1024;
unsigned int window_height = 1024;

float xMin = -2.0;
float xMax =  2.0;
float yMin = -2.0;
float yMax =  2.0;

float steps = 1024.0;
float stepSizeX = (xMax - xMin)/steps;
float stepSizeY = (yMax - yMin)/steps;

float color (float x, float y) 
{
	float mag,maxMag,t1;
	float maxCount = 200;
	float count = 0;
	maxMag = 10;
	mag = 0.0;
	
	while (mag < maxMag && count < maxCount) 
	{
		t1 = x;	
		x = x*x - y*y + A;
		y = (2.0 * t1 * y) + B;
		mag = sqrt(x*x + y*y);
		count++;
	}
	if(count < maxCount) 
	{
		return(1.0);
	}
	else
	{
		return(0.0);
	}
}

void display(void) 
{ 
	float *pixels; 
	int k;

	pixels = (float *)malloc(window_width*window_height*3*sizeof(float));
	k=0;
	float x = xMin;
	float y = yMin;
	while(x <= xMax) 
	{
		y = yMin;
		while(y <= yMax) 
		{
			pixels[k] = color(x,y);
			pixels[k+1] = 0.0; 
			pixels[k+2] = 0.0;
			k=k+3;
			y += stepSizeY;
		}
		x += stepSizeX;
	}

	glDrawPixels(window_width, window_height, GL_RGB, GL_FLOAT, pixels); 
	glFlush(); 
}

int main(int argc, char** argv)
{ 
   	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGB | GLUT_SINGLE);
   	glutInitWindowSize(window_width, window_height);
   	glutCreateWindow("Fractals man, fractals.");
   	glutDisplayFunc(display);
   	glutMainLoop();
}

