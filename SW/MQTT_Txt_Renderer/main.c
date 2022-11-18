#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <string.h>

#include "core_sys.h"
#include "arm_mqtt.h"

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

AMQTT amqtt_instance = DEFAULT_AMQTT;

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

void print_str(char* str);

inline uint8_t get_sensor_mode();

inline uint8_t get_sensor_period();

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

	const char* test_topic="unipr/prova/mqttSUB";
	const char* pub_topic="unipr/prova/mqttPUB";

	clear_mem();

	AMQTT_Init(&amqtt_instance,MQTT_ADDR,MQTT_PORT);

	AMQTT_Subscribe(&amqtt_instance,test_topic);

	char* in_msg;

	char out_msg[6];
	uint8_t old_mode = get_sensor_mode(), new_mode=0;
	uint8_t old_period = get_sensor_period(), new_period=0;
	sprintf(out_msg,"M-%u.%u",old_mode,old_period);
	AMQTT_Publish(&amqtt_instance,out_msg,pub_topic,1);

	while (1)
	{
		new_mode=get_sensor_mode();
		new_period=get_sensor_period();
		//printf("Read M-%u.%u\n",new_mode,new_period);
		if (new_mode != old_mode || new_period != old_period){
			old_mode=new_mode;
			old_period=new_period;
			sprintf(out_msg,"M-%u.%u",old_mode,old_period);
			AMQTT_Publish(&amqtt_instance,out_msg,pub_topic,1);
			printf("Sent '%s' to MQTT\n",out_msg);
		}
		in_msg=AMQTT_Poll(&amqtt_instance);
		if (in_msg) print_str(in_msg);
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

void clear_line_(){
	cur_x=0;
	for(;cur_x<H_CH;cur_x++){
		write_8b(0,MEM_CUR);
	}
	cur_x=0;
}

void new_line_(){
	cur_y = (cur_y+1+cur_x/H_CH)%V_CH;
	cur_x=0;
	cur_y = (cur_y+1)%V_CH;
	clear_line_();
	if (cur_y==0) cur_y=V_CH-1;
	else cur_y--;
}

void print_str(char* str){
	uint16_t tmp=0;
	uint8_t add_nl = 1;
	for(;tmp<strlen(str);tmp++){
		if (str[tmp] == '\n'){
			new_line_();
			add_nl=0;
		}
		else{
			write_8b((uint8_t)str[tmp],MEM_CUR);
			cur_x++;
			add_nl=1;
		}
	}	
	if (add_nl) new_line_();
}

inline uint8_t get_sensor_mode(){
	return (((*(uint32_t*)to_hps_addr) & 0x70000000) >> 28);
}

inline uint8_t get_sensor_period(){
	return (((*(uint32_t*)to_hps_addr) & 0x0F000000) >> 24);
}