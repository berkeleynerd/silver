#include "windows.bi"
#include "win/wininet.bi"

Const API_URL = "https://rosettacode.org/mw/api.php"

Function DownloadString(url As String) As String
    Const BUFFER_SIZE As Integer = 8192
    Dim As HINTERNET hInternet, hConnect
    Dim As String resultado
    Dim As ZString * BUFFER_SIZE buffer
    Dim As DWORD bytesRead
        
    hInternet = InternetOpenUrl(InternetOpen("FreeBASIC",1,NULL,NULL,0), _
    Strptr(url), NULL, 0, INTERNET_FLAG_RELOAD Or INTERNET_FLAG_NO_CACHE_WRITE, 0)
    If hInternet = NULL Then Return ""
    
    Do
        If InternetReadFile(hInternet, @buffer, BUFFER_SIZE - 1, @bytesRead) = 0 Then Exit Do
        If bytesRead = 0 Then Exit Do
        resultado &= Left(*Cast(ZString Ptr, @buffer), bytesRead)
    Loop
    
    InternetCloseHandle(hInternet)
    
    Return resultado
End Function

Function ExtractBetween(resultado As String, a As String, b As String) As String
    Dim As Integer p = Instr(resultado, a)
    If p = 0 Then Return ""
    p += Len(a)
    Dim As Integer q = Instr(p, resultado, b)
    If q = 0 Then Return ""
    
    Return Mid(resultado, p, q - p)
End Function

Type Language
    nombre As String
    users As Integer
End Type

Dim As Language results(500)
Dim As Integer i, j, cnt = 0

Dim As String cont = ""
Do
    Dim As String url = API_URL & "?action=query&format=json&formatversion=2" _
    & "&generator=categorymembers&gcmtitle=Category:Language%20users" _
    & "&gcmlimit=500&prop=categoryinfo&rawcontinue=&" & cont
    
    Dim As String js = DownloadString(url)
    If js = "" Then Exit Do
    
    ' Parse JSON manually (simple substring extraction)
    Dim As Integer posic = 1
    Do
        Dim As String block = ExtractBetween(js, "{""pageid""", "}")
        If block = "" Then Exit Do
        
        Dim As String title = ExtractBetween(block, """title"":""", """")
        Dim As String usersStr = ExtractBetween(block, """size"":", ",")
        
        If title <> "" And usersStr <> "" Then
            If Instr(title, "Category:") = 1 And Instr(title, "users") > 0 Then
                results(cnt).nombre = Mid(title, 10, Len(title) - 14)
                results(cnt).users = Val(usersStr)
                cnt += 1
            End If
        End If
        
        posic = Instr(posic + 1, js, "{""pageid""")
        If posic = 0 Then Exit Do
    Loop
    
    Dim As String gcm = ExtractBetween(js, """gcmcontinue"":""", """")
    Dim As String c = ExtractBetween(js, """continue"":""", """")
    If gcm = "" Or c = "" Then Exit Do
    
    cont = "gcmcontinue=" & gcm & "&continue=" & c
Loop

' Sort results
For i = 0 To cnt - 2
    For j = i + 1 To cnt - 1
        If results(j).users > results(i).users Then
            Swap results(i), results(j)
        End If
    Next
Next

Print "Languages with at least 100 users as at " & Date & !":\n"
For i = 0 To cnt - 1
    If results(i).users >= 100 Then
        Print Using "###  \          \ ###"; i+1; results(i).nombre; results(i).users
    End If
Next

Sleep
