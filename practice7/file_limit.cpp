#include <iostream>
#include <fstream>
#include <vector>
#include <unistd.h>
#include <string>
#include <cerrno>
#include <cstring>

int main() {
    const int BATCH_SIZE = 1000;
    const int TARGET_FILES = 100000;
    std::vector<std::ofstream> file_streams;
    
    std::cout << "Current PID: " << getpid() << std::endl;
    std::cout << "Attempting to open " << TARGET_FILES << " files...\n";

    for (int batch = 0; batch < TARGET_FILES/BATCH_SIZE; ++batch) {
        for (int i = 0; i < BATCH_SIZE; ++i) {
            std::string filename = "tempfile_" + std::to_string(batch*BATCH_SIZE + i) + ".txt";
            file_streams.emplace_back(filename);
            
            if (!file_streams.back().is_open()) {
                std::cerr << "Error (" << batch*BATCH_SIZE + i << "): " 
                          << strerror(errno) << std::endl;
                std::cerr << "Opened " << file_streams.size()-1 << " files before failure\n";
                return 1;
            }
        }
        std::cout << "Opened " << (batch+1)*BATCH_SIZE << " files. Sleeping...\n";
        sleep(1);
    }

    std::cout << "Successfully opened " << file_streams.size() << " files\n";
    std::cout << "Press Enter to close all files and exit...";
    std::cin.get();

    for (auto& fs : file_streams) {
        fs.close();
    }
    return 0;
}