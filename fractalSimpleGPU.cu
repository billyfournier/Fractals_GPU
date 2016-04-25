//nvcc fractalSimpleGPU.cu -o temp2 -lglut -lGL -lm

#include <GL/glut.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>


#define A  -0.52
#define B  0.57

#define xMin -2.0
#define xMax  2.0
#define yMin -2.0
#define yMax  2.0

unsigned int window_width = 1024;
unsigned int window_height = 1024;

float steps = 1024.0;
float stepSizeX = (xMax - xMin)/steps;
float stepSizeY = (yMax - yMin)/steps;

dim3 dimBlock;
dim3 dimGrid;

float *pixels_CPU;
float *pixels_GPU;

void __global__ julia(float *pixels, float stepX, float stepY)
{
	float mag,t1;
	
	float maxCount = 200;
	float count = 0;
	float maxMag = 10;
	
	float x = threadIdx.x*stepX + xMin;
	float y = blockIdx.x*stepY + yMin;
	int k = threadIdx.x*3 + blockDim.x*blockIdx.x*3;
	
	mag = 0.0;
	while (mag < maxMag && count < maxCount) 
	{
		t1 = x;	
		x = x*x - y*y + A;
		y = (2.0 * t1 * y) + B;
		mag = sqrt(x*x + y*y);
		count++;
	}
	if(count < maxCount) pixels[k] = 0.0;
	else pixels[k] = 0.0;
	pixels[k+1] = 0.0; 
	pixels[k+2] = 0.0;
	
}

void display(void) 
{ 	
	dimBlock.x = 1024;
	dimBlock.y = 1;
	dimBlock.z = 1;
	dimGrid.x = 1024;
	dimGrid.y = 1;
	dimGrid.z = 1;

	pixels_CPU = (float *)malloc(window_width*window_height*3*sizeof(float));
	cudaMalloc((void**)&pixels_GPU, window_width*window_height*3*sizeof(float));
	
	julia<<<GridConfig, BlockConfig>>>(pixels_GPU, stepSizeX, stepSizeY);
	
	cudaMemcpy( pixels_CPU, pixels_GPU, window_width*window_height*3*sizeof(float), cudaMemcpyDeviceToHost );

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

