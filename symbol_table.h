#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "uthash.h"

typedef struct SymbolTableEntry {
    char* name;
    char* type;
    int initialized;
    UT_hash_handle hh;
} SymbolTableEntry;

// function declarations (prototypes)
void add_variable(const char* name, char* type, int initialized);
SymbolTableEntry *find_variable(const char* name);
int check_initialized(const char* name);
void initialize_variable(const char* name);

#endif
