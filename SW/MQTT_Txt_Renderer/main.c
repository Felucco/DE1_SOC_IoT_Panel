#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <string.h>

#include "core_sys.h"
#include "arm_mqtt.h"
#include "Circ_Buffer.h"

#define REG_BASE 0XFF200000
#define REG_SPAN 0x00200000

#define MEM_DEPTH 8192

#define H_CH 42
#define V_CH 22

#define MEM_CUR (cur_y*H_CH+cur_x)

#define G_N_COLS 20

#define G_HUM_BASE		0x800
#define G_TEMP_BASE		0x800+G_N_COLS
#define G_MAGX_BASE		0x800+2*G_N_COLS
#define G_MAGY_BASE		0x800+3*G_N_COLS
#define G_MAGZ_BASE		0x800+4*G_N_COLS

//#define DEBUG_MODE

void* virtual_base;
void* to_hps_addr;
void* from_hps_addr;
int fd;
uint32_t in_data;

uint8_t cur_x = 0, cur_y = 0;

AMQTT amqtt_instance = DEFAULT_AMQTT;

Circ_Buffer_Handle my_cbs[5];

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

inline uint8_t is_graph_mode();

void send_CB(Circ_Buffer_Handle cb, uint16_t base_mem_loc);

int main (){
	fd = open("/dev/mem",(O_RDWR|O_SYNC));
	virtual_base = mmap(NULL,REG_SPAN,(PROT_READ|PROT_WRITE),MAP_SHARED,fd,REG_BASE);

	to_hps_addr  = virtual_base + HPS_0_TO_HPS_BASE;
	from_hps_addr = virtual_base + HPS_0_FROM_HPS_BASE;

	*(uint32_t*)from_hps_addr=0;
	
	char in_txt [H_CH] = {0};

	uint16_t tmp, tmp2;

	const char* test_topic="unipr/prova/mqttSUB";
	const char* pub_topic="unipr/prova/mqttPUB";

	const char* data_header="Data read";

	//clear_mem();

	AMQTT_Init(&amqtt_instance,MQTT_ADDR,MQTT_PORT);

	for (tmp=0; tmp<5; tmp++){
		my_cbs[tmp]=CB_new_circ_buff(G_N_COLS);
	}

	AMQTT_Subscribe(&amqtt_instance,test_topic);

	char* in_msg;

	char out_msg[6];
	uint8_t old_mode = get_sensor_mode(), new_mode=0;
	uint8_t old_period = get_sensor_period(), new_period=0;
	sprintf(out_msg,"M-%u.%u",old_mode,old_period);
	AMQTT_Publish(&amqtt_instance,out_msg,pub_topic,1);

	/*
	uint8_t graph_values[100];

	size_t i;
	for (i = 0; i < 100; i++)
	{
		graph_values[i]=random()%240;
		write_8b(graph_values[i],0x800+i);
	}
	write_8b(0,0x8a0);*/
	
	float val1,val2,val3;
	char msg_head[20];
	char *msg_head_ptr = msg_head;
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
		if (in_msg) {
			if (is_graph_mode()){
				//1: Check if msg is data msg
				tmp=0;
				msg_head_ptr=msg_head;
				for(;in_msg[tmp]!='\n' && tmp<strlen(in_msg);tmp++); //Discard first line;
				tmp++;
				for(; tmp<strlen(in_msg); tmp++){				
					if (in_msg[tmp]==':'){
						*msg_head_ptr=0;
						break;
					}
					else {
						*msg_head_ptr=in_msg[tmp];
						msg_head_ptr++;
					}
				}
				printf("Message Head: '%s'\n",msg_head);
				if (!strcmp(msg_head,data_header)){
					for(;in_msg[tmp]!='\n' && tmp<strlen(in_msg);tmp++); //Discard till end of header line;
					tmp++;
					msg_head_ptr=msg_head;
					for(; tmp<strlen(in_msg); tmp++){
						if (in_msg[tmp]==':'){
							*msg_head_ptr=0;
							if (!strcmp(msg_head,"Humidity")){
								sscanf(in_msg+tmp+1,"%f",&val1);
								val1 *= 2.35f; //Scale from 0-100 to 0-235
								CB_put(my_cbs[0],(uint8_t)val1);
								send_CB(my_cbs[0],G_HUM_BASE);
							} else if (!strcmp(msg_head,"Temperature")){
								sscanf(in_msg+tmp+1,"%f",&val1);
								//Scale from -20:70 to 0-235
								val1+=20;
								val1 *= (235.0f/90.0f);
								CB_put(my_cbs[1],(uint8_t)val1);
								send_CB(my_cbs[1],G_TEMP_BASE);
							} else if (!strcmp(msg_head,"Magneto")){
								sscanf(in_msg+tmp+2,"x=%f; y=%f; z=%f;",&val1,&val2,&val3);
								//Scale from -4000:4000 to 0-235 (mGauss, max 4 Gauss)
								val1+=4000;
								val1 *= (235.0f/8000.0f);
								val2+=4000;
								val2 *= (235.0f/8000.0f);
								val3+=4000;
								val3 *= (235.0f/8000.0f);
								CB_put(my_cbs[2],(uint8_t)val1);
								send_CB(my_cbs[2],G_MAGX_BASE);
								CB_put(my_cbs[3],(uint8_t)val2);
								send_CB(my_cbs[3],G_MAGY_BASE);
								CB_put(my_cbs[4],(uint8_t)val3);
								send_CB(my_cbs[4],G_MAGZ_BASE);
							}
							for(;in_msg[tmp]!='\n' && tmp<strlen(in_msg);tmp++); //Send cursor to end of line
							msg_head_ptr=msg_head;
						} else if(in_msg[tmp]=='\n'){
							msg_head_ptr=msg_head;
						}
						else {
							*msg_head_ptr=in_msg[tmp];
							msg_head_ptr++;
						}
					}
					write_8b(0,0x8A0);
				}
			} else print_str(in_msg);
		}
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

inline uint8_t is_graph_mode(){
	return (((*(uint32_t*)to_hps_addr) & (0b1<<23))>>23);
}


uint8_t cb_data [G_N_COLS];
void send_CB(Circ_Buffer_Handle cb, uint16_t base_mem_loc){
	uint16_t data_size = CB_get_data(cb,cb_data);
	uint16_t empty_idx;
	for (empty_idx=data_size; empty_idx<G_N_COLS; empty_idx++) cb_data[empty_idx]=cb_data[data_size-1];
	for (empty_idx=0; empty_idx<G_N_COLS; empty_idx++) write_8b(cb_data[empty_idx],base_mem_loc+empty_idx);

	//DEBUG SECTION

	printf("Sent Circular Buffer to %X - %X: [",base_mem_loc, base_mem_loc+G_N_COLS-1);
	for (empty_idx=0; empty_idx<G_N_COLS-1; empty_idx++) printf("%d ; ",cb_data[empty_idx]);
	printf("%d]\n",cb_data[G_N_COLS-1]);
}