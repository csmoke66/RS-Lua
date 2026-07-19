#include <windows.h>
#include <tlhelp32.h>
#include <iostream>
#include <vector>
#include <string>
#include <cstdint>

#define LOG(L, ...) std::cout << "[" << __FUNCTION__ << "][" << #L << "] " << __VA_ARGS__ << std::dec << std::endl;

static std::vector<DWORD> pids_by_name()
{
    auto name_a = std::wstring(L"osrswindows.exe");
    auto name_b = std::wstring(L"osclient.exe");

    std::vector<DWORD> pids;

    PROCESSENTRY32W entry;
    entry.dwSize = sizeof(PROCESSENTRY32W);

    auto snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snapshot == INVALID_HANDLE_VALUE)
    {
        std::cout << "Failed to create th32" << std::endl;
        return pids;
    }

    if (!Process32FirstW(snapshot, &entry))
    {
        CloseHandle(snapshot);
        return pids;
    }

    do
    {
        if (name_a == entry.szExeFile || name_b == entry.szExeFile)
        {
            pids.push_back(entry.th32ProcessID);
        }
    } while (Process32NextW(snapshot, &entry));

    return pids;
}

uint64_t remote_base(DWORD pid)
{
    uintptr_t base = 0;

    auto snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, pid);
    if (snapshot == INVALID_HANDLE_VALUE)
    {
        std::cout << "Failed to create th32" << std::endl;
        return base;
    }

    MODULEENTRY32 entry;
    entry.dwSize = sizeof(entry);

    if (Module32First(snapshot, &entry))
    {
        base = (uintptr_t)entry.modBaseAddr;
    }

    CloseHandle(snapshot);
    return base;
}

static void remote_patch(HANDLE process, uint64_t address, uint8_t *shellcode, size_t shellcode_size, size_t total_size)
{
    uint8_t nops[] = "\x90\x90\x90\x90\x90\x90\x90";

    DWORD old;
    SIZE_T num;

    if (!VirtualProtectEx(process, (void *)address, total_size, PAGE_EXECUTE_READWRITE, &old))
    {
        LOG(ERROR, "Failed to virtual protect " << std::hex << GetLastError());
    }

    if (!WriteProcessMemory(process, (void *)address, shellcode, shellcode_size, &num))
    {
        LOG(ERROR, "Failed to write");
    }

    if (total_size - shellcode_size > 0)
    {
        if (!WriteProcessMemory(process, (char *)address + shellcode_size, nops, total_size - shellcode_size, &num))
        {
            LOG(ERROR, "Failed to write");
        }
    }
    VirtualProtectEx(process, (void *)address, total_size, old, &old);
};

int main(int argc, char **args)
{
    struct Patch
    {
        uint64_t offset;
        uint8_t reg;
        size_t len;
    };

    // 49 8D 8E ? ? ? ? E8 ? ? ? ? 49 8B 8E ? ? ? ? B2
    // scroll up slowly, patch the mov rax/rcx, [+] instructions
    // they're all in a row, read -> write
    static Patch patches[] = {
        {0x11244C, 0xb8, 6},
        {0x112459, 0xb8, 7},
        {0x112467, 0xb8, 6},
        {0x112474, 0xb8, 6},
        {0x112481, 0xb9, 7},
        {0x11248F, 0xb8, 7},
        {0x11249D, 0xb8, 7}};

    uint8_t shellcode[] = {
        0x00, 0x02, 0x00, 0x00, 0x00};

    std::vector<DWORD> pids;
    HANDLE process;
    uint64_t base;
    int ret = 0;

    pids = pids_by_name(L"osrswindows.exe");
    if (pids.empty())
    {
        LOG(ERROR, "Failed to find osrswindows.exe");
        goto _error;
    }

    if (pids.size() != 1)
    {
        LOG(WARN, "Found multiple osrswindows.exe instances");
    }

    process = OpenProcess(PROCESS_ALL_ACCESS, TRUE, pids[0]);
    if (!process)
    {
        LOG(ERROR, "Failed to open process " << pids[0]);
        goto _error;
    }

    base = remote_base(pids[0]);

    LOG(INFO, "Patching " << std::hex << base);
    for (auto &patch : patches)
    {
        LOG(INFO, std::hex << (base + patch.offset));
        shellcode[0] = patch.reg;
        remote_patch(process, base + patch.offset, shellcode, sizeof(shellcode), patch.len);
    }

    LOG(INFO, "Done!");
    goto _cleanup;

_error:
    ret = 1;

_cleanup:
    std::cin.get();
    return ret;
}