STEP ONE (For PP_PREV only)

VBA Macro to delete unneccesary Indicator extract tabs:

Sub DeleteSheets1()
    Dim xWs As Worksheet
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    For Each xWs In Application.ActiveWorkbook.Worksheets
        If xWs.Name <> "HE-140-PEPFAR" And xWs.Name <> "HE-140-PEPFAR (FY2017)" And xWs.Name <> "HE_HIV_140" Then
            xWs.Delete
        End If
    Next
    Application.DisplayAlerts = True
    Application.ScreenUpdating = True
End Sub
