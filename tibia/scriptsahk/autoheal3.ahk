#SingleInstance, Force
CoordMode,Mouse Pixel,Screen
SetKeyDelay,0
x75 := 1700
HealthY := 89
Loop,
{

   If WinActive("Tibia")

   {

      PixelGetColor, Check75, %x75%, %HealthY%

      If (Check75 == 0x474747)
         Send, {F2}

   }
   Sleep, 350
}
Return