

   MEMBER('kss.clw')                                       ! This is a MEMBER module

!region Notices
! ================================================================================
! Notice : Copyright (C) 2017, Devuna
!          Distributed under the MIT License (https://opensource.org/licenses/MIT)
!
!    This file is part of Devuna-KwikSourceSearch (https://github.com/Devuna/Devuna-KwikSourceSearch)
!
!    Devuna-KwikSourceSearch is free software: you can redistribute it and/or modify
!    it under the terms of the MIT License as published by
!    the Open Source Initiative.
!
!    Devuna-KwikSourceSearch is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    MIT License for more details.
!
!    You should have received a copy of the MIT License
!    along with Devuna-KwikSourceSearch.  If not, see <https://opensource.org/licenses/MIT>.
! ================================================================================
!endregion Notices

   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

!!! <summary>
!!! Generated from procedure template - Window
!!! </summary>
ListBoxFormatter PROCEDURE (ListFormatQueueType pListFormatQueue)

!region Notices
! ================================================================================
! Notice : Copyright (C) 2017, Devuna
!          Distributed under the MIT License (https://opensource.org/licenses/MIT)
!
!    This file is part of Devuna-KwikSourceSearch (https://github.com/Devuna/Devuna-KwikSourceSearch)
!
!    Devuna-KwikSourceSearch is free software: you can redistribute it and/or modify
!    it under the terms of the MIT License as published by
!    the Open Source Initiative.
!
!    Devuna-KwikSourceSearch is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    MIT License for more details.
!
!    You should have received a copy of the MIT License
!    along with Devuna-KwikSourceSearch.  If not, see <https://opensource.org/licenses/MIT>.
! ================================================================================
!endregion Notices
oHH           &tagHTMLHelp
szListBoxFormat      CSTRING(256)                          ! 
ListFormatQueue      QUEUE,PRE(lfq)                        ! 
ColumnSequence       BYTE                                  ! 
ColumnName           CSTRING(32)                           ! 
ColumnFormat         CSTRING(64)                           ! 
                     END                                   ! 
Window               WINDOW('Results List Formatter'),AT(,,151,100),FONT('Segoe UI',10),GRAY,HLP('ListboxFor' & |
  'matter.htm')
                       BUTTON('&OK'),AT(51,81,45,14),USE(?OkButton),DEFAULT
                       BUTTON('&Cancel'),AT(101,81,45,14),USE(?CancelButton)
                       LIST,AT(5,5,141,72),USE(?ColumnList),FORMAT('124L(2)|M~Column Name~@s31@#2#'),FROM(ListFormatQueue)
                       BUTTON,AT(5,81,18,14),USE(?cmdMoveUp),ICON('ABUPROW.ICO')
                       BUTTON,AT(28,81,18,14),USE(?cmdMoveDown),ICON('ABDNROW.ICO')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Reset                  PROCEDURE(BYTE Force=0),DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeNewSelection       PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass

  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop
  RETURN(szListBoxFormat)

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

i                    BYTE
  CODE
  GlobalErrors.SetProcedureName('ListBoxFormatter')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?OkButton
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  SELF.Open(Window)                                        ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?ColumnList{PROP:LineHeight} = 10
  Do DefineListboxStyle
  LOOP i = 1 TO RECORDS(pListFormatQueue)
     GET(pListFormatQueue,i)
     ListFormatQueue = pListFormatQueue
     ADD(ListFormatQueue)
  END
  GET(ListFormatQueue,1)
  ?ColumnList{PROP:Selected} = 1
  INIMgr.Fetch('ListBoxFormatter',Window)                  ! Restore window settings from non-volatile store
  CorrectForOffscreen(Window)
  SELF.SetAlerts()
  oHH &= NEW tagHTMLHelp
  oHH.Init( 'kss.chm' )
  oHH.SetTopic('ListboxFormatter.htm')
  SELF.Reset()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.Opened
    INIMgr.Update('ListBoxFormatter',Window)               ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  IF ~oHH &= NULL
    oHH.Kill()
    DISPOSE( oHH )
  END
  RETURN ReturnValue


ThisWindow.Reset PROCEDURE(BYTE Force=0)

  CODE
  SELF.ForcedReset += Force
  IF Window{Prop:AcceptAll} THEN RETURN.
  PARENT.Reset(Force)
  IF ?ColumnList{PROP:Selected} = 1
     DISABLE(?cmdMoveUp)
     ENABLE(?cmdMoveDown)
  ELSIF ?ColumnList{PROP:Selected} = RECORDS(ListFormatQueue)
     ENABLE(?cmdMoveUp)
     DISABLE(?cmdMoveDown)
  ELSE
     ENABLE(?cmdMoveUp)
     ENABLE(?cmdMoveDown)
  END


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

i      BYTE
Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?OkButton
      ThisWindow.Update()
      FREE(pListFormatQueue)
      szListBoxFormat = ''
      LOOP i = 1 TO RECORDS(ListFormatQueue)
         GET(ListFormatQueue,i)
         pListFormatQueue = ListFormatQueue
         ADD(pListFormatQueue)
         szListBoxFormat = szListBoxFormat & ListFormatQueue.ColumnFormat
      END
      POST(EVENT:CloseWindow)
    OF ?CancelButton
      ThisWindow.Update()
      szListBoxFormat = ''
      LOOP i = 1 TO RECORDS(pListFormatQueue)
         GET(pListFormatQueue,i)
         szListBoxFormat = szListBoxFormat & pListFormatQueue.ColumnFormat
      END
      POST(EVENT:CloseWindow)
    OF ?cmdMoveUp
      ThisWindow.Update()
      GET(ListFormatQueue,CHOICE(?ColumnList))
      i = POINTER(ListFormatQueue)
      ListFormatQueue.ColumnSequence -= 1
      PUT(ListFormatQueue)
      GET(ListFormatQueue,i-1)
      ListFormatQueue.ColumnSequence += 1
      PUT(ListFormatQueue)
      SORT(ListFormatQueue,ListFormatQueue.ColumnSequence)
      GET(ListFormatQueue,i-1)
      ?ColumnList{PROP:Selected} = POINTER(ListFormatQueue)
      SELF.Reset()
    OF ?cmdMoveDown
      ThisWindow.Update()
      GET(ListFormatQueue,CHOICE(?ColumnList))
      i = POINTER(ListFormatQueue)
      ListFormatQueue.ColumnSequence += 1
      PUT(ListFormatQueue)
      GET(ListFormatQueue,i+1)
      ListFormatQueue.ColumnSequence -= 1
      PUT(ListFormatQueue)
      SORT(ListFormatQueue,ListFormatQueue.ColumnSequence)
      GET(ListFormatQueue,i+1)
      ?ColumnList{PROP:Selected} = POINTER(ListFormatQueue)
      SELF.Reset()
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeNewSelection PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all NewSelection events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeNewSelection()
    CASE FIELD()
    OF ?ColumnList
       SELF.Reset()
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

