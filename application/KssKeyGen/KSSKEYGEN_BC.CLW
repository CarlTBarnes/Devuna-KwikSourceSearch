  MEMBER('KssKeyGen.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('KssKeyGen_BC0.CLW')
KssKeyGen_BC0:DctInit             PROCEDURE()
KssKeyGen_BC0:DctKill             PROCEDURE()
KssKeyGen_BC0:FilesInit           PROCEDURE()
    END
  END

DctInit PROCEDURE()
  CODE
  KssKeyGen_BC0:DctInit
  KssKeyGen_BC0:FilesInit


DctKill PROCEDURE()
  CODE
  KssKeyGen_BC0:DctKill

