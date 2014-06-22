      subroutine mark2()
      use respinfo
      A0=1.01601D+06                                      !A0
      f0=5.0                                              !f0
      nzero=3                                             !Number of zeros
      npole=6                                             !Number of poles
      z(1)=cmplx( 0.00000E+00, 0.00000E+00)               !Z1
      z(2)=cmplx( 0.00000E+00, 0.00000E+00)               !Z2
      z(3)=cmplx( 0.00000E+00, 0.00000E+00)               !Z3
      p(1)=cmplx(-3.14159E+00, 0.00000E+00)               !P1
      p(2)=cmplx(-4.44220E+00, 4.44360E+00)               !P2
      p(3)=cmplx(-4.44220E+00,-4.44360E+00)               !P3
      p(4)=cmplx(-1.00531E+02, 0.00000E+00)               !P4
      p(5)=cmplx(-5.02655E+01, 8.70624E+01)               !P5
      p(6)=cmplx(-5.02655E+01,-8.70624E+01)               !P6
      sensitivity=1.00000D+08                             !Sensitivity
c     sensitivity=1.00000D+10                             !Sensitivity. Changed for unit consistency with other subroutines
      return
      end

