/*
Author: Matteo Mannis, UNIPR
Based on [INSERT MQTT GitHub repo]
*/

#ifndef ARM_MQTT_INC_
#define ARM_MQTT_INC_

#include <netinet/in.h>
#include <sys/socket.h>
#include <netdb.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include "mqtt.h"

#define MQTT_ADDR   "test.mosquitto.org"
#define MQTT_PORT   1883
#define MQTT_CID    "Felucco_HPS_31"

#define SEND_SIZE   256
#define REC_SIZE    512
#define TOP_SIZE    64

typedef struct amqtt_{
    uint32_t mqtt_serv_addr;
    uint16_t mqtt_serv_port;
    int sock_fd;
    struct mqtt_client *client;
    char *topic;
    uint8_t *sendbuf;
    uint8_t *recvbuf;
    uint8_t broker_connected;
    uint8_t service_connected;
} AMQTT;

#define DEFAULT_AMQTT {0,0,0,NULL,NULL,NULL,NULL,0,0};

int AMQTT_Init(AMQTT *amqtt,const char* brok_addr, uint16_t port);
int AMQTT_Subscribe(AMQTT *amqtt, const char* topic);
int AMQTT_Publish(AMQTT *amqtt, const char* msg, const char* topic, uint8_t retain);
char* AMQTT_Poll(AMQTT *amqtt);

#endif