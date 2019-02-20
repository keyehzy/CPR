MODULE CHEBYINTER
  USE INTERFACE
  USE CHEBYROOTS
  
  REAL(KIND=DP) :: PI = ACOS(-1.0_DP)
  
  REAL(KIND=DP), DIMENSION(0:N) :: X        !INTERPOLATION POINTS (LOBATTO GRID)  

  LOGICAL :: PLOT = .TRUE., EIG = .TRUE.
  
CONTAINS

  SUBROUTINE INTERPOLATE(A,B,C)
    REAL(KIND=DP), INTENT(IN) :: A,B
    REAL(KIND=DP), INTENT(OUT), DIMENSION(0:N) :: C

    REAL(KIND=DP), DIMENSION(0:N) :: F        !GRID POINTS FOR FUNCTION F
    REAL(KIND=DP), DIMENSION(0:N,0:N) :: J    !INTERPOLATION MATRIX

    INTEGER :: I1,I2  
    REAL(KIND=DP) :: BMA, BPA

    !STEP 1: CONSTRUCT THE LOBBATO GRID AND F(X)

    X = 0.0_DP
    F = 0.0_DP

    BMA = (B-A) / 2.0_DP
    BPA = (B+A) / 2.0_DP

    !NEED TO IMPROVE THIS STEP IN ORDER TO RE-USE POINTS IN GRID WITH OTHER SIZES
    X(0:N) = (/ (BMA * COS(PI * DBLE(I1) / DBLE(N)) + BPA, I1 = 0,N) /)
    F(0:N) = (/ (G(X(I1)), I1 = 0,N) /)

    !STEP 2 CONSTRUCT THE INTERPOLATION MATRIX NAD OBTAIN THE COEFFICIENTS

    J = 0.0_DP
    C = 0.0_DP

    DO I1=0,N
       PJ = 1
       IF(I1 .EQ. 0 .OR. I1 .EQ. N) PJ = 2
       DO I2=0,N
          PK = 1
          IF(I2 .EQ. 0 .OR. I2 .EQ. N) PK = 2
          
          J(I1,I2) = 2.0_DP * COS(PI * DBLE(I1) * DBLE(I2) / DBLE(N)) / DBLE(PJ) / DBLE(PK) / DBLE(N)

          !NEED TO IMPROVE THIS STEP BY DCT THESE
          C(I1) = C(I1) + J(I1,I2) * F(I2)
          
       END DO
    END DO
    
    PRINT *, 'PRINTING COEFFICIENT OF CHEBYSHEV INTERPOLATION'
    DO I1=0,N
       PRINT '(F10.5)', C(I1)
    END DO

    IF(PLOT) CALL SUM(A,B,C)

    IF(EIG) CALL CHEBYCOMP(A,B,C)
    
    RETURN
  END SUBROUTINE INTERPOLATE

  SUBROUTINE SUM(A,B,C)
    USE OGPF
    REAL(KIND=DP), INTENT(IN) :: A,B
    REAL(KIND=DP), INTENT(IN), DIMENSION(0:N) :: C
    REAL(KIND=DP),DIMENSION(0:N) :: EVAL
!    REAL(KIND=DP) :: BMA, BPA
!    REAL(KIND=DP), DIMENSION(0:N) :: XI
    !, B0, B1, B2, B3
    INTEGER :: I1,I2

    TYPE(GPF) :: GPLOT

    EVAL = 0.0_DP
    
!    BMA = B-A
!    BPA = B+A
!    XI(0:N) = (/ ((2.0_DP * X(I1) - BPA)/BMA, I1 = 0,N) /)
!!$
!!$    B0 = 0.0_DP
!!$    B1 = 0.0_DP
!!$    B2 = 0.0_DP
!!$    B3 = 0.0_DP
!!$    
!!$    DO I1=0,N
!!$       DO I2=1,N
!!$          B0(I1) = 2.0_DP * XI(I1) * B1(I1) - B2(I1) + C(N+1-I2)
!!$          B3 = B2
!!$          B2 = B1
!!$          B1 = B0
!!$       END DO
!!$    END DO
!!$    EVAL(0:N) = (/ (0.5_DP*(B0(I1) - B3(I1) + 0.5_DP*C(0)), I1 = 0,N) /)
    
    DO I1=0,N
       DO I2=0,N
          EVAL(I1) = EVAL(I1) + C(I2) * COS( DBLE(I2) * ACOS( (2.0_DP * X(I1) - B - A)/(B-A)))
       END DO
    END DO

    CALL GPLOT%PLOT(X,EVAL)

    RETURN
  END SUBROUTINE SUM
  
  FUNCTION G(X) RESULT(J)
    REAL(KIND=DP) :: J
    REAL(KIND=DP), INTENT(IN) :: X
    
    J = SIN(X)*COS(2.0_DP*X)
    
    RETURN

  END FUNCTION G
END MODULE CHEBYINTER
