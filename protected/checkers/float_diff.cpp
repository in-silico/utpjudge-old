using namespace std;
#include<bits/stdc++.h>

/**
 * Example Checker for floating point answers.
 * Params : Contestant.output, official.output, official.input
 * Return :
 *        0 -> Accepted.
 *        1 -> Presentation error.
 *        >= 2 -> Wrong Answer.
 *
 * Author : Manuel Felipe Pineda.
 * Date   : 14 - 04 - 2014.
 * */


int main (int argc, char ** argv) {

  if (argc < 3) return 5;

  ifstream contestant (argv[1], ifstream::in);
  ifstream official (argv[2], ifstream::in);

  while (contestant.good()) {
    if (!official.good()) return 5; // Printed extra data.
    double a1; contestant>>a1;
    double a2; official>>a2;
    if (fabs(a1 - a2) > 1e-4) return 2;
  }

  if (official.good()) return 5; // Not enough data.

  return 0; // All test passed.
}
