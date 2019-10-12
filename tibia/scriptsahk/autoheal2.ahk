#SingleInstance, Force
CoordMode,Mouse Pixel,Screen
SetKeyDelay,0
x40 := 1830
x75 := 1855
HealthY := 317
Loop,
{

   If WinActive("Tibia - Afterlife")

   {

      PixelGetColor, Check75, %x75%, %HealthY%
      PixelGetColor, Check40, %x40%, %HealthY%

      If (Check75 != 0x6161F1 And Check40 != 0x6161F1)
         Send, {F2}

      Else If (Check75 != 0x6161F1)
         Send, {F1}

   }
   Sleep, 100
}
Return