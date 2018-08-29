@ECHO OFF
SETLOCAL EnableDelayedExpansion
REM ############################################################################
REM # Batch script to monitor the memory consumption of a given process        #
REM # and terminate it should it surpass the specified hard limit in GB        #
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
REM Executable name to monitor (file extension must be included):
SET processToMonitor=PoorlyWrittenApp.exe
REM Memory hard limit in GB:
SET processMemoryLimit=10
REM Percentage you want to be warned at:
SET warningThreshold=90



REM ##################################################
REM ########## DO NOT EDIT BEYOND THIS LINE ##########
REM ##################################################
REM ## If you do so, author might lose his religion ##
REM ##################################################

:START
REM If the requested process is running, proceed with the checks.
FOR /F %%F IN ('tasklist /NH /FI "IMAGENAME EQ %processToMonitor%"') DO IF %%F == %processToMonitor% GOTO :CHECK
REM Otherwise, throw error and continue loop.
CLS
COLOR 67
CALL :notify "Process %processToMonitor% is not currently running."
CALL :notify "(CTRL+C to quit)"
GOTO :END

:CHECK
REM Pull the working set (KB) of the requested process.
FOR /F "tokens=*" %%F IN ('tasklist^|findstr %processToMonitor%') DO SET taskDetails=%%F
FOR /F "tokens=5" %%F IN ("%taskDetails%") DO SET memoryConsumption=%%F
SET /A memoryConsumption=%memoryConsumption:,=%

REM Adjust the memory hard limit and the corresponding warning threshold to KB units.
SET /A memoryLimit=%processMemoryLimit%*1048576
SET /A memoryWarning=%memoryLimit%*%warningThreshold%/100

REM If memory consumption reached or surpassed the hard limit..
IF %memoryConsumption% GEQ %memoryLimit% (
	REM Terminate the process, throw error and continue loop.
	TASKKILL /IM %processToMonitor%
	CLS
	COLOR 47
	CALL :notify "Process %processToMonitor% was killed because it exceeded the %processMemoryLimit% GB memory limit."
	CALL :notify "(CTRL+C to quit)"
	GOTO :END
)

REM If memory consumption reached or surpassed the warning threshold..
IF %memoryConsumption% GEQ %memoryWarning% (
	REM Throw warning and continue loop.
	CLS
	COLOR 67
	CALL :notify "Process %processToMonitor% has exceeded %warningThresholdPercent%% (%memoryConsumption% KB) of it's allotted memory."
	CALL :notify "(CTRL+C to quit)"
	GOTO :END
)

REM Notify about current memory consumption.
CLS
COLOR 27
CALL :notify "Process %processToMonitor% is currently within it's allotted memory (%memoryConsumption% KB)."
CALL :notify "(CTRL+C to quit)"
GOTO :END

REM Loop delay of 10 seconds.
:END
PING -n 9 127.0.0.1 >NUL
GOTO :START
GOTO :EOF

REM Notification function - Input will be printed out to console.
:notify
SETLOCAL
ECHO %~1
ENDLOCAL
