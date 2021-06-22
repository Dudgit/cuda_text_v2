#include "cuda_utility.cuh"

int main()
{
	

	int number_of_steps = 30;
	//Initialize data holder vectors

	std::vector<bool> reff_vec(h * w);
	std::vector<int> gpu_vec(h * w);

	//Fill values of the 2 vector
	generate(reff_vec.begin(), reff_vec.end(), rg::gen);
	std::copy(reff_vec.begin(), reff_vec.end(), gpu_vec.begin());

	//Creating the table object
	table t1(h, w, reff_vec);

	//Creating arrays for host and device
	int* host_array = gpu_vec.data();
	int* device_output;
	cudaMalloc(&device_output, w * h * sizeof(int));

	// Creating the texture object
	cudaArray* cuArray;

	cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc(32, 0, 0, 0, cudaChannelFormatKindSigned);
	error_check(cudaMallocArray(&cuArray, &channelDesc, w, h) ,"allocating memory");
	error_check(cudaMemcpyToArray(cuArray, 0, 0, host_array, w * h * sizeof(int), cudaMemcpyHostToDevice), "copying memory to device");
	//error_check(cudaMemcpy2DToArray(cuArray, 0, 0, host_array, w * h * sizeof(int), w, h, cudaMemcpyHostToDevice),"copy memory to device");
	cudaResourceDesc resDesc;
	memset(&resDesc, 0, sizeof(resDesc));
	resDesc.resType = cudaResourceTypeArray;
	resDesc.res.array.array = cuArray;


	cudaTextureDesc texDesc;
	memset(&texDesc, 0, sizeof(texDesc));
	texDesc.addressMode[0] = cudaAddressModeWrap;
	texDesc.addressMode[1] = cudaAddressModeWrap;
	texDesc.filterMode = cudaFilterModePoint;
	texDesc.readMode = cudaReadModeElementType;
	texDesc.normalizedCoords = 1;

	cudaTextureObject_t texObj = 0;
	cudaCreateTextureObject(&texObj, &resDesc, &texDesc, NULL);
	
	//Output data
	std::ofstream handler_naive("D:/Egyetem/GPU/sok/data/naive_conway.txt");
	std::ofstream handler_gpu("D:/Egyetem/GPU/sok/data/texture_conway.txt");
	gillder_test();
	//Write out, the initial table
	//write_out_result(host_array, handler_gpu);

	t1.write_table_out(handler_naive);
	write_out_result(host_array, handler_gpu);
	
	

	//Executing the simulation
	
	
	for (int i = 0; i < number_of_steps; ++i)
	{
		// One step
		step(host_array,device_output,texObj,cuArray);
		t1.do_game();

		//Write out results
		write_out_result(host_array, handler_gpu);
		t1.write_table_out(handler_naive);
	}

	//Free the allocated memory
	error_check(cudaFree(device_output), "freeing array");

	//Destroy cuda object
	error_check(cudaDestroyTextureObject(texObj), "destroying cuda texture");
	
	error_check(cudaFreeArray(cuArray), "freeing Cuda array");
	handler_gpu.close();
	handler_naive.close();
	
	//Saveing configurations
	std::ofstream cfg("D:/Egyetem/GPU/sok/data/cfg.txt");
	cfg << number_of_steps << ' ' << w << ' ' << h;
	cfg.close();
}