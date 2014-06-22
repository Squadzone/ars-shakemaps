      subroutine mark5()
      use respinfo
      A0=1.27277D+07                                      !A0
      f0=5.0                                              !f0
      nzero=4                                             !Number of zeros
      npole=9                                             !Number of poles
      z(1)=cmplx( 0.00000E+00, 0.00000E+00)               !Z1
      z(2)=cmplx( 0.00000E+00, 0.00000E+00)               !Z2
      z(3)=cmplx( 0.00000E+00, 0.00000E+00)               !Z3
      z(4)=cmplx( 0.00000E+00, 0.00000E+00)               !Z4
      p(1)=cmplx(-3.59050E+00, 2.69270E+00)               !P1
      p(2)=cmplx(-3.59050E+00,-2.69270E+00)               !P2
      p(3)=cmplx(-0.13960E+00, 0.00000E+00)               !P3
      p(4)=cmplx(-1.00000E+02, 0.00000E+00)               !P4
      p(5)=cmplx(-4.48800E+00, 0.00000E+00)               !P5
      p(6)=cmplx(-2.82700E+01, 0.00000E+00)               !P6
      p(7)=cmplx(-5.25800E+01, 0.00000E+00)               !P7
      p(8)=cmplx(-2.50900E+01, 4.23218E+01)               !P8
      p(9)=cmplx(-2.50900E+01,-4.23218E+01)               !P9
      sensitivity=0.98600D+11                             !Sensitivity
c     sensitivity=0.98600D+13                             !Sensitivity. Changed for unit consistency with other subroutines
      return
      end

