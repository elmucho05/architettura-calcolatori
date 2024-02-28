#include <stdio.h>
#include <stdlib.h>

long long int fatt(long long int n)
{
    if (n<1) return (1);
    else return n* fatt(n-1);
}

int main(){
    long long int a=4;
    printf("%lld",fatt(a));    
    return 0;
}
