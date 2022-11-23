#include "Circ_Buffer.h"

Circ_Buffer_Handle CB_new_circ_buff(uint16_t size){
    Circ_Buffer_Handle cb = malloc(sizeof(Circ_Buffer));

    cb->empty=1;
    cb->full=0;
    cb->head=0;
    cb->tail=0;

    cb->buf=malloc(sizeof(uint8_t)*size);
    cb->size=size;
    cb->n_el=0;
    return cb;
}

uint8_t CB_delete (Circ_Buffer_Handle cb){
    free(cb->buf);
    free(cb);
    return 0;
}

uint8_t CB_put(Circ_Buffer_Handle cb, uint8_t data){
    cb->empty=0;
    cb->buf[cb->head]=data;
    cb->head=(cb->head+1)%(cb->size);

    if (!cb->full) cb->n_el++;

    if (!cb->full & cb->head == cb->tail) cb->full=1;
    else if (cb->full) cb->tail=cb->head;
    return 0;
}

uint16_t CB_get_data(Circ_Buffer_Handle cb, uint8_t* out_data){
    if (cb->empty) return 0;
    uint16_t i;
    for (i=0; i<cb->n_el; i++){
        out_data[i] = cb->buf[(cb->tail+i)%cb->size];
    }

    return cb->n_el;
}