MODULE GETDATA_ICE_ADJUST_MOD

USE OMP_LIB

INTERFACE REPLICATE
  MODULE PROCEDURE REPLICATE3
  MODULE PROCEDURE REPLICATE4
END INTERFACE

INTERFACE NPROMIZE
  MODULE PROCEDURE NPROMIZE4
  MODULE PROCEDURE NPROMIZE5
END INTERFACE

INTERFACE INTERPOLATE
  MODULE PROCEDURE INTERPOLATE4
  MODULE PROCEDURE INTERPOLATE5
END INTERFACE

INTERFACE SET
  MODULE PROCEDURE SET3
  MODULE PROCEDURE SET4
  MODULE PROCEDURE SET5
END INTERFACE

CONTAINS

SUBROUTINE GETDATA_ICE_ADJUST (NPROMA, NGPBLKS, NFLEVG, PRHODJ_B, PEXNREF_B, PRHODREF_B, PPABSM_B, PTHT_B, ZICE_CLD_WGT_B, &
& ZSIGQSAT_B, PSIGS_B, PMFCONV_B, PRC_MF_B, PRI_MF_B, PCF_MF_B, ZDUM1_B, ZDUM2_B, ZDUM3_B, ZDUM4_B, ZDUM5_B, PTHS_B, PRS_B, PSRCS_B, PCLDFR_B, PHLC_HRC_B, PHLC_HCF_B,   &
& PHLI_HRI_B, PHLI_HCF_B, ZRS_B, ZZZ_B, PRS_OUT_B, PSRCS_OUT_B, PCLDFR_OUT_B, PHLC_HRC_OUT_B, PHLC_HCF_OUT_B,         &
& PHLI_HRI_OUT_B, PHLI_HCF_OUT_B, LDVERBOSE)

USE IEEE_ARITHMETIC, ONLY : IEEE_SIGNALING_NAN, IEEE_VALUE

IMPLICIT NONE

INTEGER, PARAMETER :: IFILE = 77

INTEGER      :: KLON 
INTEGER      :: KIDIA  
INTEGER      :: KFDIA  
INTEGER      :: KLEV  
INTEGER      :: KRR  
INTEGER      :: KDUM

LOGICAL :: LDVERBOSE

