      subroutine repair_trace(fname)
      integer             :: i, j, k
      integer             :: is, nline
      character (len=*)   :: fname
      character (len=100) :: line(200000)
      is=0
      nline=0
c      call system('cp '//trim(fname)//' original.sac')
      open(unit=21,file=fname,status='unknown')
      do while (is==0) 
           nline=nline+1
           read(21,'(a100)',iostat=is)line(nline)
      enddo
      do i=31,nline,1
           do j=15,75,15
                if(line(i)(j:j+1) == '00')then
                     do while (line(i)(j:j+1) == '00')
                          do k=j,99,1
                               line(i)(k:k)=line(i)(k+1:k+1)
                          enddo
                     enddo
                     line(i)(j:j)=' '
                endif
                if(line(i)(j:j) == '0'.and.line(i)(j+1:j+1) /= ' ')then
                     line(i)(j:j)=' '
                endif
           enddo
      enddo
      rewind(unit=21)
      do i=1,nline,1
           write(21,'(a)')line(i)(1:len(line(i)))
      enddo
      close(unit=21)
      return
      end
