//nvcc fractalGPU2.cu -o temp2 -lglut -lGL -lm

#include <GL/glut.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

unsigned int window_width = 1024;
unsigned int window_height = 1024;

float zoom = 0.035;

float xOffset = 950.0;
float yOffset = 450.0;

float a = 0.365;
float b = 0.11;

dim3 dimBlock;
dim3 dimGrid;

float *pixels_CPU;
float *pixels_GPU;

float xValue (int x) 
{
	float xVal = (2.0f * (((x * zoom)/(window_width-1)))-zoom);
	return xVal;
}

float yValue (int y) 
{
	float yVal = ((-2.0f)*(((y * zoom)/(window_height-1)))+zoom);
	return yVal;
}

__device__ float color (int i, int j) 
{
	float x, y, mag,maxMag,t1, a, b;
	float maxCount = 200;
	float count = 0;
	maxMag = 10;
	mag = 0.0;
	a = 0.365;	
	b = 0.11;
	x = xValue(i);
	y = yValue(j);
	
	while (mag < maxMag && count < maxCount) 
	{
		t1 = x;	
		x = pow(x,2) - pow(y,2) + a;
		y = (2 * t1 * y) + b;
		mag = sqrt(pow(x,2)+pow(y,2));
		count += 0.75;
	}
	return(count*1.0f/maxCount);
}

__global__ julea(pixel)
{
	k=0;
	for(int i = 0; i < window_width; i++) 
	{
		for(int j = 0; j < window_height; j++) 
		{
			pixels_CPU[k] = color(i+yOffset,j+xOffset);
			pixels_CPU[k+1] = 0.125; 
			pixels_CPU[k+2] = 0.30;
			k=k+3;
		}
	}
}

void display(void) { 
	int i,j,k;
	
	dimBlock.x = 1024;
	dimBlock.y = 1;
	dimBlock.z = 1;
	dimGrid.x = 1024;
	dimGrid.y = 1;
	dimGrid.z = 1;

	pixels_CPU = (float *)malloc(window_width*window_height*3*sizeof(float));
	cudaMalloc((void**)&pixels_GPU, window_width*window_height*3*sizeof(float));
	
	julea<<<GridConfig, BlockConfig>>>(pixels_GPU);
	
	cudaMemcpy( pixels_CPU, pixels_GPU, window_width*window_height*3*sizeof(float), cudaMemcpyDeviceToHost );

	glDrawPixels(window_width, window_height, GL_RGB, GL_FLOAT, pixels_CPU); 
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

