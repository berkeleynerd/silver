#macro Primero(array, Operator)
    For index As Integer = Lbound(array) To Ubound(array) - 1
        Print " " Operator array(index) Operator ",";
    Next index
    Print " " Operator array(Ubound(array))
#endmacro

#macro Segundo(nombre, array)
    Print nombre & ":"
    Primero(array, &)
#endmacro

Dim As String test1(2) => {"First", "Second", "Third"}
Dim As Integer test2(2) => {1, 2 ,3}

Print "test1:"
Primero(test1, &)
Print
Segundo("test2", test2)

Sleep
