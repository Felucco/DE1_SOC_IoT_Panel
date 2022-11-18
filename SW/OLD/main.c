#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <string.h>

#include "core_sys.h"

#define REG_BASE 0XFF200000
#define REG_SPAN 0x00200000

#define MEM_DEPTH 8192

#define H_CH 42
#define V_CH 22

#define MEM_CUR (cur_y*H_CH+cur_x)

//#define DEBUG_MODE

void* virtual_base;
void* to_hps_addr;
void* from_hps_addr;
int fd;
uint32_t in_data;

uint8_t cur_x = 0, cur_y = 0;

inline uint8_t op_completed(){
	return (
		(*(uint32_t*)to_hps_addr) >> 31
		);
}

void write_8b(uint8_t data, uint16_t addr);

void write_16b(uint16_t data, uint16_t addr);

uint8_t read_8b(uint16_t addr);

uint16_t read_16b(uint16_t addr);

void clear_mem();

int main (){
	fd = open("/dev/mem",(O_RDWR|O_SYNC));
	virtual_base = mmap(NULL,REG_SPAN,(PROT_READ|PROT_WRITE),MAP_SHARED,fd,REG_BASE);

	to_hps_addr  = virtual_base + HPS_0_TO_HPS_BASE;
	from_hps_addr = virtual_base + HPS_0_FROM_HPS_BASE;

	uint8_t d8;
	uint16_t d16;

	*(uint32_t*)from_hps_addr=0;
	
	char in_txt [H_CH] = {0};

	uint8_t tmp;

	clear_mem();

	while (1)
	{
		printf("Insert text: ");
		fgets(in_txt,H_CH,stdin);
		tmp=0;
		for(;tmp<strlen(in_txt);tmp++){
			write_8b((uint8_t)in_txt[tmp],MEM_CUR);
			cur_x++;
		}
		cur_x=0;
		cur_y++;
	}
	
	
	return 0;
}

void write_8b(uint8_t data, uint16_t addr){
	uint32_t out_data = 0b110 << 29;
	addr &= MEM_DEPTH-1; //Max addr MEM_DEPTH-1
	out_data |= ((uint32_t)addr) << 16;
	out_data |= data;
	*(uint32_t*)from_hps_addr=out_data;
	while (!op_completed());
	*(uint32_t*)from_hps_addr=0;
	#ifdef DEBUG_MODE
	printf("Issued command %u\n",out_data);
	#endif
}

void write_16b(uint16_t data, uint16_t addr){
	uint32_t out_data = 0b111 << 29;
	addr &= MEM_DEPTH-1; //Max addr MEM_DEPTH-1
	out_data |= ((uint32_t)addr) << 16;
	out_data |= data;
	*(uint32_t*)from_hps_addr=out_data;
	while (!op_completed());
	*(uint32_t*)from_hps_addr=0;
	#ifdef DEBUG_MODE
	printf("Issued command %u\n",out_data);
	#endif
}

uint8_t read_8b(uint16_t addr){
	uint32_t out_data = 0b100 << 29;
	uint8_t res;
	addr &= MEM_DEPTH-1; //Max addr MEM_DEPTH-1
	out_data |= ((uint32_t)addr) << 16;
	*(uint32_t*)from_hps_addr=out_data;
	while (!op_completed());
	res=(*(uint32_t*)to_hps_addr)&0xFF;
	*(uint32_t*)from_hps_addr=0;
	#ifdef DEBUG_MODE
	printf("Issued command %u\n",out_data);
	#endif
	return res;
}

uint16_t read_16b(uint16_t addr){
	uint32_t out_data = 0b101 << 29;
	uint16_t res;
	addr &= MEM_DEPTH-1; //Max addr MEM_DEPTH-1
	out_data |= ((uint32_t)addr) << 16;
	*(uint32_t*)from_hps_addr=out_data;
	while (!op_completed());
	res=(*(uint32_t*)to_hps_addr)&0xFFFF;
	*(uint32_t*)from_hps_addr=0;
	#ifdef DEBUG_MODE
	printf("Issued command %u\n",out_data);
	#endif
	return res;
}

void clear_mem(){
	uint16_t addr = 0;
	for(;addr<MEM_DEPTH-1;addr+=2){
		write_16b(0x0000,addr);
	}
}