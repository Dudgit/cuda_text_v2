
#include <vector>
#include <iostream>
#include <fstream>

class table
{
public:
   table( int w,  int h,std::vector<bool> d) : width(w), height(h), data(d) {}
private:
    std::vector<bool> data;
    int width,height;

    int sum_sides(int position);
    int sum_up(int position);
    int sum_down(int position);

public:
    int get_alive(int const& position);
    void write_table_out(std::ofstream & handler);
    void do_game();
    void add_data(int const& pos,bool const& value);
};