; #FUNCTION# ====================================================================================================================
; Name ..........: GetAttackBarBB
; Description ...: Gets the troops and there quantities for the current attack
; Syntax ........:
; Parameters ....: None
; Return values .: array attackBar
; Author ........: xbebenk
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================


#comments-start
	$aAttackBar[n][8]
	[n][0] = Name of the found Troop/Spell/Hero/Siege
	[n][1] = The X Coordinate of the Troop
	[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
	[n][3] = The Slot Number (Starts with 0)
	[n][4] = The Amount
#comments-end	
	
Func GetAttackBarBB($bRemaining = False, $bSecondAttack = False)
	Local $iTroopBanners = 585
	Local $iTroopAreaY = 600
	Local $iSelectTroopY = 610
	Local $aBBAttackBar[0][5]
	Local $aEmpty[0][2]
	If Not $bRemaining Then
		$g_bWBOnAttackBar = False
		$g_aWBOnAttackBar = $aEmpty
	EndIf

	Local $iMaxSlot = 9, $iSlotOffset = 75.5
	Local $aSlotX[$iMaxSlot], $iStartSlot = 100

	If GetMachinePos() = 0 Then $iStartSlot = 23
	For $i = 0 To UBound($aSlotX) - 1
		$aSlotX[$i] = $iStartSlot + ($i * $iSlotOffset)
	Next

	If Not $g_bRunState Then Return

	Local $iCount = 1, $isBlueBanner = False, $isDarkGreyBanner = False, $isGreyBanner = False, $isVioletBanner = False
	Local $Troop = "", $Troopx = 0, $Troopy = 0, $ColorPickBannerX = 0
	Local $bReadTroop = False

	For $k = 0 To UBound($aSlotX) - 1
		If Not $g_bRunState Then Return

		$Troopx = $aSlotX[$k]
		$ColorPickBannerX = $aSlotX[$k] + 34
		Local $sPixelColor = _GetPixelColor($ColorPickBannerX, $iTroopBanners, True)

		Local $bFoundTroop = QuickMIS("BC1", $g_sImgDirBBTroops, $Troopx, $iTroopAreaY, $Troopx + 70, 670)
		Local $sDetectedImage = ($bFoundTroop ? $g_iQuickMISName : "")
		If Not $bFoundTroop Then
			If QuickMIS("BC1", $g_sImgDirBBTroops, $Troopx - 3, $iTroopBanners, $Troopx + 73, 670) Then
				$sDetectedImage = $g_iQuickMISName
				$bFoundTroop = True
			EndIf
		EndIf

		; RGB heuristic — survives color drift from game UI updates
		Local $iR = Dec(StringMid($sPixelColor, 1, 2))
		Local $iG = Dec(StringMid($sPixelColor, 3, 2))
		Local $iB = Dec(StringMid($sPixelColor, 5, 2))
		Local $bLooksViolet = ($iR > 150 And $iB > 150 And $iG < 150)
		Local $bLooksBlue = ($iB > 200 And $iR < 150 And $iG < 200) Or ($iB > 180 And $iR < 100 And $iG > 100)
		Local $bLooksGreenHP = ($iG > 200 And $iR < 200 And $iB < 100)

		$isBlueBanner = _ColorCheck($sPixelColor, Hex(0x4482FE, 6), 35, Default, "isBlueBanner") Or _
			_ColorCheck($sPixelColor, Hex(0x3E7BFF, 6), 35, Default, "isBlueBannerAlt") Or _
			_ColorCheck($sPixelColor, Hex(0x3874FF, 6), 35, Default, "isBlueBannerXb") Or _
			$bLooksBlue

		$isVioletBanner = _ColorCheck($sPixelColor, Hex(0xCA4AFF, 6), 35, Default, "isVioletBanner") Or _
			_ColorCheck($sPixelColor, Hex(0xC73DFE, 6), 35, Default, "isVioletBannerAlt") Or _
			_ColorCheck($sPixelColor, Hex(0xC434FC, 6), 35, Default, "isVioletBannerXb") Or _
			$bLooksViolet

		Local $isVioletSelected = _ColorCheck($sPixelColor, Hex(0xD77AFF, 6), 30, Default, "isVioletSelected") Or _
			_ColorCheck($sPixelColor, Hex(0xCD54FF, 6), 30, Default, "isVioletSelectedAlt") Or _
			_ColorCheck($sPixelColor, Hex(0xDF9BFF, 6), 30, Default, "isVioletSelectedBright")

		Local $isPhase2Violet = False, $isPhase2Selected = False
		If $bSecondAttack Then
			$isPhase2Violet = _ColorCheck($sPixelColor, Hex(0x12244B, 6), 30, Default, "isPhase2Violet") Or _
				_ColorCheck($sPixelColor, Hex(0x10224B, 6), 30, Default, "isPhase2VioletAlt")
			$isPhase2Selected = _ColorCheck($sPixelColor, Hex(0x15274A, 6), 30, Default, "isPhase2Selected")
		EndIf

		$isGreyBanner = _ColorCheck($sPixelColor, Hex(0x7B7B7B, 6), 15, Default, "isGreyBanner") Or _
			_ColorCheck($sPixelColor, Hex(0x707070, 6), 15, Default, "isGreyBannerAlt") Or _
			_ColorCheck($sPixelColor, Hex(0x737373, 6), 15, Default, "isGreyBannerAlt2")
		$isDarkGreyBanner = _ColorCheck($sPixelColor, Hex(0x282828, 6), 20, Default, "isDarkGreyBanner")
		Local $isGreenHPBar = $bLooksGreenHP Or _ColorCheck($sPixelColor, Hex(0x9BFF30, 6), 20, Default, "isGreenHPBar")

		If $isGreyBanner Or $isDarkGreyBanner Or $isGreenHPBar Then ContinueLoop

		$bReadTroop = $isBlueBanner Or $isVioletBanner Or $isVioletSelected Or $isPhase2Violet Or $isPhase2Selected
		If Not $bReadTroop Then ContinueLoop

		$Troop = ($sDetectedImage <> "" ? $sDetectedImage : "Unknown")
		$Troopy = $iSelectTroopY

		$iCount = Number(getOcrAndCapture("coc-tbb", $ColorPickBannerX, $iTroopBanners - 8, 31, 16, True))
		If $iCount = "" Or $iCount = 0 Then $iCount = Number(getOcrAndCapture("coc-tbb", $ColorPickBannerX, $iTroopBanners - 14, 31, 16, True))
		If $iCount = "" Or $iCount < 1 Then $iCount = 1

		Local $aTempElement[1][5] = [[$Troop, $Troopx, $Troopy, $k, $iCount]]
		_ArrayAdd($aBBAttackBar, $aTempElement)
	Next

	If UBound($aBBAttackBar) = 0 Then Return ""
	
	_ArraySort($aBBAttackBar, 0, 0, 0, 3)
	For $i = 0 To UBound($aBBAttackBar) - 1
		SetLog("Slot[" & $aBBAttackBar[$i][3] & "] " & $aBBAttackBar[$i][0] & ", (" & $aBBAttackBar[$i][1] & "," & $aBBAttackBar[$i][2] & "), Count: " & $aBBAttackBar[$i][4], $COLOR_SUCCESS)
		If Not $bRemaining And $aBBAttackBar[$i][0] = "WallBreaker" Then
			$g_bWBOnAttackBar = True
			_ArrayAdd($g_aWBOnAttackBar, $aBBAttackBar[$i][1] & "|" & $aBBAttackBar[$i][2])
		EndIf
	Next
	If $g_bChkDebugAttackBB And UBound($g_aWBOnAttackBar) > 0 Then SetLog("WBOnAttackBar=" & String($g_bWBOnAttackBar) & " : " & _ArrayToString($g_aWBOnAttackBar, ",", Default, Default, "|"), $COLOR_DEBUG2)
	Return $aBBAttackBar
EndFunc

Global Const $g_asAttackBarBB2[$g_iBBTroopCount + 1] = ["Barbarian", "Archer", "BoxerGiant", "Minion", "WallBreaker", "BabyDrag", "CannonCart", "Witch", "DropShip", "SuperPekka", "HogGlider", "ElectroWizard", "Machine"]
Global Const $g_asBBTroopShortNames[$g_iBBTroopCount + 1] = ["Barb", "Arch", "Giant", "Minion", "Breaker", "BabyD", "Cannon", "Witch", "Drop", "Pekka", "HogG", "EWiza", "Machine"]
Global Const $g_sTroopsBBAtk[$g_iBBTroopCount + 1] = ["Raged Barbarian", "Sneaky Archer", "Boxer Giant", "Beta Minion", "Bomber Breaker", "Baby Dragon", "Cannon Cart", "Night Witch", "Drop Ship", "Super Pekka", "Hog Glider", "Electro Wizard", "Battle Machine"]

Func TestCorrectAttackBarBB()
	Local $aAvailableTroops = GetAttackBarBB()
	CorrectAttackBarBB($aAvailableTroops)
	Return $aAvailableTroops
EndFunc   ;==>TestCorrectAttackBarBB

#comments-start
		$aAttackBar[n][8]
		[n][0] = Name of the found Troop/Spell/Hero/Siege
		[n][1] = The X Coordinate of the Troop
		[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
		[n][3] = The Slot Number (Starts with 0)
		[n][4] = The Amount
#comments-end

Func CorrectAttackBarBB(ByRef $aBBAttackBar, $bSecondAttack = False)
	If Not $g_bRunState Then Return
	
	For $i = 0 To UBound($aBBAttackBar) - 1
		SetLog("Detected Troop [" & $aBBAttackBar[$i][3] & "] : " &  $aBBAttackBar[$i][0], $COLOR_ACTION)
	Next
	
	Local $aTmpAttackBar = $aBBAttackBar
	
	Local $sTroopName = "", $sChangeTo = "", $iSlot = 0, $x = 0
	For $i = 0 To UBound($aTmpAttackBar) - 1
		$iSlot = $aBBAttackBar[$i][3]
		$x = $aBBAttackBar[$i][1]
		$sTroopName = $aTmpAttackBar[$i][0]
		$sChangeTo = $g_asAttackBarBB2[$g_iCmbTroopBB[$iSlot]]
		If $sTroopName = $sChangeTo Then 
			SetLog("Slot[" & $iSlot & "] Troop: " & $sTroopName & " is Correct", $COLOR_INFO)
			ContinueLoop
		Else
			SetLog("Slot[" & $iSlot & "] Troop: " & $sTroopName & ", Change to " & $sChangeTo, $COLOR_ACTION)
			If ChangeBBTroopTo($sTroopName, $x, $sChangeTo) Then 
				$aBBAttackBar[$i][0] = $sChangeTo
				ContinueLoop
			Else
				SetLog("Slot[" & $iSlot & "] Fail to Change Troop", $COLOR_ERROR)
				ContinueLoop
			EndIf
		EndIf
	Next
EndFunc

Func ChangeBBTroopTo($sTroopName, $x, $sChangeTo)
	Local $bRet = False
	
	Local $TmpX = 0, $TmpY = 0
	If QuickMIS("BC1", $g_sImgChangeTroops, $x, 635, $x + 70, 665) Then
		Click($g_iQuickMISX + 2, $g_iQuickMISY)
		$TmpX = $g_iQuickMISX
		$TmpY = $g_iQuickMISY
		If _Sleep(1500) Then Return
		If QuickMIS("BFI", $g_sImgDirBBTroops & $sChangeTo & "*", 0, 470, 860, 540) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(1000) Then Return
			$bRet = True
		Else
			SetLog("Troop " & $sChangeTo & " not found", $COLOR_ERROR)
			If $g_bChkDebugAttackBB Then SaveDebugImage("ChangeBBTroopTo", False)
			Click($TmpX, $TmpY)
			If _Sleep(1000) Then Return
		EndIf
	Else
		SetLog("Switch Button not found", $COLOR_ERROR)
		If $g_bChkDebugAttackBB Then SaveDebugImage("ChangeBBTroopTo", False)
	EndIf
	Return $bRet
EndFunc
#endRegion - xbebenk