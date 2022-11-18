#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <netdb.h>
#include <fcntl.h>

#include "mqtt.h"

#define MQTT_ADDR   "test.mosquitto.org"
#define MQTT_PORT   1883

#define SEND_SIZE 256
#define REC_SIZE 512

#define TOPIC "UNIPR/EDSE/TEST2"

void get_addr_string(char* output, uint32_t addr_n);

void publish_callback(void** unused,struct mqtt_response_publish *publish);

void* client_refresher(void* client);

void exit_example(int status, int sockfd, pthread_t *client_daemon);

int main(){

    //Step 1: Get MQTT broker address

    printf("Pippo baudo\n");

    struct hostent *serv_addr;
    serv_addr=gethostbyname(MQTT_ADDR);              //Address already saved in big endian representation: ok network
    uint32_t addr_n=*(uint32_t*)(serv_addr->h_addr_list[0]);
    char addr_h [32] = {0};
    get_addr_string(addr_h,addr_n);
    printf("Discovered %s\n",MQTT_ADDR);

    //Step 2: prepare socket

    int sock_fd=socket(AF_INET,SOCK_STREAM,0);

    if (sock_fd<0){
        perror("Error in creating socket");
        return -1;
    }

    //Step 3: prepare MQTT broker address

    struct sockaddr_in mqtt_sin;
    mqtt_sin.sin_family=AF_INET;
    mqtt_sin.sin_addr.s_addr=addr_n;
    mqtt_sin.sin_port=htons(MQTT_PORT);

    //Step 4: connect to MQTT broker

    int broker_fd=connect(sock_fd,(struct sockaddr*)&mqtt_sin,sizeof(mqtt_sin));

    if (broker_fd < 0){
        perror("Error in connecting to broker");
        return -2;
    }

    printf("Connected to %s on port %i\n",MQTT_ADDR,MQTT_PORT);

    fcntl(sock_fd, F_SETFL, fcntl(sock_fd, F_GETFL) | O_NONBLOCK);

    //Step 5: connect to MQTT service

    struct mqtt_client client;
    uint8_t sendbuf[SEND_SIZE];
    uint8_t recvbuf[REC_SIZE];
    mqtt_init(&client, sock_fd, sendbuf, sizeof(sendbuf), recvbuf, sizeof(recvbuf), publish_callback);
    /* Create an anonymous session */
    const char* client_id = "FeluccoTest123";
    /* Ensure we have a clean session */
    uint8_t connect_flags = MQTT_CONNECT_CLEAN_SESSION;
    /* Send connection request to the broker. */
    enum MQTTErrors conn_res;
    mqtt_connect(&client, client_id, NULL, NULL, 0, NULL, NULL, connect_flags, 400);

    if (client.error != MQTT_OK) {
        perror("Error connecting to MQTT service");
        return -3;
    }

    //Step 6: start listening for incoming messages

    /* subscribe */
    mqtt_subscribe(&client, TOPIC, 0);

    while (1)
    {
        mqtt_sync(&client);
        usleep(100000U);
    }
    

    return 0;
}

void get_addr_string(char* output, uint32_t addr_n){
    uint8_t *single_byte_ptr = (uint8_t*) &addr_n;
    sprintf(output,"%i.%i.%i.%i",single_byte_ptr[0],single_byte_ptr[1],single_byte_ptr[2],single_byte_ptr[3]);
}

void publish_callback(void** unused,struct mqtt_response_publish *publish){
    char msg[REC_SIZE] = {0};
    strncpy(msg,publish->application_message,publish->application_message_size);
    printf("Received message '%s' from broker\n",msg);
}