#SingleInstance, Force
CoordMode,Mouse Pixel,Screen
SetKeyDelay,0
x75 := 1767
HealthY := 243
Loop,
{

   If WinActive("Tibia")

   {
        Sleep, 1984
Send, {LControl Down}
Sleep, 266
Send, {Right}
Sleep, 313
Send, {Up}
Sleep, 406
Send, {Left}
Sleep, 469
Send, {Down}
Sleep, 406
Send, {Right}
Sleep, 500
Send, {LControl Up}
Sleep, 812
Send,{F4}
Sleep, 1000
Send,{F4}
Sleep, 1000
Send,{F4}
Sleep, 1000
Send,{F4}
Sleep, 1000
Send,{F4}
Sleep, 1000
   }
   Sleep, 780000
}
Return