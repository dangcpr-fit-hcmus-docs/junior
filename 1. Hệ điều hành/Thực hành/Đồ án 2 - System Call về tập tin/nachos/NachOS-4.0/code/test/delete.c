#include "syscall.h"
#define MAX_LENGTH 255

int main()
{
    char fileName[MAX_LENGTH + 1];
    int length;

    PrintString("File name's length (<=255): ");
    length = ReadNum();

    PrintString("File's name: ");
    ReadString(fileName, length);

    if (Remove(fileName) == 1)
    {
        PrintString("Succeed in removing file ");
        PrintString(fileName);
        PrintString("\n");
    }
    else 
    {
        PrintString("Fail to remove file ");
        PrintString(fileName);
        PrintString("\n");
    }
}