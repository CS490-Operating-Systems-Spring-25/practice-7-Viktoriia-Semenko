#include <iostream>
#include <fstream>
#include <unistd.h> 

int main() {
    std::ofstream outfile("test.txt");

    if (!outfile.is_open()) {
        std::cerr << "Error opening file!" << std::endl;
        return 1;
    }

    for (int i = 0; i < 1000; ++i) {
        outfile << "Line " << i << std::endl << std::flush;
        sleep(1); // wait 1 second between writes
    }

    outfile.close();
    return 0;
}
