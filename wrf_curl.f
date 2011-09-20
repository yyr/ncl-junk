c--------------------------------------------------------
C     http://forum.wrfforum.com/viewtopic.php?f=32&t=2267&p=15399#p14791

C     NCLFORTSTART
      SUBROUTINE DCOMPUTECURL(CRL,U,V,MSFT,DX,DY,NX,NY,NZ)
      IMPLICIT NONE
      INTEGER NX,NY,NZ
      DOUBLE PRECISION U(NX,NY,NZ),V(NX,NY,NZ)
      DOUBLE PRECISION CRL(NX,NY,NZ),MSFT(NX,NY)
      DOUBLE PRECISION DX,DY
C     NCLEND

      INTEGER JP1,JM1,IP1,IM1,I,J,K
      DOUBLE PRECISION DSY,DSX,DVDX,DUDY
      DOUBLE PRECISION MM

C     Note all data must be on T-pts
      DO K = 1,NZ
         DO J = 1,NY
            JP1 = MIN(J+1,NY)
            JM1 = MAX(J-1,1)
            DO I = 1,NX
               IP1 = MIN(I+1,NX)
               IM1 = MAX(I-1,1)

               DSX = (IP1-IM1)*DX
               DSY = (JP1-JM1)*DY
c     Careful with map factors...
               MM = MSFT(I,J)*MSFT(I,J)
               DVDX = (V(IP1,J,K)/MSFT(IP1,J) -
     *              V(IM1,J,K)/MSFT(IM1,J))/DSX*MM

               DUDY = (U(I,JP1,K)/MSFT(I,JP1) -
     *              U(I,JM1,K)/MSFT(I,JM1))/DSY*MM

C     RL(I,J,K) = DVDX - DUDY
            END DO
         END DO
      END DO
      RETURN
      END
