#include "arm_mqtt.h"

int get_broker_addr_(AMQTT *amqtt,const char* addr){
    struct hostent *serv_addr;
    serv_addr=gethostbyname(MQTT_ADDR);              //Address already saved in big endian representation: ok network
    if (serv_addr){
        amqtt->mqtt_serv_addr=*(uint32_t*)(serv_addr->h_addr_list[0]);
        return 0;
    } else
    {
        perror("Could not discover server address");
        amqtt->mqtt_serv_addr=0;
        return 1;
    }
    
}

int connect_to_broker_(AMQTT *amqtt){
    amqtt->sock_fd=socket(AF_INET,SOCK_STREAM,0);
    if (amqtt->sock_fd<0){
        perror("Error in creating socket");
        return 1;
    }

}