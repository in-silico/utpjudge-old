using namespace std;
#include<cstdlib>
#include<string>

int main(int argc, char **argv) {
  if (argc < 3) return 5;
  string line = "diff -wB " +  string(argv[1]) + " " + argv[2];
  int ret = system(line.c_str());
  return ret != 0;
}
