#!/usr/bin/env python
import subprocess
from subprocess import run
from datetime import datetime
import os
import time
import shutil

SYNC_FROM = r'D:\Books'
SYNC_TO = r'D:\Books2'
LOG_DIR = r'D:\MY_Tools\sync\SyncLogs'

# keep logs for 30 days
DAYS_TO_KEEP = 30

# Create a unique log file for THIS run
today = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
LOG_FILE = os.path.join(LOG_DIR, f"sync_{today}.log")

# clean up sync log olders than certain days
def cleanup_old_logs(directory, days):
    now = time.time()
    cutoff = now - (days * 86400) # days * seconds in a day
    
    print(f"Checking for logs older than {days} days...")
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        # Only check .txt or .log files
        if os.path.isfile(file_path) and (filename.endswith(".txt") or filename.endswith(".log")):
            if os.path.getmtime(file_path) < cutoff:
                try:
                    os.remove(file_path)
                    print(f"Deleted old log: {filename}")
                except Exception as e:
                    print(f"Could not delete {filename}: {e}")
                finally:
                    print('Checking completed.')


#
#   Arguments
#

# /L            -> display the command without copying, remove when put it to work.
# /LOG+:path    -> Appends the robocopy output to the file
# /V            -> Verbose (shows skipped files; remove if log gets too big)
# /FP           -> Full Path (shows exactly where each file is)
# /TEE          -> Output to BOTH the log file AND the console window
args = ['/Z', '/E','/J', '/FFT', '/COPY:DAT', '/DCOPY:T', '/MT:8', f"/LOG+:{LOG_FILE}", "/TEE"]

#
#   Exclusions
#

# /XD           -> exclude directories, /XD dir1 dir2 dir3
exD = ['/XD', r'Z:\Movies',r'Z:\Games']

# /XF           -> exclude files, /XF file1 file2
exF = ['/XF',".*", "Thumbs.db"]

# /XX           -> exclude extra files or directory exists in the destination but not in the source.
exX = ['/XX']

command = ["robocopy", SYNC_FROM, SYNC_TO]
command.extend(exD)
command.extend(exF)
command.extend(exX)
command.extend(args)

rcMap = {0:'No files copied', 1:'Files copied successfully', 2:'Extra files detected', 3:'Files copied + extras'}

if __name__ == '__main__':

    consent = input(f"Please confirm the SYNC_FROM location is: {SYNC_FROM} \nY/N\n")
    if consent.lower() != 'y':
        exit(r'You can change the SYNC_FROM location in D:\MY_Tools\sync\bin\sync.py')
        
    consent = input(f"Please confirm the SYNC_TO location is: {SYNC_TO} \nY/N\n")
    if consent.lower() != 'y': 
    	exit(r'You can change the SYNC_TO location in D:\MY_Tools\sync\bin\sync.py')
    
    # 1. Ensure the log directory exists
    os.makedirs(LOG_DIR, exist_ok=True)

    # 2. Create a header in the log file using Python
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as f:
        f.write(f"\n{'='*60}\n")
        f.write(f"SYNC START: {timestamp}\n")
        f.write(f"SOURCE: {SYNC_FROM} -> DEST: {SYNC_TO}\n")
        f.write(f"{'='*60}\n")

    try:
        # We use subprocess.run without capture_output because of /TEE 
        # handles the display for us automatically.
        result = run(command,text=True,check=False)
        rcode = result.returncode
        if rcode < 8:
            print(f"Sync completed successfully (Return Code: {rcode}-{rcMap.get(rcode)})")
            
            # 3. append complete message to the log
            with open(LOG_FILE, "a") as f:
                status = "SUCCESS" if rcode < 8 else "FAILED"
                f.write(f"SYNC FINISHED. Status Code: {rcode}-{rcMap.get(rcode)} ({status})\n")
    
            print(f"\nSync complete. Detailed log saved in: {LOG_FILE}")

            # 4. Cleanup Function: Delete logs older than 30 days
            cleanup_old_logs(LOG_DIR, DAYS_TO_KEEP)
    except subprocess.CalledProcessError as e:
        print(f'command returns non-zero exit status {e.returncode} ')
        print(result.stderr)
        #non-zero exit status 16 happens there is extra blank space.
        # That tiny trailing space in '/XF ' is a classic "invisible" bug.
        # In Python’s subprocess, since each list item is passed as a literal argument to the Windows API,
        # Robocopy sees it as a separate, empty, or malformed parameter and crashes.
    except FileNotFoundError:
        print("Robocopy command not found. Ensure it is in your system's PATH")

    
    # copy log file to the SYNC_TO location
    shutil.copy2(LOG_FILE,SYNC_TO)
    print(f"\nSync complete. Detailed log also saved in: {SYNC_TO}\n")

    # prevent the window to be closed automatically in case of error happens.
    input("Press Enter to close this window...")
