      subroutine findduration(header,dur,sample_int)
      implicit none
      integer                     :: nsample
      real                        :: sample_int, dur
      character (len=80)          :: header(30)
      read(header(1),*)sample_int
      read(header(16)(44:),*)nsample
      dur=sample_int*real(nsample)
      return
      end
