MODULE INIT
  IMPLICIT NONE

  INTEGER, PARAMETER :: DP = SELECTED_REAL_KIND(15,307)

  INTEGER, PARAMETER :: N = 100

END MODULE INIT

MODULE CHEBYROOTS
  USE INIT

CONTAINS

  SUBROUTINE CHEBYCOMP(A,B,C)
    REAL(KIND=DP), INTENT(IN), DIMENSION(0:N) :: C
    REAL(KIND=DP), INTENT(IN) :: A, B

    REAL(KIND=DP), DIMENSION(N,N) :: M     !FROBENIUS-CHEBYSHEV COMPANION MATRIX

    INTEGER :: I1

    M = 0.0_DP

    DO I1 = 1,N-1
       M(I1,I1+1) = 0.5_DP
       M(I1+1,I1) = 0.5_DP
    END DO

    M(N,1:N) = (/ (-0.5_DP*C(I1-1)/C(N), I1=1,N) /)

    M(1,2) = 1.0_DP
    M(N,N-1) = M(N,N-1) + 0.5_DP

    CALL EIGEN(A,B,M)

    RETURN
  END SUBROUTINE CHEBYCOMP

  SUBROUTINE EIGEN(A,B,M)
    REAL(KIND=DP), DIMENSION(N,N) :: M
    REAL(KIND=DP), INTENT(IN) :: A, B

    CHARACTER :: JOBVL = 'N', JOBVE = 'N', INFO
    REAL(KIND=DP), DIMENSION(N) :: WR, WI
    REAL(KIND=DP), DIMENSION(1) :: VR, VL
    INTEGER, PARAMETER :: LDVL = 1, LDVR = 1, LWORK = 5*N
    REAL(KIND=DP), DIMENSION(LWORK) :: WORK

    INTEGER :: I1,I2

    CALL DGEEV(JOBVL, JOBVE, N, M, N, WR, WI, VL, LDVL, VR, LDVR, WORK, LWORK, INFO)

    PRINT *, 'PRINTING ALL THE ROOTS IN THE INTERVAL:'
    DO I1 = 1,N
       IF(ABS(WI(I1)) .LT. 1.D-16 .AND. ABS(WR(I1)) .LE. 1.0_DP) THEN
          PRINT *, 0.5_DP*(B-A)*WR(I1) + 0.5_DP*(B+A)
       END IF
    END DO

  END SUBROUTINE EIGEN
END MODULE CHEBYROOTS

MODULE CHEBYINTER
  USE INIT
  USE CHEBYROOTS

  REAL(KIND=DP), PARAMETER :: PI = ACOS(-1.0_DP)

  REAL(KIND=DP), DIMENSION(0:N) :: X        !INTERPOLATION POINTS (LOBATTO GRID)
  REAL(KIND=DP), DIMENSION(0:N) :: C


  LOGICAL :: PLOT = .TRUE., EIG = .TRUE.

CONTAINS

  SUBROUTINE INTERPOLATE(A,B,G)
    REAL(KIND=DP), INTENT(IN) :: A,B

    REAL(KIND=DP), DIMENSION(0:N) :: F        !GRID POINTS FOR FUNCTION F
    REAL(KIND=DP), DIMENSION(0:N,0:N) :: J    !INTERPOLATION MATRIX

    REAL(KIND=DP) :: G
    EXTERNAL G

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

    PRINT *, 'PRINTING COEFFICIENT OF CHEBYSHEV INTERPOLATION:'
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

    INTEGER :: I1,I2

    TYPE(GPF) :: GPLOT

    EVAL = 0.0_DP

    DO I1=0,N
       DO I2=0,N
          EVAL(I1) = EVAL(I1) + C(I2) * COS( DBLE(I2) * ACOS( (2.0_DP * X(I1) - B - A)/(B-A)))
       END DO
    END DO

    CALL GPLOT%PLOT(X,EVAL)

    RETURN
  END SUBROUTINE SUM

END MODULE CHEBYINTER
