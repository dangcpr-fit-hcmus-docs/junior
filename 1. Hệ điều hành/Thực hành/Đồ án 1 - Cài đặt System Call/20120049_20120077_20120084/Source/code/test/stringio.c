#include "syscall.h"
char a[256];
int main() {
    PrintString("String length (<256): ");
    ReadString(a, ReadNum());

    PrintString("String input: ");
    PrintString(a);
    PrintString("\n");
    
    Halt();
}