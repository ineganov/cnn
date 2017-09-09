// Copileft:
// The code is copied from: http://www.cl.cam.ac.uk/research/srg/han/ACS-P35/ethercrc/
// (C) 2012 DJ Greaves, University of Cambridge, Computer Laboratory. 

#include <stdio.h>


// Generating polynomial:
const unsigned int ethernet_polynomial_le = 0xedb88320U;

//bit-oriented implementation: processes a byte array.
unsigned ether_crc_le(int length, unsigned char *data, int foxes)
{
    unsigned int crc = (foxes) ? 0xffffffff: 0;	/* Initial value. */
    while(--length >= 0) 
      {
	unsigned char current_octet = *data++;
	int bit;
	printf("%02X, %08X,  inv %08X\n", current_octet, crc, ~crc);

	for (bit = 8; --bit >= 0; current_octet >>= 1) {
	  if ((crc ^ current_octet) & 1) {
	    crc >>= 1;
	    crc ^= ethernet_polynomial_le;
	  } else
	    crc >>= 1;
	  
	  printf("Step: %02X, %08X\n", current_octet, crc, ~crc);
	}
      }
    printf("crc final %x\n", crc);
    return crc;
  }


int main (int ac, char ** av)
{

   unsigned char str[] = "ABCD";
   ether_crc_le(4, str, 1);

   return 0;
}


