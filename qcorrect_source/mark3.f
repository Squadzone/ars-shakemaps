      subroutine mark3()
      use respinfo
      A0=1.26001D+14                                      !A0
      f0=5.0                                              !f0
      nzero=3                                             !Number of zeros
      npole=10                                            !Number of poles
      z(1)=cmplx( 0.00000E+00, 0.00000E+00)               !Z1
      z(2)=cmplx( 0.00000E+00, 0.00000E+00)               !Z2
      z(3)=cmplx( 0.00000E+00, 0.00000E+00)               !Z3
      p(1)=cmplx(-5.03193E+01, 8.98543E+01)               !P1
      p(2)=cmplx(-5.03193E+01,-8.98543E+01)               !P2
      p(3)=cmplx(-7.47119E+01, 5.25240E+01)               !P3
      p(4)=cmplx(-7.47119E+01,-5.25240E+01)               !P4
      p(5)=cmplx(-8.49678E+01, 1.73505E+01)               !P5
      p(6)=cmplx(-8.49678E+01,-1.73505E+01)               !P6
      p(7)=cmplx(-4.44220E+00, 4.44360E+00)               !P7
      p(8)=cmplx(-4.44220E+00,-4.44360E+00)               !P8
      p(9)=cmplx(-3.57140E+00, 0.00000E+00)               !P9
      p(10)=cmplx(-1.89400E+02, 0.00000E+00)              !P10
      sensitivity=1.00000D+09                             !Sensitivity
c     sensitivity=1.00000D+11                             !Sensitivity. Changed for unit consistency with other subroutines
      return
      end

