      subroutine merge_traces(namepart)
      implicit none
      integer                    :: i, j, k, n, is, nfiles, npoint
      integer, dimension(100)    :: npoints
      real                       :: values(100000,100)
      real                       :: allvalues(1050000)
      character (len=50)         :: nam, namepart, filelist(100)
      character (len=80)         :: header1(30), header2(30)
      character (len=80)         :: header(30,100)
      is = 0
      nfiles = 0
      filelist = ''
      npoints = 0
      values=0.
      call dirf(namepart,'sac_sublis.txt')
      open(unit=80,file='sac_sublis.txt',status='old')
      do while (is == 0)
           nfiles = nfiles + 1
           read(80,'(a50)',iostat = is) filelist(nfiles)
           if(is /= 0)then
                filelist(nfiles)=''
                nfiles=nfiles-1
           endif
      enddo
      close(unit=80)
      call system('rm -f sac_sublis.txt')
      do while (len_trim(filelist(nfiles)) == 0)
           nfiles=nfiles-1
      enddo
      if(nfiles.eq.1)return

      do i=1,nfiles
           nam=filelist(i)
           call repair_trace(nam)
           call system('rm -f original.sac')
           open(unit=81,file=nam,status='old')
           do j=1,30
                read(81,'(a80)')header(j,i)
           enddo
           read(header(16,i)(45:),'(i6)')npoints(i)
           read(81,*)values(1:npoints(i),i)
           close(unit=81)
           if(i > 1)then
                header1(1:30)=header(1:30,i-1)
                header2(1:30)=header(1:30,i)
                npoint=npoints(i-1)
                call addzeros(header1, header2, npoint)
                npoints(i-1)=npoint
           endif
           call system('rm -f '//trim(nam))
      enddo

      n=0
      do i=1,nfiles
           allvalues(n+1:n+npoints(i))=values(1:npoints(i),i)
           n=n+npoints(i)
      enddo
      write(header(16,1)(45:),'(i6)')n

      open(unit=81,file=trim(filelist(1)),status='new')
      do i=1,30
           write(81,'(a80)')header(i,1)
      enddo
      write(81,'(5(g14.6,1x))')(allvalues(i),i=1,n)
      close(unit=81)

      return
      end
