version:=2.0

#SingleInstance, force
coordmode, mouse, screen
SetWorkingDir %A_ScriptDir%

help=
(
Win + F12 = Hide Show Gui
Win + F11 = Play the macro
Win + Space = insert a left click.
Win + X = insert a right click.
2 clicks at the same position  =  double-click
Win + W = insert current window title as comment
Win + Esc = exit the script

Add a line that begin with " : " to  insert a keyboard command

:U3 T2 {PgDn} S2.5        = Send, {Up 3}{Tab 2}{PgDn}(Sleep, 2500)
:S2.5 "Hello World"  = (Sleep, 2500)  SendRaw, Hello World
)

Gui 1: +Resize +AlwaysOnTop 
Gui 1: -dpiscale
Gui 1: font, s10
Gui 1: Add, Text,, % help
gui 1: font
Gui 1: Add, Text,, Delay between clicks in ms
Gui 1: Add, Edit, veditdelay disabled
Gui 1: Add, UpDown, vDelayTimer Range100-100000, 500
Gui 1: +Resize 

Gui 1: Add, CheckBox, x+30 yp+2 hp-25 -border gtoggleLoopPlay vLoopPlay, Repeat
Gui 1: Add, Edit,  x+1 yp-3 w80 +Number ved_rep Disabled c5D69BA,

Gui 1: Add, UpDown, vrepeat x34  Range1-999999, 2
Gui 1: Add, tab3, x10 section vmytab, Macro|Debugger|Command Letters
gui 1: font, s12
Gui 1: Add, Edit, y+30 w350 h300 -ReadOnly vmyedit -Wrap HScroll WantTab hwndHandle
Gui 1: font
Gui 1: Add, Button, Default vbtplay yp-27, PLAY
Gui 1: Add, Button, x+10, CLEAR
Gui 1: Add, Button, x+25, LOAD
Gui 1: Add, Button, x+10, SAVE
gui 1:tab, Debugger
Gui 1: Add, Edit, y+30 w350 h300  vmyedit2 -Wrap HScroll WantTab
Gui 1: Add, Button, xm+20 yp-27 gtranscribetoahk, Transcribe to AHK syntax
gui 1:tab, Command Letters
Gui 1: Add, Edit, w350 h320 ReadOnly vmyedit3 -Wrap HScroll WantTab
gosub, commandlist
guicontrol,, myedit3, % list
Gui 1: show, w400 h645, %  "Macro Commander v" . version
toggle:=1, clickscount:=0
guicontrol, enable, editdelay

; Hide Show Gui
#F12:: 

loopplay:=0
guicontrol,, loopplay, 0
GuiControl,disable,ed_rep

toggle:=!toggle
        if toggle {
        Gui 1: Show, w400 h645, % "Macro Commander v" . version
        GuiControl, Focus, MyEdit
        SendMessage, 0xB1, -2, -1,, ahk_id %Handle%
        SendMessage, 0xB7,,,, ahk_id %Handle%
        }
        else
        gui 1: hide
return

GuiSize:
	If (A_EventInfo = 1) ; The window has been minimized.
		Return
	AutoXYWH("wh", "mytab")
	AutoXYWH("wh", "myedit", "myedit2" ,"myedit3")
return



; Play Macro
#F11::
        gosub, buttonplay
return

; Insert Left Click
#space::
        Gui 1: Submit, NoHide
        MouseGetPos, xpos, ypos, 
        tooltip, % ++clickscount ": " xpos " " ypos
        myedit .= "`n" . "mouseclick, left, " xpos  " ," ypos 
        guicontrol,, myedit, % myedit
        SendMessage, 0xB1, -2, -1,, ahk_id %Handle%
        SendMessage, 0xB7,,,, ahk_id %Handle%
        sleep, 300
        tooltip,
return

; Insert Right Click
#x::
        Gui 1: Submit, NoHide
        MouseGetPos, xpos, ypos, 
        tooltip, % ++clickscount ": " xpos " " ypos
        myedit .= "`n" . "mouseclick, right, " xpos  " ," ypos 
        guicontrol,, myedit, % myedit
        SendMessage, 0xB1, -2, -1,, ahk_id %Handle%
        SendMessage, 0xB7,,,, ahk_id %Handle%  
        sleep, 300
        tooltip,
return

; Insert Window Title as comment
#w::
        Gui 1: Submit, NoHide
        WinGetTitle, Title, A        
        myedit .="`n; " . Title
        guicontrol,, myedit, % myedit
        SendMessage, 0xB1, -2, -1,, ahk_id %Handle%
        SendMessage, 0xB7,,,, ahk_id %Handle%          
        tooltip, % Title
        sleep, 300
        tooltip,        
