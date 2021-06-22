
#include "table.h"

int table::sum_sides(int const position)
{
    int l_side = position % width;
    int r_side = (position + 1) % width;

    bool l_value = l_side == 0 ? data[position + width - 1] : data[position - 1];
    bool r_value = r_side == 0 ? data[position - width + 1] : data[position + 1];

    return l_value+r_value;
}

int table::sum_up(int const position)
{
    int new_pos = position < width ? (width - 1) * height + position : position-width; 
    return data[new_pos] + sum_sides(new_pos);
}

int table::sum_down(int const position)
{
    int new_pos = position+width <height*width  ? position+width : position%height;
    return data[new_pos] + sum_sides(new_pos);
}

int table::get_alive(int const& position)
{
    return sum_up(position)+sum_down(position)+sum_sides(position);
}

void table::write_table_out(std::ofstream& handler)
{
    for (int i = 0; i < height; ++i)
    {
        for (int j = 0; j < width; ++j)
        {
            handler << data[i * height + j]<<' ';
        }
        handler << std::endl;
    }
    handler << std::endl;
}

/*
void table::write_table_out_console()
{
    for (int i = 0; i < height; ++i)
    {
        for (int j = 0; j < width; ++j)
        {
            std::cout << data[i * height + j]<<' ';
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}
*/

void table::add_data(int const& pos,bool const& value)
{
    data[pos] = value;
}

void table::do_game()
{
    std::vector<bool> res(height*width);
    for (int i = 0; i < height; ++i)
    {
        for (int j = 0; j < width; ++j)
        {
            int pos = i * height + j;
            bool isalive = data[pos];
            int sum = get_alive(pos);

            res[pos] = (sum == 3) || (isalive && sum == 2);
        }
    }
    data = res;
}