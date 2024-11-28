#include "symbol_table.h"

SymbolTableEntry *symbol_table = NULL;

void add_variable(const char* name, char* type, int initialized) {
    SymbolTableEntry *entry = malloc(sizeof(SymbolTableEntry));
    entry->name = strdup(name);
    entry->type = strdup(type);
    entry->initialized = initialized;

    HASH_ADD_KEYPTR(hh, symbol_table, entry->name, strlen(entry->name), entry);
}

SymbolTableEntry *find_variable(const char* name) {
    SymbolTableEntry *entry;
    HASH_FIND_STR(symbol_table, name, entry);
    return entry;
}

int check_initialized(const char* name) {
    SymbolTableEntry *entry = find_variable(name);
    if (!entry) {
        fprintf(stderr, "ERROR: Variable '%s' is undeclared.\n", name);
        return -1;
    }
    else if (entry->initialized == 0) {
        fprintf(stderr, "ERROR: Variable '%s' is used without being initialized\n", name);
        return -1;
    }
    return 0;
}

void initialize_variable(const char* name) {
    SymbolTableEntry *entry = find_variable(name);
    if (!entry) {
        fprintf(stderr, "ERROR: Cannot assign to undeclared variable '%s'\n", name);
        return;
    }
    entry->initialized = 1;
}
