; Configuration
global const $kAttackSkillTimeout = 6
global const $kAttackTimeout = 20
global const $kMoveTimeout = 40
global const $kTimeouts = "1.5,20"
global const $kTimeoutHandlers = "OnBuffTimeout,CustomScript"
global const $kIsCancelTargetMove = true
global const $kDelayRate = 1
global const $kIsRestEnable = false
global const $kIsMacroSearch = false

; Skills
global const $kAttackSkill = "{F3}"
global const $kStunSkill = "{F2}"
global const $kSelfBuff = "{F7}"

func OnAttack()
	SendClient($kStunSkill, 1000)
endfunc

func OnAttackSkill()
	SendClient($kAttackSkill, 1000)
endfunc

func OnFirstKill()
	SendClient($kCancelTarget, 50)
endfunc

func OnAllKill()
	PickDrop(4)
endfunc

func NextTarget()
	LogWrite("NextTarget()")
	SendClient($kNextTargetKey, 800)
endfunc

func OnAttackTimeout()
	SendClient($kCancelTarget, 50)
	ChangePosition()
endfunc

func OnBuffTimeout()
	SendClient($kSelfBuff, 1000)
endfunc

func OnCheckHealthAndMana()
	if IsHealthLess($kBarHalf) then
		HealthPotion()
	endif
	
	if IsManaLess($kBarThird) then
		ManaPotion()
	endif
endfunc

#include "../tactics/solo.au3"
