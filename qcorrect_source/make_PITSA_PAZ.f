      subroutine make_PITSA_PAZ()
      use respinfo
      implicit none
      integer                     :: i
      open(unit=13,file='PITSA.PAZ',status='unknown')
      write(13,'(a34)')'CAL1                           PAZ'
      if(npole < 10)then
           write(13,'(i1)')npole
      else
           write(13,'(i2)')npole
      endif
      if(npole >= 1)then
           do i=1,npole,1
                write(13,'(2(g8.3E1))')real(p(i)),aimag(p(i))
           enddo
      endif
      if(nzero < 10)then
           write(13,'(i1)')nzero
      else
           write(13,'(i2)')nzero
      endif
      if(nzero >= 1)then
           do i=1,nzero,1
                write(13,'(2(g8.3E1))')real(z(i)),aimag(z(i))
           enddo
      endif
      write(13,'(g8.3)')sensitivity*A0
      close(unit=13)
      return
      end

