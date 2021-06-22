#include <stdio.h>
#include <random>
#include <algorithm>
#include <fstream>
#include <string>


#include "table.h"



void gillder_test()
{
	std::ofstream handler("glidder.txt");
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
	for (int i = 0; i < 5; ++i)
	{
		glidder.do_game();
		glidder.write_table_out(handler);
	}
	handler.close();
}

