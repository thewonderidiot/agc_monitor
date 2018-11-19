#include <stdio.h>
#include "platform.h"

int main()
{
    init_platform();

    for (;;);

    cleanup_platform();
    return 0;
}
