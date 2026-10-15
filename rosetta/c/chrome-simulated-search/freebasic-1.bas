#include once "windows.bi"

Const KEY_DELAY As Integer = 15
Const CONTROL_DELAY As Integer = 25
Const BROWSER_WAIT As Integer = 5000

Sub KeyDown(Byval vk As Ubyte)
    keybd_event(vk, 0, 0, 0)
End Sub

Sub KeyUp(Byval vk As Ubyte)
    keybd_event(vk, 0, KEYEVENTF_KEYUP, 0)
End Sub

Sub PressKey(Byval vk As Ubyte)
    KeyDown(vk)
    Sleep(KEY_DELAY)
    KeyUp(vk)
End Sub

Sub PressCtrlKey(Byval vk As Ubyte)
    KeyDown(VK_CONTROL)
    Sleep(CONTROL_DELAY)
    
    PressKey(vk, CONTROL_DELAY)
    Sleep(CONTROL_DELAY)
    
    KeyUp(VK_CONTROL)
End Sub

Sub TypeText(Byref text As String)   
    For i As Integer = 1 To Len(text)
        Dim character As Ubyte = Asc(text, i)
        Dim translated As Short = VkKeyScan(character)
        
        If translated = -1 Then
            Print "Character not supported in position "; i
            Continue For
        End If
        
        Dim vk As Ubyte = translated And &HFF
        Dim modifiers As Ubyte = (translated Shr 8) And &HFF
        
        If (modifiers And MOD_SHIFT)   <> 0 Then KeyDown(VK_SHIFT)
        If (modifiers And MOD_CONTROL) <> 0 Then KeyDown(VK_CONTROL)
        If (modifiers And MOD_ALT)     <> 0 Then KeyDown(VK_MENU)
        
        PressKey(vk, KEY_DELAY)
        
        If (modifiers And MOD_ALT)     <> 0 Then KeyUp(VK_MENU)
        If (modifiers And MOD_CONTROL) <> 0 Then KeyUp(VK_CONTROL)
        If (modifiers And MOD_SHIFT)   <> 0 Then KeyUp(VK_SHIFT)
        
        Sleep(KEY_DELAY)
    Next
End Sub

Print "Activate a browser: Chrome, Edge, Opera, Firefox, ..."
Print "Sending will begin in five seconds..."

Sleep(BROWSER_WAIT)

Dim hwnd As HWND = GetForegroundWindow()
If hwnd = 0 Then
    Print "There is no active window."
    Sleep: End
End If

Dim className As ZString * 256
GetClassName(hwnd, className, 256)

If className <> "Chrome_WidgetWin_1" And className <> "MozillaWindowClass" Then
    Print "The active window is not a supported browser."
    Sleep: End
End If

' Open a new tab
PressCtrlKey(VK_T)
Sleep(500)

' Enter the search
TypeText("todays weather")
Sleep(300)

' Run the search
PressKey(VK_RETURN)
Sleep(5000)
