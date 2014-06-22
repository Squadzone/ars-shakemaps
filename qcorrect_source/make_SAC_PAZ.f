      subroutine make_SAC_PAZ()
      use respinfo
      implicit none
      integer                     :: i
      open(unit=14,file='SAC.PAZ',status='unknown')
      if(nzero < 10)then
           write(14,141)nzero
141        format('ZEROS ',i1)
      else
           write(14,142)nzero
142        format('ZEROS ',i2)
      endif
      if(nzero >= 1)then
           do i=1,nzero,1
                write(14,'(2(f11.4,2x))')real(z(i)),aimag(z(i))
           enddo
      endif
      if(npole < 10)then
           write(14,143)npole
143        format('POLES ',i1)
      else
           write(14,144)npole
144        format('POLES ',i2)
      endif
      if(npole >= 1)then
           do i=1,npole,1
                write(14,'(2(f11.4,2x))')real(p(i)),imag(p(i))
           enddo
      endif
      write(14,145)sensitivity*A0
145   format('CONSTANT ',g13.5)
      close(unit=14)
      return
      end

