      subroutine addzeros(header1,header2,npoints)
      implicit none
      integer                     :: npoints
      real                        :: dur, sample_int
      double precision            :: sec, sec1, sec2
      character (len=80)          :: header1(30), header2(30)
      call findstartsec(header1, sec1)
      call findduration(header1, dur, sample_int)
      call findstartsec(header2, sec2)
      sec=sec2-(sec1+dble(dur))
      npoints=npoints+anint(sec/sample_int)
      return
      end