REAL, ALLOCATABLE   :: PRHODJ_B       (:,:,:,:)   
REAL, ALLOCATABLE   :: PEXNREF_B      (:,:,:,:)   
REAL, ALLOCATABLE   :: PRHODREF_B     (:,:,:,:)   
REAL, ALLOCATABLE   :: PPABSM_B       (:,:,:,:)   
REAL, ALLOCATABLE   :: PTHT_B         (:,:,:,:)   
REAL, ALLOCATABLE   :: ZICE_CLD_WGT_B (:,:,:)
REAL, ALLOCATABLE   :: ZSIGQSAT_B     (:,:,:)
REAL, ALLOCATABLE   :: PSIGS_B        (:,:,:,:)   
REAL, ALLOCATABLE   :: PMFCONV_B      (:,:,:,:)   
REAL, ALLOCATABLE   :: PRC_MF_B       (:,:,:,:)   
REAL, ALLOCATABLE   :: PRI_MF_B       (:,:,:,:)   
REAL, ALLOCATABLE   :: PCF_MF_B       (:,:,:,:)   
REAL, ALLOCATABLE   :: ZDUM1_B        (:,:,:,:)
REAL, ALLOCATABLE   :: ZDUM2_B        (:,:,:,:)
REAL, ALLOCATABLE   :: ZDUM3_B        (:,:,:,:)
REAL, ALLOCATABLE   :: ZDUM4_B        (:,:,:,:)
REAL, ALLOCATABLE   :: ZDUM5_B        (:,:,:,:)
REAL, ALLOCATABLE   :: PTHS_B         (:,:,:,:)   
REAL, ALLOCATABLE   :: PRS_B          (:,:,:,:,:) 
REAL, ALLOCATABLE   :: PRS_OUT_B      (:,:,:,:,:) 
REAL, ALLOCATABLE   :: PSRCS_B        (:,:,:,:)   
REAL, ALLOCATABLE   :: PSRCS_OUT_B    (:,:,:,:)   
REAL, ALLOCATABLE   :: PCLDFR_B       (:,:,:,:)   
REAL, ALLOCATABLE   :: PCLDFR_OUT_B   (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLC_HRC_B     (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLC_HRC_OUT_B (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLC_HCF_B     (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLC_HCF_OUT_B (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLI_HRI_B     (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLI_HRI_OUT_B (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLI_HCF_B     (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLI_HCF_OUT_B (:,:,:,:)   
REAL, ALLOCATABLE   :: ZRS_B          (:,:,:,:,:) 
REAL, ALLOCATABLE   :: ZZZ_B          (:,:,:,:)   

REAL, ALLOCATABLE   :: PRHODJ         (:,:,:,:)   
REAL, ALLOCATABLE   :: PEXNREF        (:,:,:,:)   
REAL, ALLOCATABLE   :: PRHODREF       (:,:,:,:)   
REAL, ALLOCATABLE   :: PPABSM         (:,:,:,:)   
REAL, ALLOCATABLE   :: PTHT           (:,:,:,:)   
REAL, ALLOCATABLE   :: PSIGS          (:,:,:,:)   
REAL, ALLOCATABLE   :: PMFCONV        (:,:,:,:)   
REAL, ALLOCATABLE   :: PRC_MF         (:,:,:,:)   
REAL, ALLOCATABLE   :: PRI_MF         (:,:,:,:)   
REAL, ALLOCATABLE   :: PCF_MF         (:,:,:,:)   
REAL, ALLOCATABLE   :: PTHS           (:,:,:,:)   
REAL, ALLOCATABLE   :: PRS            (:,:,:,:,:) 
REAL, ALLOCATABLE   :: PRS_OUT        (:,:,:,:,:) 
REAL, ALLOCATABLE   :: PSRCS_OUT      (:,:,:,:)   
REAL, ALLOCATABLE   :: PCLDFR_OUT     (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLC_HRC_OUT   (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLC_HCF_OUT   (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLI_HRI_OUT   (:,:,:,:)   
REAL, ALLOCATABLE   :: PHLI_HCF_OUT   (:,:,:,:)   
REAL, ALLOCATABLE   :: ZRS            (:,:,:,:,:) 
REAL, ALLOCATABLE   :: ZZZ            (:,:,:,:)   

INTEGER :: NGPTOT, NPROMA, NGPBLKS, NFLEVG
INTEGER :: IOFF, IBL
LOGICAL :: LLEXIST
CHARACTER(LEN=32) :: CLFILE
REAL :: ZNAN

KRR=6
NGPTOT = NPROMA * NGPBLKS

IBL = 1
WRITE (CLFILE, '("data/",I8.8,".dat")') IBL
OPEN (IFILE, FILE=TRIM (CLFILE), FORM='UNFORMATTED') 
READ (IFILE) KLON, KDUM, KLEV
CLOSE (IFILE)

IF (NFLEVG < 0) NFLEVG = KLEV

ALLOCATE (ZSIGQSAT_B      (NPROMA,1,NGPBLKS))
ALLOCATE (ZICE_CLD_WGT_B  (NPROMA,1,NGPBLKS))
ALLOCATE (PSRCS_B         (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PCLDFR_B        (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PHLC_HRC_B      (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PHLC_HCF_B      (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PHLI_HRI_B      (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PHLI_HCF_B      (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PRHODJ_B        (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PEXNREF_B       (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PRHODREF_B      (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PPABSM_B        (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PTHT_B          (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PSIGS_B         (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PMFCONV_B       (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PRC_MF_B        (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PRI_MF_B        (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PCF_MF_B        (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (ZDUM1_B         (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (ZDUM2_B         (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (ZDUM3_B         (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (ZDUM4_B         (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (ZDUM5_B         (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PTHS_B          (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PRS_B           (NPROMA,1,NFLEVG,KRR,NGPBLKS))
ALLOCATE (PRS_OUT_B       (NPROMA,1,NFLEVG,KRR,NGPBLKS))
ALLOCATE (PSRCS_OUT_B     (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PCLDFR_OUT_B    (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (ZRS_B           (NPROMA,1,NFLEVG,0:KRR,NGPBLKS))
ALLOCATE (ZZZ_B           (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PHLC_HRC_OUT_B  (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PHLC_HCF_OUT_B  (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PHLI_HRI_OUT_B  (NPROMA,1,NFLEVG,NGPBLKS))
ALLOCATE (PHLI_HCF_OUT_B  (NPROMA,1,NFLEVG,NGPBLKS))

ZNAN = IEEE_VALUE (ZNAN, IEEE_SIGNALING_NAN)


CALL SET (ZSIGQSAT_B    )
CALL SET (ZICE_CLD_WGT_B)
CALL SET (PSRCS_B       )
CALL SET (PCLDFR_B      )
CALL SET (PHLC_HRC_B    )
CALL SET (PHLC_HCF_B    )
CALL SET (PHLI_HRI_B    )
CALL SET (PHLI_HCF_B    )
CALL SET (PRHODJ_B      )
CALL SET (PEXNREF_B     )
CALL SET (PRHODREF_B    )
CALL SET (PPABSM_B      )
CALL SET (PTHT_B        )
CALL SET (PSIGS_B       )
CALL SET (PMFCONV_B     )
CALL SET (PRC_MF_B      )
CALL SET (PRI_MF_B      )
CALL SET (PCF_MF_B      )
CALL SET (PTHS_B        )
CALL SET (PRS_B         )
CALL SET (PRS_OUT_B     )
CALL SET (PSRCS_OUT_B   )
CALL SET (PCLDFR_OUT_B  )
CALL SET (ZRS_B         )
CALL SET (ZZZ_B         )
CALL SET (PHLC_HRC_OUT_B)
CALL SET (PHLC_HCF_OUT_B)
CALL SET (PHLI_HRI_OUT_B)
CALL SET (PHLI_HCF_OUT_B)



ZSIGQSAT_B     = 2.0000000000000000E-002
ZICE_CLD_WGT_B = 1.5
PSRCS_B        = ZNAN
PCLDFR_B       = ZNAN
PHLI_HCF_B     = ZNAN
PHLI_HRI_B     = ZNAN
PHLC_HCF_B     = ZNAN
PHLC_HRC_B     = ZNAN


IOFF = 0
IBL = 0
LLEXIST = .TRUE.

DO WHILE(LLEXIST)
  IBL = IBL + 1
  WRITE (CLFILE, '("data/",I8.8,".dat")') IBL

  INQUIRE (FILE=TRIM (CLFILE), EXIST=LLEXIST)

  IF (LDVERBOSE) PRINT *, TRIM (CLFILE)

  IF (.NOT. LLEXIST) EXIT

  OPEN (IFILE, FILE=TRIM (CLFILE), FORM='UNFORMATTED') 
  
  READ (IFILE) KLON, KDUM, KLEV

  IF (IBL == 1) THEN
    ALLOCATE (PRHODJ       (NGPTOT,1,KLEV,1))
    ALLOCATE (PEXNREF      (NGPTOT,1,KLEV,1))
    ALLOCATE (PRHODREF     (NGPTOT,1,KLEV,1))
    ALLOCATE (PPABSM       (NGPTOT,1,KLEV,1))
    ALLOCATE (PTHT         (NGPTOT,1,KLEV,1))
    ALLOCATE (PSIGS        (NGPTOT,1,KLEV,1))
    ALLOCATE (PMFCONV      (NGPTOT,1,KLEV,1))
    ALLOCATE (PRC_MF       (NGPTOT,1,KLEV,1))
    ALLOCATE (PRI_MF       (NGPTOT,1,KLEV,1))
    ALLOCATE (PCF_MF       (NGPTOT,1,KLEV,1))
    ALLOCATE (PTHS         (NGPTOT,1,KLEV,1))
    ALLOCATE (PRS          (NGPTOT,1,KLEV,KRR,1))
    ALLOCATE (PRS_OUT      (NGPTOT,1,KLEV,KRR,1))
    ALLOCATE (PSRCS_OUT    (NGPTOT,1,KLEV,1))
    ALLOCATE (PCLDFR_OUT   (NGPTOT,1,KLEV,1))
    ALLOCATE (ZRS          (NGPTOT,1,KLEV,0:KRR,1))
    ALLOCATE (ZZZ          (NGPTOT,1,KLEV,1))
    ALLOCATE (PHLC_HRC_OUT (NGPTOT,1,KLEV,1))
    ALLOCATE (PHLC_HCF_OUT (NGPTOT,1,KLEV,1))
    ALLOCATE (PHLI_HRI_OUT (NGPTOT,1,KLEV,1))
    ALLOCATE (PHLI_HCF_OUT (NGPTOT,1,KLEV,1))
  ENDIF

  IF (IOFF+KLON > NGPTOT) THEN
    EXIT
  ENDIF

  READ (IFILE) PRHODJ       (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PEXNREF      (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PRHODREF     (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PSIGS        (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PMFCONV      (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PPABSM       (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) ZZZ          (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PCF_MF       (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PRC_MF       (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PRI_MF       (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) ZRS          (IOFF+1:IOFF+KLON,:,:,:,1) 
  READ (IFILE) PRS          (IOFF+1:IOFF+KLON,:,:,:,1) 
  READ (IFILE) PTHS         (IOFF+1:IOFF+KLON,:,:,1)
  READ (IFILE) PRS_OUT      (IOFF+1:IOFF+KLON,:,:,:,1) 
  READ (IFILE) PSRCS_OUT    (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PCLDFR_OUT   (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PHLC_HRC_OUT (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PHLC_HCF_OUT (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PHLI_HRI_OUT (IOFF+1:IOFF+KLON,:,:,1) 
  READ (IFILE) PHLI_HCF_OUT (IOFF+1:IOFF+KLON,:,:,1) 
  
  CLOSE (IFILE)

  IOFF = IOFF + KLON

ENDDO

IF (NFLEVG /= KLEV) THEN
  CALL INTERPOLATE (NFLEVG, IOFF, PRHODJ      )
  CALL INTERPOLATE (NFLEVG, IOFF, PEXNREF     )
  CALL INTERPOLATE (NFLEVG, IOFF, PRHODREF    )
  CALL INTERPOLATE (NFLEVG, IOFF, PSIGS       )
  CALL INTERPOLATE (NFLEVG, IOFF, PMFCONV     )
  CALL INTERPOLATE (NFLEVG, IOFF, PPABSM      )
  CALL INTERPOLATE (NFLEVG, IOFF, ZZZ         )
  CALL INTERPOLATE (NFLEVG, IOFF, PCF_MF      )
  CALL INTERPOLATE (NFLEVG, IOFF, PRC_MF      )
  CALL INTERPOLATE (NFLEVG, IOFF, PRI_MF      )
  CALL INTERPOLATE (NFLEVG, IOFF, ZRS         )
  CALL INTERPOLATE (NFLEVG, IOFF, PRS         )
  CALL INTERPOLATE (NFLEVG, IOFF, PTHS        )
  CALL INTERPOLATE (NFLEVG, IOFF, PRS_OUT     )
  CALL INTERPOLATE (NFLEVG, IOFF, PSRCS_OUT   )
  CALL INTERPOLATE (NFLEVG, IOFF, PCLDFR_OUT  )
  CALL INTERPOLATE (NFLEVG, IOFF, PHLC_HRC_OUT)
  CALL INTERPOLATE (NFLEVG, IOFF, PHLC_HCF_OUT)
  CALL INTERPOLATE (NFLEVG, IOFF, PHLI_HRI_OUT)
  CALL INTERPOLATE (NFLEVG, IOFF, PHLI_HCF_OUT)
ENDIF

CALL REPLICATE (IOFF, PRHODJ       (:, :, :, 1))
CALL REPLICATE (IOFF, PEXNREF      (:, :, :, 1))
CALL REPLICATE (IOFF, PRHODREF     (:, :, :, 1))
CALL REPLICATE (IOFF, PSIGS        (:, :, :, 1))
CALL REPLICATE (IOFF, PMFCONV      (:, :, :, 1))
CALL REPLICATE (IOFF, PPABSM       (:, :, :, 1))
CALL REPLICATE (IOFF, ZZZ          (:, :, :, 1))
CALL REPLICATE (IOFF, PCF_MF       (:, :, :, 1))
CALL REPLICATE (IOFF, PRC_MF       (:, :, :, 1))
CALL REPLICATE (IOFF, PRI_MF       (:, :, :, 1))
CALL REPLICATE (IOFF, ZRS          (:, :, :, :, 1))
CALL REPLICATE (IOFF, PRS          (:, :, :, :, 1))
CALL REPLICATE (IOFF, PTHS         (:, :, :, 1))
CALL REPLICATE (IOFF, PRS_OUT      (:, :, :, :, 1))
CALL REPLICATE (IOFF, PSRCS_OUT    (:, :, :, 1))
CALL REPLICATE (IOFF, PCLDFR_OUT   (:, :, :, 1))
CALL REPLICATE (IOFF, PHLC_HRC_OUT (:, :, :, 1))
CALL REPLICATE (IOFF, PHLC_HCF_OUT (:, :, :, 1))
CALL REPLICATE (IOFF, PHLI_HRI_OUT (:, :, :, 1))
CALL REPLICATE (IOFF, PHLI_HCF_OUT (:, :, :, 1))

CALL NPROMIZE (NPROMA, PRHODJ      ,  PRHODJ_B        )
CALL NPROMIZE (NPROMA, PEXNREF     ,  PEXNREF_B       )
CALL NPROMIZE (NPROMA, PRHODREF    ,  PRHODREF_B      )
CALL NPROMIZE (NPROMA, PSIGS       ,  PSIGS_B         )
CALL NPROMIZE (NPROMA, PMFCONV     ,  PMFCONV_B       )
CALL NPROMIZE (NPROMA, PPABSM      ,  PPABSM_B        )
CALL NPROMIZE (NPROMA, ZZZ         ,  ZZZ_B           )
CALL NPROMIZE (NPROMA, PCF_MF      ,  PCF_MF_B        )
CALL NPROMIZE (NPROMA, PRC_MF      ,  PRC_MF_B        )
CALL NPROMIZE (NPROMA, PRI_MF      ,  PRI_MF_B        )
CALL NPROMIZE (NPROMA, ZRS         ,  ZRS_B           )
CALL NPROMIZE (NPROMA, PRS         ,  PRS_B           )
CALL NPROMIZE (NPROMA, PTHS        ,  PTHS_B          )
CALL NPROMIZE (NPROMA, PRS_OUT     ,  PRS_OUT_B       )
CALL NPROMIZE (NPROMA, PSRCS_OUT   ,  PSRCS_OUT_B     )
CALL NPROMIZE (NPROMA, PCLDFR_OUT  ,  PCLDFR_OUT_B    )
CALL NPROMIZE (NPROMA, PHLC_HRC_OUT,  PHLC_HRC_OUT_B  )
CALL NPROMIZE (NPROMA, PHLC_HCF_OUT,  PHLC_HCF_OUT_B  )
CALL NPROMIZE (NPROMA, PHLI_HRI_OUT,  PHLI_HRI_OUT_B  )
CALL NPROMIZE (NPROMA, PHLI_HCF_OUT,  PHLI_HCF_OUT_B  )

END SUBROUTINE 

SUBROUTINE REPLICATE4 (KOFF, P)

INTEGER :: KOFF
REAL    :: P (:,:,:,:)

INTEGER :: I, J

DO I = KOFF+1, SIZE (P, 1)
  J = 1 + MODULO (I - 1, KOFF)
  P (I, :, :, :) = P (J, :, :, :)
ENDDO

END SUBROUTINE

SUBROUTINE REPLICATE3 (KOFF, P)

INTEGER :: KOFF
REAL    :: P (:,:,:)

INTEGER :: I, J

DO I = KOFF+1, SIZE (P, 1)
  J = 1 + MODULO (I - 1, KOFF)
  P (I, :, :) = P (J, :, :)
ENDDO

END SUBROUTINE

SUBROUTINE NPROMIZE4 (KPROMA, PI, PO)

INTEGER :: KPROMA
REAL, INTENT (IN)  :: PI (:,:,:,:) 
REAL, INTENT (OUT) :: PO (:,:,:,:)

INTEGER :: I, J, IGPBLK, IGPTOT, IGP, JLON, JIDIA, JFDIA

IF (SIZE (PI, 4) /= 1) STOP 1

IGPTOT = SIZE (PI, 1)
IGPBLK = 1 + (IGPTOT-1) / KPROMA

DO IGP = 1, IGPTOT, KPROMA
  IBL = 1 + (IGP - 1) / KPROMA
  JIDIA = 1
  JFDIA = MIN (KPROMA, IGPTOT - (IBL - 1) * KPROMA)

  DO JLON = JIDIA, JFDIA
    PO (JLON, :, :, IBL) = PI (IGP + (JLON - 1), :, :, 1)
  ENDDO

  DO JLON = JFDIA+1, KPROMA
    PO (JLON, :, :, IBL) = PO (JFDIA, :, :, IBL)
  ENDDO

ENDDO

END SUBROUTINE

SUBROUTINE NPROMIZE5 (KPROMA, PI, PO)

INTEGER :: KPROMA
REAL, INTENT (IN)  :: PI (:,:,:,:,:) 
REAL, INTENT (OUT) :: PO (:,:,:,:,:)

INTEGER :: I, J, IGPBLK, IGPTOT, IGP, JLON, JIDIA, JFDIA

IF (SIZE (PI, 5) /= 1) STOP 1

IGPTOT = SIZE (PI, 1)
IGPBLK = 1 + (IGPTOT-1) / KPROMA

DO IGP = 1, IGPTOT, KPROMA
  IBL = 1 + (IGP - 1) / KPROMA
  JIDIA = 1
  JFDIA = MIN (KPROMA, IGPTOT - (IBL - 1) * KPROMA)

  DO JLON = JIDIA, JFDIA
    PO (JLON, :, :, :, IBL) = PI (IGP + (JLON - 1), :, :, :, 1)
  ENDDO

  DO JLON = JFDIA+1, KPROMA
    PO (JLON, :, :, :, IBL) = PI (JFDIA, :, :, :, IBL)
  ENDDO

ENDDO

END SUBROUTINE

SUBROUTINE INTERPOLATE4 (KFLEVG, KOFF, P)

INTEGER :: KFLEVG, KOFF
REAL, ALLOCATABLE :: P (:,:,:,:)
REAL :: Z (LBOUND (P, 1):UBOUND (P, 1), &
         & LBOUND (P, 2):UBOUND (P, 2), &
         & LBOUND (P, 3):UBOUND (P, 3), &
         & LBOUND (P, 4):UBOUND (P, 4))
INTEGER :: ILEV1A, ILEV1B, ILEV2, NLEV1, NLEV2
REAL :: ZWA, ZWB, ZLEV1, ZLEV2

Z = P

NLEV1 = SIZE (P, 3)
NLEV2 = KFLEVG

DEALLOCATE (P)

ALLOCATE (P (LBOUND (Z, 1):UBOUND (Z, 1), &
           & LBOUND (Z, 2):UBOUND (Z, 2), &
           & KFLEVG, &
           & LBOUND (Z, 4):UBOUND (Z, 4)))

DO ILEV2 = 1, NLEV2
  ZLEV2 = REAL (ILEV2 - 1) / REAL (NLEV2 -1)
  ZLEV1 = 1. + ZLEV2 * REAL (NLEV1 - 1)
  ILEV1B = MIN (CEILING (ZLEV1), NLEV1)
  ILEV1A = MAX (FLOOR   (ZLEV1),     1)

  IF (ILEV1A == ILEV1B) THEN
    ZWA = 1.
    ZWB = 0.
  ELSE
    ZWA = REAL (ILEV1B) - ZLEV1
    ZWB = ZLEV1 - REAL (ILEV1A)
  ENDIF

! WRITE (*, '(" ZLEV2 = ",E12.5," ZLEV1 = ",E12.5," ILEV2 = ",I4," ILEV1A = ",I4," ZWA = ",E12.5," ILEV1B = ",I4," ZWB = ",E12.5)') &
!   & ZLEV2, ZLEV1, ILEV2, ILEV1A, ZWA, ILEV1B, ZWB

  P (1:KOFF, :, ILEV2, :) = ZWA * Z (1:KOFF, :, ILEV1A, :) + ZWB * Z (1:KOFF, :, ILEV1B, :) 
ENDDO

END SUBROUTINE

SUBROUTINE INTERPOLATE5 (KFLEVG, KOFF, P)

INTEGER :: KFLEVG, KOFF
REAL, ALLOCATABLE :: P (:,:,:,:,:)
REAL :: Z (LBOUND (P, 1):UBOUND (P, 1), &
         & LBOUND (P, 2):UBOUND (P, 2), &
         & LBOUND (P, 3):UBOUND (P, 3), &
         & LBOUND (P, 4):UBOUND (P, 4), &
         & LBOUND (P, 5):UBOUND (P, 5))
INTEGER :: ILEV1A, ILEV1B, ILEV2, NLEV1, NLEV2
REAL :: ZWA, ZWB, ZLEV1, ZLEV2

Z = P

NLEV1 = SIZE (P, 3)
NLEV2 = KFLEVG

DEALLOCATE (P)

ALLOCATE (P (LBOUND (Z, 1):UBOUND (Z, 1), &
           & LBOUND (Z, 2):UBOUND (Z, 2), &
           & KFLEVG, &
           & LBOUND (Z, 4):UBOUND (Z, 4), &
           & LBOUND (Z, 5):UBOUND (Z, 5)))

DO ILEV2 = 1, NLEV2
  ZLEV2 = REAL (ILEV2 - 1) / REAL (NLEV2 -1)
  ZLEV1 = 1. + ZLEV2 * REAL (NLEV1 - 1)
  ILEV1B = MIN (CEILING (ZLEV1), NLEV1)
  ILEV1A = MAX (FLOOR   (ZLEV1),     1)

  IF (ILEV1A == ILEV1B) THEN
    ZWA = 1.
    ZWB = 0.
  ELSE
    ZWA = REAL (ILEV1B) - ZLEV1
    ZWB = ZLEV1 - REAL (ILEV1A)
  ENDIF

! WRITE (*, '(" ZLEV2 = ",E12.5," ZLEV1 = ",E12.5," ILEV2 = ",I4," ILEV1A = ",I4," ZWA = ",E12.5," ILEV1B = ",I4," ZWB = ",E12.5)') &
!   & ZLEV2, ZLEV1, ILEV2, ILEV1A, ZWA, ILEV1B, ZWB

  P (1:KOFF, :, ILEV2, :, :) = ZWA * Z (1:KOFF, :, ILEV1A, :, :) + ZWB * Z (1:KOFF, :, ILEV1B, :, :) 
ENDDO

END SUBROUTINE

SUBROUTINE SET3 (P)

REAL :: P (:,:,:)
INTEGER :: IBL, IGPBLKS
INTEGER :: NTID, ITID, JBLK1, JBLK2


IGPBLKS = SIZE (P, 3)

!$OMP PARALLEL PRIVATE (ITID, JBLK1, JBLK2, NTID)
NTID = OMP_GET_MAX_THREADS ()
ITID = OMP_GET_THREAD_NUM ()
JBLK1 = 1 +  (IGPBLKS * (ITID+0)) / NTID
JBLK2 =      (IGPBLKS * (ITID+1)) / NTID

DO IBL = JBLK1, JBLK2
  P (:,:,IBL) = ZNAN
ENDDO

!$OMP END PARALLEL

END SUBROUTINE

SUBROUTINE SET4 (P)

REAL :: P (:,:,:,:)
INTEGER :: IBL, IGPBLKS
INTEGER :: NTID, ITID, JBLK1, JBLK2

IGPBLKS = SIZE (P, 4)

!$OMP PARALLEL PRIVATE (ITID, JBLK1, JBLK2, NTID)
NTID = OMP_GET_MAX_THREADS ()
ITID = OMP_GET_THREAD_NUM ()
JBLK1 = 1 +  (IGPBLKS * (ITID+0)) / NTID
JBLK2 =      (IGPBLKS * (ITID+1)) / NTID

DO IBL = JBLK1, JBLK2
  P (:,:,:,IBL) = ZNAN
ENDDO

!$OMP END PARALLEL

END SUBROUTINE

SUBROUTINE SET5 (P)

REAL :: P (:,:,:,:,:)
INTEGER :: IBL, IGPBLKS
INTEGER :: NTID, ITID, JBLK1, JBLK2

IGPBLKS = SIZE (P, 5)

!$OMP PARALLEL PRIVATE (ITID, JBLK1, JBLK2, NTID)
NTID = OMP_GET_MAX_THREADS ()
ITID = OMP_GET_THREAD_NUM ()
JBLK1 = 1 +  (IGPBLKS * (ITID+0)) / NTID
JBLK2 =      (IGPBLKS * (ITID+1)) / NTID

DO IBL = JBLK1, JBLK2
  P (:,:,:,:,IBL) = ZNAN
ENDDO

!$OMP END PARALLEL

END SUBROUTINE


END  MODULE
