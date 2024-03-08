#include "syscall.h"

#define MAX_LENGTH 255
#define MODE_READWRITE 0
#define MODE_READ 1

int main() {
    //Append the source file to the destination file
    char buffer[100];
    char fileName[MAX_LENGTH + 1];
    char end[1];
    int len = 0, fileId, read, write, temp, length;

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
        PrintNum(temp);

        Close(fileId);
    }
    else 
    {
        PrintString("Fail to open file ");
        PrintString(fileName);
        PrintString("\n");
    }

    // Read file 2
    PrintString("Enter destination file name's length (<=255): ");
    length = ReadNum();

    PrintString("Destination file's name: ");
    ReadString(fileName, length);

    fileId = Open(fileName, MODE_READWRITE);

    if (fileId != -1) 
    {
        temp = Seek(-1, fileId);
        write = Write(buffer, len, fileId);

        PrintString("Write ");
        PrintNum(write);
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