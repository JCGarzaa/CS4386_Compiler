#include <stdio.h>
#include <stdlib.h>

int main() {
int SMALLER;
int BIGGER;
int TEMP;
int TEMP1;

scanf("%d", &BIGGER);
scanf("%d", &SMALLER);
if (SMALLER > BIGGER) {
TEMP = SMALLER;
TEMP1 = 2147483647;
SMALLER = BIGGER;
BIGGER = TEMP;
}
while (SMALLER > 0) {
BIGGER = BIGGER - SMALLER;
if (SMALLER > BIGGER) {
TEMP = SMALLER;
SMALLER = BIGGER;
BIGGER = TEMP;
}
}
printf("%d\n", BIGGER);

return 0;
}
