// exception.cc
//	Entry point into the Nachos kernel from user programs.
//	There are two kinds of things that can cause control to
//	transfer back to here from user code:
//
//	syscall -- The user code explicitly requests to call a procedure
//	in the Nachos kernel.  Right now, the only function we support is
//	"Halt".
//
//	exceptions -- The user code does something that the CPU can't handle.
//	For instance, accessing memory that doesn't exist, arithmetic errors,
//	etc.
//
//	Interrupts (which can also cause control to transfer from user
//	code into the Nachos kernel) are handled elsewhere.
//
// For now, this only handles the Halt() system call.
// Everything else core dumps.
//
// Copyright (c) 1992-1996 The Regents of the University of California.
// All rights reserved.  See copyright.h for copyright notice and limitation
// of liability and disclaimer of warranty provisions.

#include "copyright.h"
#include "main.h"
#include "syscall.h"
#include "ksyscall.h"

//----------------------------------------------------------------------
// ExceptionHandler
// 	Entry point into the Nachos kernel.  Called when a user program
//	is executing, and either does a syscall, or generates an addressing
//	or arithmetic exception.
//
// 	For system calls, the following is the calling convention:
//
// 	system call code -- r2
//		arg1 -- r4
//		arg2 -- r5
//		arg3 -- r6
//		arg4 -- r7
//
//	The result of the system call, if any, must be put back into r2.
//
// If you are handling a system call, don't forget to increment the pc
// before returning. (Or else you'll loop making the same system call forever!)
//
//	"which" is the kind of exception.  The list of possible exceptions
//	is in machine.h.
//----------------------------------------------------------------------
char* stringUser2System(int addr, int convert_length = -1) {
    int length = 0;
    bool stop = false;
    char* str;

    do {
        int oneChar;
        kernel->machine->ReadMem(addr + length, 1, &oneChar);
        length++;
        // if convert_length == -1, we use '\0' to terminate the process
        // otherwise, we use convert_length to terminate the process
        stop = ((oneChar == '\0' && convert_length == -1) ||
                length == convert_length);
    } while (!stop);

    str = new char[length];
    for (int i = 0; i < length; i++) {
        int oneChar;
        kernel->machine->ReadMem(addr + i, 1,
                                 &oneChar);  // copy characters to kernel space
        str[i] = (unsigned char)oneChar;
    }
    return str;
}

void stringSys2User(char* str, int addr, int convert_length = -1) {
    int length = (convert_length == -1 ? strlen(str) : convert_length);
    for (int i = 0; i < length; i++) {
        kernel->machine->WriteMem(addr + i, 1,
                                  str[i]);  // copy characters to user space
    }
    kernel->machine->WriteMem(addr + length, 1, '\0');
}


void moveProgramCounter()
{
	/* set previous programm counter (debugging only) */
	// Register[PrevPCReg] = Register[PCReg]
	kernel->machine->WriteRegister(PrevPCReg, kernel->machine->ReadRegister(PCReg));

	/* set programm counter to next instruction */
	// Register[PCReg] = Register[NextPCReg]
	kernel->machine->WriteRegister(PCReg, kernel->machine->ReadRegister(NextPCReg));

	/* set next programm counter for brach execution */
	// Register[NextPCReg] = Register[NextPCReg + 4]
	kernel->machine->WriteRegister(NextPCReg, kernel->machine->ReadRegister(NextPCReg) + 4);
}

void handleSC_Halt()
{
	DEBUG(dbgSys, "Shutdown, initiated by user program.\n");
    SysHalt();
    ASSERTNOTREACHED();
}

void handleSC_Add()
{
	DEBUG(dbgSys, "Add " << kernel->machine->ReadRegister(4) << " + "
                         << kernel->machine->ReadRegister(5) << "\n");

    /* Process SysAdd Systemcall*/
    int result;
    result = SysAdd(
        /* int op1 */ (int)kernel->machine->ReadRegister(4),
        /* int op2 */ (int)kernel->machine->ReadRegister(5));

    DEBUG(dbgSys, "Add returning with " << result << "\n");
    /* Prepare Result */
    kernel->machine->WriteRegister(2, (int)result);

    return moveProgramCounter();
}

//Viet them ham handle o day (de su)

void handleSC_ReadNum()
{
	int result = SysReadNum();
    kernel->machine->WriteRegister(2, result);
    return moveProgramCounter();
}

void handleSC_PrintNum()
{
	int character = kernel->machine->ReadRegister(4);
    SysPrintNum(character);
    return moveProgramCounter();
}

//========================hieu====================
void handleSC_ReadChar() {
    char result = SysReadChar();
    kernel->machine->WriteRegister(2, (int)result);
    return moveProgramCounter();
}

void handleSC_PrintChar() {
    char character = (char)kernel->machine->ReadRegister(4);
    SysPrintChar(character);
    return moveProgramCounter();
}

void handleSC_RandomNum() {
    int result;
    result = SysRandomNum();
    kernel->machine->WriteRegister(2, result);
    return moveProgramCounter();
}

#define MAX_READ_STRING_LENGTH 255
void handleSC_ReadString() {
    int memPtr = kernel->machine->ReadRegister(4);  // read address of C-string
    int length = kernel->machine->ReadRegister(5);  // read length of C-string
    if (length > MAX_READ_STRING_LENGTH) {  // avoid allocating large memory
        DEBUG(dbgSys, "String length exceeds " << MAX_READ_STRING_LENGTH);
        SysHalt();
    }
    char* buffer = SysReadString(length);
    stringSys2User(buffer, memPtr);
    delete[] buffer;
    return moveProgramCounter();
}

void handleSC_PrintString() {
    int memPtr = kernel->machine->ReadRegister(4);  // read address of C-string
    char* buffer = stringUser2System(memPtr);

    SysPrintString(buffer, strlen(buffer));
    delete[] buffer;
    return moveProgramCounter();
}


void ExceptionHandler(ExceptionType which)
{
	int type = kernel->machine->ReadRegister(2);

	DEBUG(dbgSys, "Received Exception " << which << " type: " << type << "\n");

	switch (which)
	{
	case NoException:
		kernel->interrupt->setStatus(SystemMode);
		DEBUG(dbgSys, "Switch to system mode\n");
		break;
	case PageFaultException:
	case ReadOnlyException:
	case BusErrorException:
	case AddressErrorException:
	case OverflowException:
	case IllegalInstrException:
	case NumExceptionTypes:
		cerr << "Error " << which << " occurs\n";
		SysHalt();
		ASSERTNOTREACHED();
	case SyscallException:
		switch (type)
		{
		case SC_Halt:
			return handleSC_Halt();
			//break;
		case SC_Add:
			return handleSC_Add();
			//break;
		case SC_ReadNum:
			return handleSC_ReadNum();
			//break;
		case SC_PrintNum:
			return handleSC_PrintNum();
			//break;

		//Nguyen Van Hieu
		case SC_ReadChar:
                return handleSC_ReadChar();
        case SC_PrintChar:
                return handleSC_PrintChar();
        case SC_RandomNum:
        	return handleSC_RandomNum();
        case SC_ReadString:
                return handleSC_ReadString();
   
		//Nguyen Hai Dang
		case SC_PrintString:
			return handleSC_PrintString();

		// Phan phia duoi dung thay doi !!
		default:
			cerr << "Unexpected system call " << type << "\n";
			break;
		}
		break;
	default:
		cerr << "Unexpected user mode exception" << (int)which << "\n";
		break;
	}
	ASSERTNOTREACHED();
}

