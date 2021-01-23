; Disables Google Drive context menu but ONLY if you're not currently pressing shift while in explorer.
; This virtually makes it an "extended" menu item, therefore you will not have a slow context menu
; unless you intend to actually access Google Drive (or other items in the extended menu) and overall
; increases efficiency.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IMPORTANT! For this to work, be sure to set permissions on the two registry keys below to ensure that this ;;
;; can modify those keys without having to launch as administrator (like if you start this when logging in).  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#NoEnv
#SingleInstance force

if(!A_IsAdmin)
{	
	MsgBox, 52, , Script is running without admin rights! It may not be able to edit registry keys. Would you like to restart this script as admin?
	IfMsgBox Yes 
	{
		Run *RunAs "%A_ScriptFullPath%" 
		ExitApp
	}
}
	
current := true

; Initialize ensuring Google Drive shell context are disabled.
setRegistry(false)

; Also clean up when exiting.
OnExit("exitFunc")

; Don't bother executing any hooks below at all unless actually in Explorer.
GroupAdd, vGroupDesktop, ahk_class Progman ;desktop
GroupAdd, vGroupDesktop, ahk_class WorkerW ;desktop
GroupAdd, vGroupDesktop, ahk_class CabinetWClass ;explorer


#If (WinActive("ahk_group vGroupDesktop") and WinActive("ahk_exe Explorer.EXE"))

; Register shift key hooks.
~Shift::
	setRegistry(true)
	KeyWait, Shift
	setRegistry(false)
return


setRegistry(enable) {
	if(current != enable){
		prefix := "-"
		if (enable) {
			prefix := ""
		}
		
		; The extra comma in parameter list is an empty value for the "(Default)" value for the key (as you'd see it in regedit).
		; See: https://autohotkey.com/docs/commands/RegWrite.htm
		
		; Directories
		RegWrite, REG_SZ, HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\GDContextMenu, , %prefix%{BB02B294-8425-42E5-983F-41A1FA970CD6}
		RegWrite, REG_SZ, HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\DriveFS 28 or later, , %prefix%{EE15C2BD-CECB-49F8-A113-CA1BFC528F5B}
		
		; Files
		RegWrite, REG_SZ, HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\GDContextMenu, , %prefix%{BB02B294-8425-42E5-983F-41A1FA970CD6}
		RegWrite, REG_SZ, HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\DriveFS 28 or later, , %prefix%{EE15C2BD-CECB-49F8-A113-CA1BFC528F5B}
		
		current := enable
	}
}
; Reverts back to enabling drive on exit.
exitFunc() {
	setRegistry(true)
	ExitApp
}