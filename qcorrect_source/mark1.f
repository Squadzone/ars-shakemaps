      subroutine mark1()
      use respinfo
      A0=3.13368D+10                                      !A0
      f0=5.0                                              !f0
      nzero=3                                             !Number of zeros
      npole=8                                             !Number of poles
      z(1)=cmplx( 0.00000E+00, 0.00000E+00)               !Z1
      z(2)=cmplx( 0.00000E+00, 0.00000E+00)               !Z2
      z(3)=cmplx( 0.00000E+00, 0.00000E+00)               !Z3
      p(1)=cmplx(-0.62830E+00, 0.00000E+00)               !P1
      p(2)=cmplx(-4.44220E+00, 4.44360E+00)               !P2
      p(3)=cmplx(-4.44220E+00,-4.44360E+00)               !P3
      p(4)=cmplx(-1.25664E+02, 0.00000E+00)               !P4
      p(5)=cmplx(-1.01660E+02, 0.73870E+02)               !P5
      p(6)=cmplx(-1.01660E+02,-0.73870E+02)               !P6
      p(7)=cmplx(-0.38830E+02, 1.19510E+02)               !P7
      p(8)=cmplx(-0.38830E+02,-1.19510E+02)               !P8
      sensitivity=1.00000D+08                             !Sensitivity
c     sensitivity=1.00000D+10                             !Sensitivity. Changed for unit consistency with other subroutines
      return
      end

