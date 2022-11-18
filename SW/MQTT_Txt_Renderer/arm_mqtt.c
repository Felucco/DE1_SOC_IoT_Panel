#include "arm_mqtt.h"

char amqtt_topic [TOP_SIZE];
uint8_t mqtt_callback_buffer [REC_SIZE] = {0};
uint8_t amqtt_recv_buffer [REC_SIZE] = {0};
uint8_t amqtt_send_buffer [SEND_SIZE];

struct mqtt_client amqtt_client;

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

    struct sockaddr_in mqtt_sin;
    mqtt_sin.sin_family=AF_INET;
    mqtt_sin.sin_addr.s_addr=amqtt->mqtt_serv_addr;
    mqtt_sin.sin_port=htons(amqtt->mqtt_serv_port);

    int broker_fd=connect(amqtt->sock_fd,(struct sockaddr*)&mqtt_sin,sizeof(mqtt_sin));

    if (broker_fd < 0){
        perror("Error in connecting to broker");
        return 1;
    }

    fcntl(amqtt->sock_fd, F_SETFL, fcntl(amqtt->sock_fd, F_GETFL) | O_NONBLOCK);

    amqtt->broker_connected=1;
    return 0;
}

void publish_callback_(void** unused,struct mqtt_response_publish *publish){
    strncpy(mqtt_callback_buffer,publish->application_message,publish->application_message_size);
    memset(mqtt_callback_buffer+publish->application_message_size,0,1);
    printf("Received: '%s' \n",mqtt_callback_buffer);
}

int connect_service_(AMQTT *amqtt){
    
    amqtt->client = &amqtt_client;
    amqtt->recvbuf = amqtt_recv_buffer;
    amqtt->sendbuf = amqtt_send_buffer;
    amqtt->topic = amqtt_topic;
    mqtt_init(amqtt->client, amqtt->sock_fd, amqtt->sendbuf, SEND_SIZE,
             amqtt->recvbuf, REC_SIZE, publish_callback_);
    /* Create an anonymous session */
    /* Ensure we have a clean session */
    uint8_t connect_flags = MQTT_CONNECT_CLEAN_SESSION;
    /* Send connection request to the broker. */
    enum MQTTErrors conn_res;
    mqtt_connect(amqtt->client, MQTT_CID, NULL, NULL, 0, NULL, NULL, connect_flags, 400);

    if (amqtt->client->error != MQTT_OK) {
        perror("Error connecting to MQTT service");
        return 1;
    }
    amqtt->service_connected=1;
    return 0;
}

int AMQTT_Init(AMQTT *amqtt,const char* brok_addr, uint16_t port){
    amqtt->mqtt_serv_port=port;
    if (get_broker_addr_(amqtt,brok_addr) != 0) return 1;
    if (connect_to_broker_(amqtt) != 0) return 1;
    if (connect_service_(amqtt) != 0) return 1;
    return 0;
}

int AMQTT_Subscribe(AMQTT *amqtt, const char* topic){
    if (mqtt_subscribe(amqtt->client, topic, 2) != MQTT_OK) return 1;
    return 0;
}

char* AMQTT_Poll(AMQTT *amqtt){
    static char old_msg [REC_SIZE]={0};
    strcpy(old_msg,mqtt_callback_buffer); 
    mqtt_sync(amqtt->client);
    if (strcmp(old_msg,mqtt_callback_buffer)){
		return mqtt_callback_buffer;
	} else{
		return NULL;
	}
}

int AMQTT_Publish(AMQTT *amqtt, const char* msg, const char* topic, uint8_t retain){
    if (msg==NULL || topic==NULL) return 1;
    uint8_t pub_flags = MQTT_PUBLISH_QOS_2;
    if (retain) pub_flags |= MQTT_PUBLISH_RETAIN;
    size_t msg_size = strlen(msg);
    if (mqtt_publish(amqtt->client,topic,(const void*)msg,msg_size,pub_flags) != MQTT_OK) return 1;
    return 0;
}