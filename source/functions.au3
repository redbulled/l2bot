#include <SendMessage.au3>
#include "input.au3"
#include "FastFind.au3"

ProcessHide(@AutoItPID)
WaitGrabCommand()

Sleep(200)

; This is needed for Windows Vista and above
#RequireAdmin
;#NoTrayIcon

Opt("SendKeyDownDelay", 10)
Opt("PixelCoordMode", 2)
Opt("MouseCoordMode", 2)

global const $kMinute = 60 * 1000
global const $kErrorCoord = -1
global const $kToggleCount = 12
global $gToggleList[$kToggleCount]
global $gCurrentSnapShot = -1

func ProcessHide($PID)
	DllCall("HideProcessNT.dll","long","HideNtProcess","dword",$PID)
endfunc

func WaitGrabCommand()
	while not $gIsGrab
		Sleep(1)
	wend
endfunc

func SendClient($key, $delay)
	LogWrite("SendClient() - " & $key)
	_Send($key, 0)
	_Sleep($delay)
endfunc

func SendSymbolClient($key, $delay)
	LogWrite("SendSymbolClient() - " & $key)
	_Send($key, 1)
	_Sleep($delay)
endfunc

func SendSplitText($text)
	local $key_array = StringSplit($text, "")

	for $i = 1 to $key_array[0] step 1
		if $key_array[$i] == "!" or $key_array[$i] == "/" then
			_Send($key_array[$i], 1)
		else
			_Send($key_array[$i])
		endif
		_Sleep(20)
	next
	_Sleep(200)
endfunc

func SendTextClient($text)
	LogWrite("SendTextClient() - " & $text)

	_Send($kEnterKey)
	_Sleep(200)

	SendSplitText($text)
	
	_Send($kEnterKey)
	_Sleep(500)
endfunc

func IsPixelExistClient($window_left, $window_right, $color)
	local $coord = PixelSearch($window_right[0], $window_right[1], $window_left[0], $window_left[1], $color, 1)
	if not @error then
		return true
	else
		return false
	endif
endfunc

func IsPixelsChanged($left, $right)
	LogWrite("IsPixelsChanged()")
	
	if $gCurrentSnapShot == -1 then
		$gCurrentSnapShot = 1
		LogWrite("	- init first snapshot = " & $gCurrentSnapShot)
		FFSnapShot($left[0], $left[1], $right[0], $right[1], $gCurrentSnapShot)
		return true
	endif
	
	local $prev_snapshot = $gCurrentSnapShot
	
	if $gCurrentSnapShot == 1 then
		$gCurrentSnapShot = 2
	else
		$gCurrentSnapShot = 1
	endif
	
	FFSnapShot($left[0], $left[1], $right[0], $right[1], $gCurrentSnapShot)
	
	local $result = FFIsDifferent($prev_snapshot, $gCurrentSnapShot)
	LogWrite("	- snapshot compare result = " & $result)	
	return $result
endfunc

func GetPixelCoordinateClient($window_left, $window_right, $color)
	local $coord = PixelSearch($window_right[0], $window_right[1], $window_left[0], $window_left[1], $color, 4)
	
	if not @error then
		return $coord
	else
		local $error[2] = [$kErrorCoord, $kErrorCoord]
		return $error
	endif
endfunc

func GetPixelColorClient($point)
	return PixelGetColor($point[0], $point[1])
endfunc

func MouseClickClient($botton, $x, $y)
	LogWrite("MouseClickClient() - " & $botton & " x = " & $x & " y = " & $y)
	MouseClick($botton, $x, $y)
endfunc

func GetBarValue($coord, $bar_left, $bar_right)
	local $result = ($coord[0] - $bar_left[0]) / ($bar_right[0] - $bar_left[0]) * 100
	
	LogWrite("GetBarValue() - result = " & Round($result, 2) & "%")
	
	return $result
endfunc

func SwitchToggle($number, $key, $state)
	LogWrite("SwitchToggle() - number = " & $number & " key = " & $key & " state = " & $state)
	
	if $kToggleCount <= $number then
		return
	endif
	
	if $gToggleList[$number] == $state then
		return
	endif
	
	SendClient($key, 1000)
	$gToggleList[$number] = $state
endfunc

func _Sleep($delay)
	SRandom(@MSEC)
	local $gap = $delay * 0.1
	$delay = $delay - $gap + Random(0, $gap, 1) + Random(0, $gap, 1)
	
	if $delay < 10 then
		$delay = 10
	endif
	
	Sleep($delay)
endfunc
