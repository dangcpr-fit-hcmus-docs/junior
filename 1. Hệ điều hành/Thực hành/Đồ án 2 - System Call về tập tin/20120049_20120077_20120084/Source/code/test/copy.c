#include "syscall.h"

#define MAX_LENGTH 255
#define MODE_READWRITE 0
#define MODE_READ 1

#define stdin 0
#define stdout 1

int main()
{
    char buffer[100];
    char fileName[MAX_LENGTH + 1];
    int length, fileId, read, write;
    int len = 0;

    // Read file 1
    PrintString("Enter source file name's length (<=255): ");
    length = ReadNum();

    PrintString("Source file's name: ");
    ReadString(fileName, length);

    // Exclude \0 after press Enter
    ReadString("\0", 1);

    fileId = Open(fileName, MODE_READ);

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
        
        // Write file 2
        PrintString("Enter destination file name's length (<=255): ");
        length = ReadNum();

        PrintString("Destination file's name: ");
        ReadString(fileName, length);

        if ((Remove(fileName) == -1) || (Create(fileName) == -1))
        {
            PrintString("Fail to paste to file ");
            PrintString(fileName);
            PrintString("\n");
        }
        else
        {
            fileId = Open(fileName, MODE_READWRITE);

            write = Write(buffer, len, fileId);

            PrintString("Write ");
            PrintNum(write);

            PrintString(" characters: ");
            PrintString(buffer);
            PrintString("\n");

            Close(fileId);
        }
    }
    else
    {
        PrintString("Fail to open file ");
        PrintString(fileName);
        PrintString("\n");
    }
    Halt();
}