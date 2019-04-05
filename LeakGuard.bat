@ECHO OFF
SETLOCAL EnableDelayedExpansion
REM ############################################################################
REM # Batch script to monitor the memory consumption of a given process        #
REM # and terminate it should the specified limit be surprassed                #
REM # Copyright (c) 2018 Frostbyte <frostbytegr@gmail.com>                     #
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
REM Process name to monitor (file extension must be included):
SET processToMonitor=PoorlyWrittenApp.exe
REM Process memory limit (in GB) to kill process at:
SET processMemoryLimit=10
REM Percentage of process memory limit to issue a warning at:
SET warningThreshold=90



REM ##################################################
REM ########## DO NOT EDIT BEYOND THIS LINE ##########
REM ##################################################
REM ## If you do so, author might lose his religion ##
REM ##################################################

REM Adjust the process memory limit and warning threshold to KB units.
SET /A processMemoryLimit=%processMemoryLimit%*1048576
SET /A processMemoryWarning=%processMemoryLimit%*%warningThreshold%/100

:START
REM If the requested process is running, proceed with the checks.
FOR /F %%F IN ('TASKLIST /NH /FI "IMAGENAME EQ %processToMonitor%"') DO IF %%F == %processToMonitor% GOTO :CHECK
REM Otherwise, wait for the requested process to launch.
CLS
COLOR 67
CALL :NOTIFY "Process %processToMonitor% is not currently running."
CALL :NOTIFY "(CTRL+C to quit)"
GOTO :LOOP

:CHECK
REM Fetch the working set of the requested process (in KB).
FOR /F "tokens=*" %%F IN ('TASKLIST^|FINDSTR %processToMonitor%') DO SET taskDetails=%%F
FOR /F "tokens=5" %%F IN ("%taskDetails%") DO SET processMemoryConsumption=%%F
SET /A processMemoryConsumption=%processMemoryConsumption:,=%

REM If current process memory consumption has reached or surpassed the limit..
IF %processMemoryConsumption% GEQ %processMemoryLimit% (
	REM Terminate the requested process, throw error and continue the loop.
	TASKKILL /IM %processToMonitor% /F
	CLS
	COLOR 47
	CALL :NOTIFY "Process %processToMonitor% has been killed, because it's memory consumption exceeded the %processMemoryLimit%KB memory limit."
	CALL :NOTIFY "(CTRL+C to quit)"
	GOTO :LOOP
)

REM If current process memory consumption has reached or surpassed the warning threshold..
IF %processMemoryConsumption% GEQ %processMemoryWarning% (
	REM Throw warning and continue the loop.
	CLS
	COLOR 67
	CALL :NOTIFY "Process %processToMonitor% memory consumption has exceeded the %processMemoryWarning%KB (%warningThreshold% Percent) warning threshold."
	CALL :NOTIFY "(CTRL+C to quit)"
	GOTO :LOOP
)

REM Notify about current process memory consumption.
CLS
COLOR 27
CALL :NOTIFY "Process %processToMonitor% memory consumption is currently within the limit (%processMemoryConsumption%/%processMemoryLimit%KB)."
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