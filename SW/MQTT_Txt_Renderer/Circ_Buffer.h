#ifndef CIRC_BUFFER_H_
#define CIRC_BUFFER_H_

#include <stdint.h>
#include <stdlib.h>

typedef struct 
{
    uint8_t *buf;
    uint16_t size, n_el;
    uint16_t head, tail;
    uint8_t empty, full;
} Circ_Buffer;

typedef Circ_Buffer* Circ_Buffer_Handle;

Circ_Buffer_Handle CB_new_circ_buff(uint16_t size);

uint8_t CB_delete (Circ_Buffer_Handle cb);

uint8_t CB_put(Circ_Buffer_Handle cb, uint8_t data);

uint16_t CB_get_data(Circ_Buffer_Handle cb, uint8_t* out_data);



#endif