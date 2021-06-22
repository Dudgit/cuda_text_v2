#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "cuda_texture_types.h"
#include "texture_fetch_functions.h"
#include "texture_types.h"

#include <stdio.h>
#include <random>
#include <algorithm>
#include <fstream>
#include <string>
#include <iostream>

#include "table.cpp"

const int h = 50;
const int w = 50;
const int block_size = 50;



dim3 dimBlock(w / block_size, h / block_size);
dim3 dimGrid(block_size, block_size);



__global__ void texture_c(int* output, cudaTextureObject_t texobj)
{
	unsigned int tx = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int ty = blockIdx.y * blockDim.y + threadIdx.y;
	
	
	float corr = 0.01f;
	float push = 2 * corr;

	float x = tx / (float)w + corr; 
	float y = ty / (float)h + corr;


	int sum = tex2D<int>(texobj, x - push, y - push)+tex2D<int>(texobj, x, y - push) + tex2D<int>(texobj, x + push, y - push)
		+ tex2D<int>(texobj, x - push, y) + tex2D<int>(texobj, x + push, y)
		+ tex2D<int>(texobj, x - push, y + push) + tex2D<int>(texobj, x, y + push) + tex2D<int>(texobj, x + push, y + push);
	int isalive = tex2D<int>(texobj, x, y);

	int res = 0;
	if (sum == 3 || isalive && sum == 2) res = 1;

	output[ty * h + tx] = res;
}



namespace rg
{
	//Creating a random number generator
	std::random_device rd{};
	std::mt19937 mersenne_engine{ rd() };
	std::uniform_real_distribution<float> dist{ 0, 100 };
	auto gen = []() { return dist(mersenne_engine) < 50 ? false : true; };
}

void gillder_test()
{
	std::ofstream handler("D:/Egyetem/GPU/sok/data/glidder.txt");
	std::vector<bool> g1 =
	{
		0,0,0,0,0,0,
		0,0,1,0,0,0,
		1,0,1,0,0,0,
		0,1,1,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0
	};

	table glidder(6, 6, g1);
	
	glidder.write_table_out(handler);
	for (int i = 0; i < 30; ++i)
	{
		glidder.do_game();
		glidder.write_table_out(handler);
	}
	handler.close();
}

void write_line(int* res,std::ofstream& handler,int x)
{
	for (int y = 0; y < w; ++y)
	{
		std::cout << res[x * h + y] << ' ';
	}
}

void write_out_result(int* res,std::ofstream& handler)
{
	for (int x = 0; x < h; ++x)
	{
		for(int y = 0;y<w;++y)
		{
			handler<<res[h*x+y]<<' ';
		}
		handler << std::endl;
	}
	handler  << std::endl;
}



void run_kernel(int* output, cudaTextureObject_t& texObj, int* hOutput, int h, int w)
{
	texture_c <<< dimGrid, dimBlock >>> (output, texObj);

	//auto err = cudaMemcpy2DToArray(hOutput, 0 , 0 ,output, w * h * sizeof(int),w ,h ,cudaMemcpyDeviceToHost);
	auto err = cudaMemcpy(hOutput,output,w * h * sizeof(int), cudaMemcpyDeviceToHost);
	if (err != cudaSuccess) { std::cout << "Error copying memory to host: " << cudaGetErrorString(err) << "\n"; }

}

void step(int* h_array,int* device_output,cudaTextureObject_t texObj,cudaArray* cuArray)
{
	
	run_kernel(device_output, texObj, h_array, h, w);

	// The texture memory is binded with the cuda array
	auto err = cudaMemcpyToArray(cuArray, 0, 0, h_array, w * h * sizeof(int), cudaMemcpyHostToDevice);
	if (err != cudaSuccess) { std::cout << "Error copying memory to device: " << cudaGetErrorString(err) << "\n"; }

}


int error_check(cudaError_t const& err, std::string const& err_s)
{
	if (err != cudaSuccess)
	{
		std::cout << "Error in " << err_s << " :" << cudaGetErrorString(err) << std::endl;
	}
	return -1;
}