      subroutine findstartsec(header, sec)
      implicit none
      integer                     :: datetime(6), doy, milisec
      double precision            :: sec
      character (len=80)          :: header(30)
      read(header(15), *)datetime(1), doy, datetime(4:6)
      read(header(16), *)milisec
      call doy2date(datetime(1), datetime(2), datetime(3), doy)
      call julsec(datetime, sec)
      sec=sec+dble(milisec)/1000.
      return
      end