return

toggleLoopPlay:

if (LoopPlay:=!LoopPlay)
 {
  guicontrol,, loopplay, 1
  GuiControl,enable,ed_rep
 }
else
 {
  guicontrol,, loopplay, 0
  GuiControl,enable0,ed_rep
 }
return


ButtonPLAY:
Gui 1: Submit
clickscount:=0

GuiControlGet,ed_rep,,repeat


runmacro:


if !ed_rep
ed_rep:=1

if !LoopPlay
ed_rep:=1

Loop % ed_rep
{
loop, parse, myedit, `n 
{
        if regexmatch(a_loopfield, "mouseclick,.*(l|r)\D+(\d+)\D+(\d+)",match) {
                MouseMove, match2, match3
                tooltip, % ++clickscount                
                if !(pmatch2==match2) && !(pmatch3==match3)
                Sleep, % DelayTimer
                mouseclick, % (match1="r") ? "right" : "left"
        }
        pmatch2:=match2, pmatch3:=match3

        if regexmatch(a_loopfield, "^:") {
                sendstring:=0, toggleshift:=0
                for k, v in strsplit(a_loopfield) {
                        if (v="""")
                        sendstring := !sendstring
        
                        if !(sendstring)  {      
                                if (v="s") {
                                match_s:=""
                                regexmatch(substr(a_loopfield, k), "i)(^s)(?! *)?([0-9]*\.[0-9]+|[0-9]+)",match_s)
                                        if (match_s) {
                                                match_s:=substr(match_s, 2)
                                                tooltip, % "Sleep " match_s " sec"
                                                sleep, % round((1000 * match_s))
                                        }
                                        else {
                                                tooltip, % "Sleep 1 sec"
                                                sleep, 1000
                                        }
                                        tooltip,
                                }

                                if (v="f") && !(sendkey) {
                                match_f:=""
                                regexmatch(substr(a_loopfield, k), "i)(^f)(?! *)?([0-9]+)",match_f)
                                        if (match_f) {
                                                match_f:=substr(match_f, 2)
                                                SendInput, {F%match_f%}
                                        }
                                        else {
                                                Send, ^f
                                        }
                                }

								else if (v="{") {
										sendkey:=1, match_k:=""
										regexmatch(substr(a_loopfield, k), "^{.*?}",match_k)
										SendInput, % match_k
									}
								else if (v="}") && (sendkey)
										sendkey:=0

                                else if (v="u") && !(sendkey)
                                        sk("u", "UP")    
                                else if (v="d") && !(sendkey)
                                        sk("d", "Down")
                                else if (v="l") && !(sendkey)
                                        sk("l", "Left")  
                                else if (v="r") && !(sendkey)
                                        sk("r", "Right")   
                                else if (v="e") && !(sendkey)
                                        sk("e", "Enter") 
                                else if (v="t") && !(sendkey)
                                        sk("t", "Tab") 
                                else if (v="k") && !(sendkey)
                                        sk("k", "Appskey")										
                                else if (v="h") && !(sendkey)
                                        sk("h", "Home")   
                                else if (v="n") && !(sendkey)
                                        sk("n", "End")
                                else if (v="b") && !(sendkey)
                                        sk("b", "BackSpace") 
                                else if (v="c") && !(sendkey)
                                Send, ^c 
                                else if (v="v") && !(sendkey)
                                Send, ^v   
                                else if (v="x") && !(sendkey)
                                Send, ^x  
                                else if (v="a") && !(sendkey)
                                Send, ^a
                                else if (v="q") && !(sendkey)
                                Send, !{f4}  
                                else if (v="w") && !(sendkey)
                                Clipwait  								
                                
                                else if (v="+") {
                                        toggleshift:=!toggleshift 
                                        if (toggleshift)
                                                send, {Shift down}
                                        else
                                                send, {Shift up} 
                                } 
                                else if (v="^") {
                                        toggleControl:=!toggleControl 
                                        if (toggleControl)
                                                send, {Ctrl down}
                                        else
                                                send, {Ctrl up} 
                                } 
                                else if (v="!") {
                                        toggleAlt:=!toggleAlt 
                                        if (toggleAlt)
                                                send, {Alt down}
                                        else
                                                send, {Alt up} 
                                }  
                                else if (v="#") {
                                        toggleWin:=!toggleWin 
                                        if (toggleWin)
                                                send, {LWin down}
                                        else
                                                send, {LWin up} 
                                }                                 

                        }

                        if (sendstring) {
                                if !(v="""")
                                tosend .= v
                        }     

                        if !(sendstring) && (tosend!="") {
                                sendraw, % tosend
                                tosend:=""
                        }
                } ; end of for loop (to parse a command line)
        }  ; end of if command ":"


        ; Ensure that all toggle keys are released
        if (toggleShift) {
                send, {Shift up}        
                toggleShift:=0
        }        
        if (toggleControl) {
                send, {Ctrl up}        
                toggleControl:=0
        }
        if (toggleAlt) {
                send, {Alt up}        
                toggleAlt:=0
        }
        if (toggleWin) {
                send, {Lwin up}        
                toggleWin:=0
        } 
        
        
} ;end of parse lines loop


clickscount:=0

tooltip, % "done :  " a_index "/" ed_rep
sleep, 400
tooltip,

if !loopplay
    break  

} ; end of repeat the macro


guiclose:
toggle:=""
gui 1: hide
return

return

TranscribetoAHK:
text_out:=""
guicontrolget, text_in,,myedit
loop, parse, text_in, `n 
{
        if !(regexmatch(a_loopfield, "^:"))
        text_out .= "`n" . A_LoopField
        if regexmatch(a_loopfield, "^:") {
                sendstringdebug:=0
                for k, v in strsplit(a_loopfield) {
                        if (v="""")
                        sendstringdebug := !sendstringdebug
                        if !(sendstringdebug) {      
                                if (v="s") {
                                match_s_debug:=""
                                regexmatch(substr(a_loopfield, k), "i)(^s)(?! *)?([0-9]*\.[0-9]+|[0-9]+)",match_s_debug)
                                        if (match_s_debug) {
                                                match_s_debug:=substr(match_s_debug, 2)
                                                text_out .= "`nsleep, "  round((1000 * match_s_debug))
                                        }
                                        else 
                                                text_out .= "`nsleep, 1000"
                                }

                                if (v="f") && !(sendkey_debug) {
                                match_f_debug:=""
                                regexmatch(substr(a_loopfield, k), "i)(^f)(?! *)?([0-9]+)",match_f_debug)
                                        if (match_f_debug) {
                                                match_f_debug:=substr(match_f_debug, 2)
												text_out .= "`nSendInput, {F" match_f_debug "}"
                                        }
                                        else {
                                                text_out .= "`nSend, ^f"
                                        }
                                }

								else if (v="{") {
										sendkey_debug:=1, match_k_debug:=""
										regexmatch(substr(a_loopfield, k), "^{.*?}",match_k_debug)
										text_out .= "`nSendInput, " . match_k_debug
									}
								else if (v="}") && (sendkey_debug)
										sendkey_debug:=0

                                else if (v="u") && !(sendkey_debug)
                                        sk_debug("u","Up")
                                else if (v="d") && !(sendkey_debug)
                                        sk_debug("d","Down")
                                else if (v="l") && !(sendkey_debug)
                                        sk_debug("l","Left")
                                else if (v="r") && !(sendkey_debug)
                                        sk_debug("r","Right")    
                                else if (v="e") && !(sendkey_debug)
                                        sk_debug("e","Enter")  
                                else if (v="t") && !(sendkey_debug)
                                        sk_debug("t","Tab")
                                else if (v="k") && !(sendkey_debug)
                                        sk_debug("k","Appskey")										
                                else if (v="h") && !(sendkey_debug)
                                        sk_debug("h","Home")  
                                else if (v="n") && !(sendkey_debug)
                                        sk_debug("n","End") 
                                else if (v="b") && !(sendkey_debug)
                                        sk_debug("b","BackSpace")  
                                else if (v="c") && !(sendkey_debug)
                                text_out .= "`nSend, ^c" 
                                else if (v="v") && !(sendkey_debug)
                                text_out .= "`nSend, ^v"   
                                else if (v="x") && !(sendkey_debug)
                                text_out .= "`nSend, ^x"  
                                else if (v="a") && !(sendkey_debug)
                                text_out .= "`nSend, ^a"
                                else if (v="q") && !(sendkey_debug)
                                text_out .= "`nSend, !{f4}"  
                                else if (v="w") && !(sendkey_debug)
                                text_out .= "`nClipWait"								
                                
                                else if (v="+") && !(sendkey_debug) {
                                        toggleshiftdebug:=!toggleshiftdebug
                                        if (toggleshiftdebug)
                                                text_out .= "`nSend, {Shift down}"
                                        else
                                                text_out .= "`nSend, {Shift up}" 
                                } 
                                else if (v="^") {
                                        toggleControldebug:=!toggleControldebug
                                        if (toggleControldebug)
                                                text_out .= "`nSend, {Ctrl down}"
                                        else
                                                text_out .= "`nSend, {Ctrl up}" 
                                }
                                else if (v="!") {
                                        toggleAltdebug:=!toggleAltdebug
                                        if (toggleAltdebug)
                                                text_out .= "`nSend, {Alt down}"
                                        else
                                                text_out .= "`nSend, {Alt up}" 
                                }
                                else if (v="#") {
                                        toggleWindebug:=!toggleWinDebug 
                                        if (toggleWinDebug)
                                                text_out .= "`nSend, {LWin down}"
                                        else
                                                text_out .= "`nSend, {LWin up}"
                                }                                
              
                        }
                        
                        if (sendstringdebug) {
                                if !(v="""")
                                tosenddebug .= v
                        }     

                        if !(sendstringdebug) && (tosenddebug!="") {
                                text_out .= "`nSendRaw, "  tosenddebug
                                tosenddebug:=""
                        }                        
                }
        }


        ; Ensure that all toggle keys are released

        if (toggleshiftdebug) {
                text_out .= "`nsend, {Shift up} `; Don't forget to put a second   +  to release the key "        
                toggleshiftdebug:=0
        } 
        if (toggleControldebug) {
                text_out .= "`nsend, {Ctrl up} `; Don't forget to put a second   ^   to release the key "        
                toggleControldebug:=0
        }
        if (toggleAltdebug) {
                text_out .= "`nsend, {Alt up} `; Don't forget to put a second   !   to release the key "        
                toggleAltdebug:=0
        }
        if (toggleWindebug) {
                text_out .= "`nsend, {Lwin up} `; Don't forget to put a second   #   to release the key "        
                toggleWindebug:=0
        } 

}        



guicontrol,, myedit2, %   text_out  

return
;--------------------------------------------------------------------------------------------------------

sk(key,KeyName) {
global
match_num:=""
regexmatch(substr(a_loopfield, k), "i)(^" key ")(?! *)?([0-9]+)",match_num)
        if (match_num) {
                match_num:=substr(match_num, 2)
                SendInput, {%KeyName% %match_num%}
        }
        else {
                SendInput, {%KeyName%}
        } 
} 

sk_debug(key,KeyName) {
global
match_num_deb:=""
regexmatch(substr(a_loopfield, k), "i)(^" key ")(?! *)?([0-9]+)",match_num_deb)
        if (match_num_deb) {
                match_num_deb:=substr(match_num_deb, 2)
                text_out .= "`nSendInput, {" KeyName "  " match_num_deb "}"
        }
        else {
                text_out .= "`nSendInput, {" KeyName "}"
        } 
} 

;---------------------------------------------------------------------------------------------------------


ButtonCLEAR:
clickscount:=0
myedit:=""
guicontrol,, myedit, % ""
return

ButtonLOAD:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectFile, SelectedFileName, 3,, Open File, Text Documents (*.txt)
if SelectedFileName =  ; No file selected.
    return
Gosub FileRead
return

FileRead:  ; Caller has set the variable SelectedFileName for us.
FileRead, MyEdit, %SelectedFileName%  ; Read the file's contents into the variable.
if ErrorLevel
{
    MsgBox Could not open "%SelectedFileName%".
    return
}
GuiControl,, MyEdit, %MyEdit%  ; Put the text into the control.
return


ButtonSAVE:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectFile, SelectedFileName, S16, %A_WorkingDir% , Save File, Text Documents (*.txt)
if SelectedFileName =  ; No file selected.
    return
CurrentFileName = %SelectedFileName%
Gosub SaveCurrentFile
return

SaveCurrentFile:  ; Caller has ensured that CurrentFileName is not blank.
IfExist %CurrentFileName%
{
    FileDelete %CurrentFileName%
    if ErrorLevel
    {
        MsgBox The attempt to overwrite "%CurrentFileName%" failed.
        return
    }
}
GuiControlGet, myedit  ; Retrieve the contents of the Edit control.
if ! instr(currentfilename, ".",,2)
FileAppend, %myedit%, %CurrentFileName%.txt  ; Save the contents to the file.
else
FileAppend, %myedit%, %CurrentFileName% ; Save the contents to the file.
return

commandlist:
list=
(
Add a line that begin with " : " to  insert a command in the Macro
Each letter represents a key command.
The standard AHK notation for keys is also supported. 
for ex. :{PgDn} u2 {Enter} = SendInput, {PgDn}{Up 2}{Enter}

S   =  Sleep, 1000
Sn =  Where n is a number or floating number  
         S3.2 = Sleep, 3200   S4 = Sleep, 4000 etc...
B  =  {BackSpace}
Bn =  n represents the number of times the key is pressed
      B3 = SendInput, {Backspace 3) ; n is also compatible with commands E D H N T U D L R 
E  =  {Enter}
H  =  {Home}
N  =  {End}
T  =  {Tab}
K  =  {Appskey}
A  =  ^a  ; select all
X  =  ^x  ; cut
C  =  ^c  ; copy
V  =  ^v  ; paste
F  =  ^f  ; find
Q  =  {Alt}{F4}  ; Close
W  =  ClipWait
F1 to F24 = {F1} - {F24} ; function keys

U D L R =  {Up} {Down} {Left} {Right}

"   = Toggle send as string  (SendRaw)
    for example
    :"Hello" + H + = Send, Hello {Shift Down}{Home}{Shift Up}

+  = {Shift Down/Up}  Toogle shift key  
     Don't forget to put a second + to release the key !!!
     for example
     :+ N + = Send, {Shift Down}{End}{Shift up}
     :++  = Send, {Shift Down}{Shift up}     (normal shift event)

^  = {Ctrl Down/Up}  Toogle Ctrl key  
     Don't forget to put a second ^ to release the key !!!
     for example
     :^ "o" ^ = Send, {Ctrl Down} o {Ctrl up}

!  = {Alt Down/Up}  Toogle Alt key  
     Don't forget to put a second ! to release the key !!!
     for example
     :! "fs" ! = Send, {Alt Down} fs {Alt up}
     
#  = {Win Down/Up}  Toogle Win key  
     Don't forget to put a second # to release the key !!!
     for example to open explorer
     : # "e" # = Send, {Win Down} e {Win up}     
    
    
)
return


getcontrol(crtname, what)
{
 guicontrolget, out,  Pos, %crtname%

 if (what="x")
 return % outx

 if (what="y")
 return % outy

 if (what="w")
 return % outW

 if (what="h")
 return % outH

 if (what="yh")
 return % outy + outH 

 if (what="xw")
 return % outx + outW
}





~#esc::
send, {shift up}
tooltip,
exitapp 
return

; =================================================================================
; Function: AutoXYWH
;   Move and resize control automatically when GUI resizes.
; Parameters:
;   DimSize - Can be one or more of x/y/w/h  optional followed by a fraction
;             add a '*' to DimSize to 'MoveDraw' the controls rather then just 'Move', this is recommended for Groupboxes
;   cList   - variadic list of ControlIDs
;             ControlID can be a control HWND, associated variable name, ClassNN or displayed text.
;             The later (displayed text) is possible but not recommend since not very reliable 
; Examples:
;   AutoXYWH("xy", "Btn1", "Btn2")
;   AutoXYWH("w0.5 h 0.75", hEdit, "displayed text", "vLabel", "Button1")
;   AutoXYWH("*w0.5 h 0.75", hGroupbox1, "GrbChoices")
; ---------------------------------------------------------------------------------
; Version: 2015-5-29 / Added 'reset' option (by tmplinshi)
;          2014-7-03 / toralf
;          2014-1-2  / tmplinshi
; requires AHK version : 1.1.13.01+
; =================================================================================
AutoXYWH(DimSize, cList*){       ; http://ahkscript.org/boards/viewtopic.php?t=1079
  static cInfo := {}
 
  If (DimSize = "reset")
    Return cInfo := {}
 
  For i, ctrl in cList {
    ctrlID := A_Gui ":" ctrl
    If ( cInfo[ctrlID].x = "" ){
        GuiControlGet, i, %A_Gui%:Pos, %ctrl%
        MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
        fx := fy := fw := fh := 0
        For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]")))
            If !RegExMatch(DimSize, "i)" dim "\s*\K[\d.-]+", f%dim%)
              f%dim% := 1
        cInfo[ctrlID] := { x:ix, fx:fx, y:iy, fy:fy, w:iw, fw:fw, h:ih, fh:fh, gw:A_GuiWidth, gh:A_GuiHeight, a:a , m:MMD}
    }Else If ( cInfo[ctrlID].a.1) {
        dgx := dgw := A_GuiWidth  - cInfo[ctrlID].gw  , dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
        For i, dim in cInfo[ctrlID]["a"]
            Options .= dim (dg%dim% * cInfo[ctrlID]["f" dim] + cInfo[ctrlID][dim]) A_Space
        GuiControl, % A_Gui ":" cInfo[ctrlID].m , % ctrl, % Options
} } }
