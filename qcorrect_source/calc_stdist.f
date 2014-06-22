      subroutine calc_stdist()
      use traceinfo
      use eqpar
      implicit none
      real                        :: PI, D2R, Re
      Re=6378.137
      PI=4.0*atan(1.)
      D2R=PI/180.
      stdist=Re*acos(cos(stalat*D2R)*cos(eqcoord(1)*D2R)*
     1           cos(D2R*(stalon-eqcoord(2)))+
     2           sin(stalat*D2R)*sin(eqcoord(1)*D2R))
      return
      end
