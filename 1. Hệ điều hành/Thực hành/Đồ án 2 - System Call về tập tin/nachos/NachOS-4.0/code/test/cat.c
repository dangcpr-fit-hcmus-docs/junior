#include "syscall.h"
#define MAX_LENGTH 255

int main()
{
    char buffer[100];
    char fileName[MAX_LENGTH + 1];
    int length, fileId, read;
    int len = 0;

    PrintString("Enter file name's length (<=255): ");
    length = ReadNum();

    PrintString("File's name: ");
    ReadString(fileName, length);

    //type=1: read only; type=0: read and write
    fileId = Open(fileName, 1);

    if (fileId != -1)
    {
        read = Read(buffer, 50, fileId);

        while (buffer[len] != '\0') 
            ++len;

        PrintString("Read ");
        PrintNum(len);
        
        PrintString(" characters: ");
        PrintString(buffer);
        PrintString("\n");
        
        Close(fileId);
    }
    else
    {
        PrintString("Fail to open file ");
        PrintString(fileName);
        PrintString("\n");
    }
    Halt();
}