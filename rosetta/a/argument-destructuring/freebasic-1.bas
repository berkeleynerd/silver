Type NamedArg  ' to simulate **kwargs
    nkey As String
    nval As String
End Type

Sub F(x As String, y As String, z As String, w As String)
    Print "This function's arguments are:"
    Print x
    Print y
    Print z
    Print w
End Sub

Sub ApplyMixed(positional() As String, named() As NamedArg)
    Dim x As String, y As String, z As String, w As String
    
    x = positional(0)
    y = positional(1)
    
    For i As Integer = Lbound(named) To Ubound(named)
        Select Case named(i).nkey
        Case "z"
            z = named(i).nval
        Case "w"
            w = named(i).nval
        End Select
    Next
    
    F(x, y, z, w)
End Sub

' Main program
Dim posic(0 To 1) As String = { "x - positional", "y - positional" }  ' to simulate *args

Dim named(0 To 1) As NamedArg
named(0).nkey = "w": named(0).nval = "w - named"
named(1).nkey = "z": named(1).nval = "z - named"

ApplyMixed(posic(), named())

Sleep
