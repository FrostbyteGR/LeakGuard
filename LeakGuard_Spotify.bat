@ECHO OFF
REM ############################################################################
REM # Batch script to monitor the system memory consumption while Spotify      #
REM # is running and terminate it should the specified limit be surprassed     #
REM # Copyright (c) 2019 Frostbyte <frostbytegr@gmail.com>                     #
REM #                                                                          #
REM # This program is free software: you can redistribute it and/or modify     #
REM # it under the terms of the GNU General Public License as published by     #
REM # the Free Software Foundation, either version 3 of the License, or        #
REM # (at your option) any later version.                                      #
REM #                                                                          #
REM # This program is distributed in the hope that it will be useful,          #
REM # but WITHOUT ANY WARRANTY; without even the implied warranty of           #
REM # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
REM # GNU General Public License for more details.                             #
REM #                                                                          #
REM # You should have received a copy of the GNU General Public License        #
REM # along with this program.  If not, see <http://www.gnu.org/licenses/>.    #
REM ############################################################################

REM Settings
REM Spotify process name (file extension must be included):
SET spotifyProcess=Spotify.exe
REM Used system memory limit (in GB) to kill Spotify at:
SET usedSystemMemoryLimit=18
REM Percentage of used system memory limit to issue a warning at:
SET warningThreshold=80



REM ##################################################
REM ########## DO NOT EDIT BEYOND THIS LINE ##########
REM ##################################################
REM ########### No seriously, please don't ###########
REM ##################################################

REM Adjust the used system memory limit and warning threshold to KB units.
SET /A usedSystemMemoryLimit=%usedSystemMemoryLimit%*1048576
SET /A usedSystemMemoryWarning=%usedSystemMemoryLimit%*%warningThreshold%/100

:START
REM If Spotify is running, proceed with the checks.
FOR /F %%F IN ('TASKLIST /NH /FI "IMAGENAME EQ %spotifyProcess%"') DO IF %%F == %spotifyProcess% GOTO :CHECK
REM Otherwise, wait for Spotify to launch.
CLS
COLOR 67
CALL :NOTIFY "Process %spotifyProcess% is not currently running."
CALL :NOTIFY "(CTRL+C to quit)"
GOTO :LOOP

:CHECK
REM Calculate current system memory consumption (in KB).
FOR /F "tokens=2 delims==" %%F IN ('WMIC OS GET TotalVisibleMemorySize /VALUE') DO SET totalSystemMemory=%%F
FOR /F "tokens=2 delims==" %%F IN ('WMIC OS GET FreePhysicalMemory /VALUE') DO SET availableSystemMemory=%%F
SET /A usedSystemMemory=%totalSystemMemory%-%availableSystemMemory%

REM If current system memory consumption has reached or surpassed the limit..
IF %usedSystemMemory% GEQ %usedSystemMemoryLimit% (
	REM Terminate the Spotify process, throw error and continue the loop.
	TASKKILL /IM %spotifyProcess% /F
	CLS
	COLOR 47
	CALL :NOTIFY "Process %spotifyProcess% has been killed, because system memory consumption exceeded the %usedSystemMemoryLimit%KB memory limit."
	CALL :NOTIFY "(CTRL+C to quit)"
	GOTO :LOOP
)

REM If current system memory consumption has reached or surprassed the warning threshold..
IF %usedSystemMemory% GEQ %usedSystemMemoryWarning% (
	REM Throw warning and continue the loop.
	CLS
	COLOR 67
	CALL :NOTIFY "System memory consumption has exceeded the %usedSystemMemoryWarning%KB (%warningThreshold% Percent) warning threshold."
	CALL :NOTIFY "(CTRL+C to quit)"
	GOTO :LOOP
)

REM Notify about current system memory consumption.
CLS
COLOR 27
CALL :NOTIFY "System memory consumption is currently within the limit (%usedSystemMemory%/%usedSystemMemoryLimit%KB)."
CALL :NOTIFY "(CTRL+C to quit)"
GOTO :LOOP

REM Loop controller - 10 seconds of delay between cycles.
:LOOP
PING -n 9 127.0.0.1 >NUL
GOTO :START

REM Notification function - Input will be printed out to console.
:NOTIFY
SETLOCAL
ECHO %~1
ENDLOCAL