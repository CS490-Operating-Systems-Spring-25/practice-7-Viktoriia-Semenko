#include <iostream>
#include <fstream>
#include <vector>
#include <unistd.h>
#include <string>

int main() {
    const int MAX_FILES = 20;
    std::vector<std::ofstream> file_streams;
    
    std::cout << "Process PID: " << getpid() << std::endl;
    std::cout << "Opening " << MAX_FILES << " files...\n";
    sleep(60);

    for (int i = 0; i < MAX_FILES; ++i) {
        std::string filename = "test_file_" + std::to_string(i) + ".txt";
        file_streams.emplace_back(filename);
        
        if (!file_streams.back().is_open()) {
            std::cerr << "Failed to open " << filename << std::endl;
            return 1;
        }
        
        file_streams.back() << "Initial content for file " << i << std::endl;
        std::cout << "Opened: " << filename << std::endl;
    }

    std::cout << "Press Enter to close files and exit...";
    std::cin.get();

    for (auto& fs : file_streams) {
        fs.close();
    }

    return 0;
}